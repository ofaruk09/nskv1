//
//  pinnedEventsViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 14/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "pinnedEventsViewController.h"

@interface pinnedEventsViewController ()

@end

@implementation pinnedEventsViewController
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
    NSLog(@"%i",PinnedEvents.count);
    [self refreshView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"view did appear");
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [PinnedEvents count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

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
    if([self eventIsFlagged:model]){
        NSLog(@"changing status");
        [cell.eventStatusIcon setHidden:false];
    }
    return cell;
}
-(bool)eventIsFlagged:(FacebookEvent*) event
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *newPrefs = [defaults objectForKey:@"FacebookEventChanged"];
    NSArray *currentFlaggedEvents = [newPrefs componentsSeparatedByString:@","];
    for (NSString *str in currentFlaggedEvents) {
        if([str isEqualToString:event.eventID]){
            NSLog(@"This event has been flagged");
            return true;
        }
    }
    return false;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"eventDetails"]){
        EventsCell *cell =(EventsCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        [cell.eventStatusIcon setHidden:true];
        [self removeFlagForEvent:[PinnedEvents objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        EventDetailsViewController *eventdet = segue.destinationViewController;
        eventdet.fbEvent = [PinnedEvents objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}

- (void)removeFlagForEvent:(FacebookEvent *)event
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *newPrefs = [defaults objectForKey:@"FacebookEventChanged"];
    NSArray *currentFlaggedEvents = [newPrefs componentsSeparatedByString:@","];
    [defaults removeObjectForKey:@"FacebookEventChanged"];
    NSString *newDefaultValue;
    for (NSString *str in currentFlaggedEvents) {
        NSLog(@"%@ - %@",str, event.eventID);
        if(![str isEqualToString:event.eventID]){
           newDefaultValue = [newDefaultValue stringByAppendingString:[NSString stringWithFormat:@"%@,",str]];
        }
    }
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
