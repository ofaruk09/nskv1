//
//  pinnedEventsViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 14/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "PinnedEventsViewController.h"

@interface PinnedEventsViewController ()
-(void) refreshView;
@property NSMutableArray *PinnedEvents;
@end

@implementation PinnedEventsViewController
@synthesize PinnedEvents;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:@"refreshPinnedList"
                                               object:nil];
    [self refreshView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated
{
    [self refreshView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [PinnedEvents count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
// selector description:
// displays all the events that the user has pinned
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FacebookEvent *model = (FacebookEvent *)[PinnedEvents objectAtIndex:indexPath.row];
    EventsCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.eventName.text = model.eventName;
    cell.eventDesc.text = model.eventDescription;
    [cell.eventThumb setContentMode:UIViewContentModeScaleAspectFill];
    [cell.eventThumb setClipsToBounds:YES];
    cell.eventThumb.image = model.eventImage;
    // check if the event is flagged by a push notification
    if([self eventIsFlagged:model]){
        [cell.eventStatusIcon setHidden:false];
    }
    return cell;
}

// selector description:
// checks if an event has been flagged by checking the user defaults
-(bool)eventIsFlagged:(FacebookEvent*) event
{
    // separates out the values held in the user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *newPrefs = [defaults objectForKey:@"FacebookEventChanged"];
    NSArray *currentFlaggedEvents = [newPrefs componentsSeparatedByString:@","];
    for (NSString *str in currentFlaggedEvents) {
        // if the event id in question matches the event id held in the defaults,
        // return true
        if([str isEqualToString:event.eventID]){
            return true;
        }
    }
    // if there is no such entry, just return false
    return false;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"eventDetails"]){
        EventsCell *cell =(EventsCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        // now we need to deal with the flag for the flagged events
        // first remove the status icon
        [cell.eventStatusIcon setHidden:true];
        // then call the selector to remove the flag from the user prefs.
        [self removeFlagForEvent:[PinnedEvents objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        EventDetailsViewController *eventdet = segue.destinationViewController;
        eventdet.fbEvent = [PinnedEvents objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}
// selector description:
// checks if the event passed to selector is flagged, if it is, removes it from
// the user prefs
- (void)removeFlagForEvent:(FacebookEvent *)event
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *newPrefs = [defaults objectForKey:@"FacebookEventChanged"];
    NSArray *currentFlaggedEvents = [newPrefs componentsSeparatedByString:@","];
    [defaults removeObjectForKey:@"FacebookEventChanged"];
    NSString *newDefaultValue;
    // loops through the list of events, finds the event, removes it from the list
    for (NSString *str in currentFlaggedEvents) {
        if(![str isEqualToString:event.eventID]){
           newDefaultValue = [newDefaultValue stringByAppendingString:[NSString stringWithFormat:@"%@,",str]];
        }
    }
    // sets the new user prefs.
    [defaults setObject:newDefaultValue forKey:@"FacebookEventChanged"];
}


-(void)refreshView
{
    PinnedEvents = [FacebookEvent getPinnedList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

@end
