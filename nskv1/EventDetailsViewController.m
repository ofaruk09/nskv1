//
//  EventDetailsViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 04/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController
@synthesize fbEvent;
@synthesize eventImageView;

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        NSLog(@"%i",indexPath.item);
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
        cell.detailTextLabel.text = fbEvent.eventStartTime;
        return cell;
    }
    else if (indexPath.item == 4){
        static NSString *CellIdentifier = @"eventDetailsCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Event End Time";
        cell.detailTextLabel.text = fbEvent.eventEndTime;
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

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
