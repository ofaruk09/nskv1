//
//  EventsViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 25/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "EventsViewController.h"


@interface EventsViewController ()

@property NSMutableArray *EventsList;
- (void) refreshView:(NSNotification *) notification;

@end

@implementation EventsViewController
@synthesize EventsList;

UIActivityIndicatorView *loadingIndicator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)populateTables {
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    // make this controller listen for when the facebook events have completed downloading
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView:)
                                                 name:@"refreshEventList"
                                               object:nil];
    // add an activity indicator to the view to show that events are being downloaded
    loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: loadingIndicator];
    
    [loadingIndicator startAnimating];
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
    return [EventsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    EventsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    FacebookEvent *model = (FacebookEvent *)[EventsList objectAtIndex:indexPath.row];
    cell.eventName.text = model.eventName;
    cell.eventDesc.text = model.eventDescription;
    [cell.eventThumb setContentMode:UIViewContentModeScaleAspectFill];
    [cell.eventThumb setClipsToBounds:YES];
    cell.eventThumb.image = model.eventImage;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // each row is 80 pixels high
    return 80;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"eventDetails"]){
        EventDetailsViewController *eventdet = segue.destinationViewController;
        eventdet.fbEvent = [EventsList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
    }
}

// selector description:
// this selector is called when the facebook class has sent a notification that the events have completed downloading
- (void)refreshView:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        EventsList = [FacebookEvent getEventsList];
        [self.tableView reloadData];
        if(loadingIndicator != nil){
            [loadingIndicator stopAnimating];
            [loadingIndicator removeFromSuperview];
        }
    });
}

@end