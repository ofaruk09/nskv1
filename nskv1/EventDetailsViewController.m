//
//  EventDetailsViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 04/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import "kayakingConditionsButtonCell.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController
@synthesize fbEvent;
@synthesize pinButton;
@synthesize weatherConditionsButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
// selector description:
// this is the event handler for when the pin/unpin button is pressed.
// if the event is pinned, it sends a message to facebook saying that the user
// is coming to the event
// if the event is unpinned, it sends a message to facebook saying that the user
// is not coming to the event
- (IBAction)PinEvent:(id)sender
{
    if ([FBSession.activeSession.permissions indexOfObject:@"rsvp_event"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        NSLog(@"requesting permission");
    }
    else{
        // if the user is attending flip the values and say user is not attending
        if(fbEvent.eventAttending){
            
            NSString *attendingPost = [fbEvent.eventID stringByAppendingString:@"/declined"];
            // send a message to facebook
            [FBRequestConnection startWithGraphPath:attendingPost parameters:nil HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(error){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Unpinning"
                        message:@"You do not have permission to unpin this event"
                        delegate:self
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
                    [alert show];
                }
                else{
                    [[FacebookEvent getPinnedList] removeObject:fbEvent];
                    fbEvent.eventAttending = false;
                    [self changePinLabel];
                }
            }];
        }
        // if the user is not attending flip the values and say user is attending
        else{
            NSString *attendingPost = [fbEvent.eventID stringByAppendingString:@"/attending"];
            // send a message to facebook
            [FBRequestConnection startWithGraphPath:attendingPost parameters:nil HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(error){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nomad Infinity Event"
                        message:@"To pin this event, ensure you have Infinity membership and have joined the Nomad Members Facebook page"
                        delegate:self
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
                    [alert show];
                }
                else{
                    fbEvent.eventAttending = true;
                    [self changePinLabel];
                    [[FacebookEvent getPinnedList] addObject:fbEvent];
                }
            }];
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self changePinLabel];
}

// selector description:
// called when user presses the pin and unpin button
-(void)changePinLabel
{
    if(fbEvent.eventAttending){
        pinButton.title = @"Unpin";
    }
    else{
        pinButton.title = @"Pin";
    }
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
    // there are 6 sections to display all the event information.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // index path to display the event image
    if(indexPath.item == 0){
        static NSString *CellIdentifier = @"eventImage";
        EventImageCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.eventImage.image = fbEvent.eventImage;
        return cell;
    }
    // index path to display the event name
    else if(indexPath.item == 1){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Event Name";
        cell.detailTextLabel.text = fbEvent.eventName;
        return cell;
    }
    // index path to display the event description
    else if(indexPath.item == 2){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        // set the detail label so the word wraps to the size of the view
        cell.textLabel.text = @"Event Description";
        cell.detailTextLabel.text = fbEvent.eventDescription;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        return cell;
    }
    // index path to display the event start time
    else if (indexPath.item == 3){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Event Start Time";
        // we have to check the format of the date given by facebook so we can
        // display the date properly to the user
        if([fbEvent.dateFormatterStart dateFormat].length > 10){
            NSString *date = [[fbEvent.dateFormatterStart stringFromDate:fbEvent.eventStartDate]substringWithRange:NSMakeRange(0, 10)];
            NSString *time = [[fbEvent.dateFormatterStart stringFromDate:fbEvent.eventStartDate]substringWithRange:NSMakeRange(11, 5)];
            cell.detailTextLabel.text = [[date stringByAppendingString:@" at "] stringByAppendingString:time];
        }
        else
        {
            NSString *date = [fbEvent.dateFormatterStart stringFromDate:fbEvent.eventStartDate];
            cell.detailTextLabel.text = [date stringByAppendingString:@" at no time specified"];
        }
        
        return cell;
    }
    // index path for event end time
    else if (indexPath.item == 4){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Event End Time";
        // we have to check the format of the date given by facebook so we can
        // display the date properly to the user
        if([fbEvent.dateFormatterEnd dateFormat].length > 10 && fbEvent.eventEndDate != nil)
        {
            NSString *date = [[fbEvent.dateFormatterEnd stringFromDate:fbEvent.eventEndDate]substringWithRange:NSMakeRange(0, 10)];
            NSString *time = [[fbEvent.dateFormatterEnd stringFromDate:fbEvent.eventEndDate]substringWithRange:NSMakeRange(11, 5)];
            cell.detailTextLabel.text = [[date stringByAppendingString:@" at "] stringByAppendingString:time];
        }
        else if ([fbEvent.dateFormatterEnd dateFormat].length <= 10 && fbEvent.eventEndDate != nil)
        {
            NSString *date = [fbEvent.dateFormatterEnd stringFromDate:fbEvent.eventEndDate];
            cell.detailTextLabel.text = [date stringByAppendingString:@" at no time specified"];
        }
        // sometimes the right information will not be given so we tell the user to speak to the supervisor
        else
        {
            cell.detailTextLabel.text = @"Contact Supervisor for Information";
        }
        return cell;
    }
    // index path for button to view kayaking conditions
    else {
        // we only enable the button if the event is less than 5 days from the
        // event start date. Because of this we need to calculate how many days
        // till the start of the event
        static NSString *CellIdentifier = @"eventConditionsCell";
        kayakingConditionsButtonCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        double timeToEvent = [fbEvent.eventStartDate timeIntervalSinceNow];
        timeToEvent = timeToEvent/86400; // 86400 is the number of seconds in a day
        NSLog(@"timeToEvent: %f",timeToEvent);
        // if the time is less than 5 days, enable the buttoon
        if(timeToEvent <= 5.0f){
            [cell.conditionsButton setTitle:@"Show Kayaking Conditions" forState:UIControlStateNormal];
            [cell.conditionsButton setEnabled:YES];
        }
        else
        {
            // we minus 5 days off the time to event so the message takes into
            // account from which day the weather information is available which
            // is 5 days from the event start date.
            timeToEvent -=5;
            NSString *message = [NSString stringWithFormat:@"Conditions available in %i days",(int)timeToEvent];
            [cell.conditionsButton setTitle:message forState:UIControlStateNormal];
            [cell.conditionsButton setEnabled:NO];
        }
        return cell;
    }
}
// selector description:
// returns the row height for each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // image is 213 pixels high
    if(indexPath.item == 0){
        return 213;
    }
    // event name cell is 50 pixels high
    else if (indexPath.item == 1){
        return 50;
    }
    // we must determine the size of the event description cell from the
    // amount of text in the description
    else if(indexPath.item == 2){
        UIFont *contentFont = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
        UIFont *sectionFont = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize contentSize = [fbEvent.eventDescription sizeWithFont:contentFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
        CGSize sectionSize = [@"Event Description" sizeWithFont:sectionFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
        
        return contentSize.height + sectionSize.height + 20;
    }
    // all other cells have a height of 60
    else{
        return 60;
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showWeatherForEvent"]){
        WeatherTidesViewController *wvController = segue.destinationViewController;
        wvController.fbEvent = fbEvent;
    }
}
@end
