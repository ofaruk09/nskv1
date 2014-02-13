//
//  EventDetailsViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 04/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AppDelegate.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController
@synthesize fbEvent;
@synthesize pinButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)PinEvent:(id)sender
{
    if ([FBSession.activeSession.permissions indexOfObject:@"rsvp_event"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        NSLog(@"requesting permission");
    }
    else{
        if(fbEvent.eventAttending){
            fbEvent.eventAttending = false;
            [self changePinLabel];
            NSString *attendingPost = [fbEvent.eventID stringByAppendingString:@"/declined"];
            NSLog(@"Event Unpinned");
            [FBRequestConnection startWithGraphPath:attendingPost parameters:nil HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(error){
                    NSLog([error description]);
                }
                else{
                    NSLog(@"successful");
                    [[FacebookEvent getPinnedList] removeObject:fbEvent];
                }
            }];
        }
        else{
            fbEvent.eventAttending = true;
            [self changePinLabel];
            NSString *attendingPost = [fbEvent.eventID stringByAppendingString:@"/attending"];
            NSLog(@"Event Pinned");
            [FBRequestConnection startWithGraphPath:attendingPost parameters:nil HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(error){
                    NSLog([error description]);
                }
                else{
                    NSLog(@"successful");
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
    NSLog(fbEvent.eventID);
    [self changePinLabel];
}

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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item == 0){
        static NSString *CellIdentifier = @"eventImage";
        EventImageCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.eventImage.image = fbEvent.eventImage;
        return cell;
    }
    else if(indexPath.item == 1){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Event Name";
        cell.detailTextLabel.text = fbEvent.eventName;
        return cell;
    }
    else if(indexPath.item == 2){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Event Description";
        cell.detailTextLabel.text = fbEvent.eventDescription;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        return cell;
    }
    else if (indexPath.item == 3){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Event Start Time";
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
    else if (indexPath.item == 4){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Event End Time";
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
        else
        {
            cell.detailTextLabel.text = @"Contact Supervisor for Information";
        }
        //cell.detailTextLabel.text = [[fbEvent.eventEndDate stringByAppendingString:@" at "]stringByAppendingString:fbEvent.eventEndTime];
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"eventWeatherButtonCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.item == 0){
        return 160;
    }
    else if (indexPath.item == 1){
        return 50;
    }
    else if(indexPath.item == 2){
        UIFont *contentFont = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
        UIFont *sectionFont = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize contentSize = [fbEvent.eventDescription sizeWithFont:contentFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
        CGSize sectionSize = [@"Event Description" sizeWithFont:sectionFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
        
        return contentSize.height + sectionSize.height + 20;
    }
    else{
        return 50;
    }
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
    if([[segue identifier] isEqualToString:@"showWeatherForEvent"]){
        // check if within 5 days of event day
        double timeToEvent = [fbEvent.eventStartDate timeIntervalSinceNow];
        timeToEvent = timeToEvent/86400; // 86400 is the number of seconds in a day
        
        //if(timeToEvent <= 5.0f){
        WeatherTidesViewController *wvController = segue.destinationViewController;
        wvController.fbEvent = fbEvent;
        wvController.timeToEvent = timeToEvent;
        //}
        //else{
        //show message to show no wether data beyond 5 days!
        //}
    }
}
@end
