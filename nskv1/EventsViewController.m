//
//  EventsViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 25/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "EventsViewController.h"


@interface EventsViewController ()

@end

@implementation EventsViewController

@synthesize requestConnection = _requestConnection;
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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ([self openFacebookSession]) {
        loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
        [self.view addSubview: loadingIndicator];
        
        [loadingIndicator startAnimating];
        
        [self downloadEvents];
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
    return [EventsList count];
    //return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    EventsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    FacebookEvent *model = (FacebookEvent *)[EventsList objectAtIndex:indexPath.row];
    cell.eventName.text = model.eventName;
    cell.eventDesc.text = model.eventDescription;
    cell.eventThumb.image = model.eventImage;
    //cell.eventName.text = @"This is a test name";
    //cell.eventDesc.text = @"This is a test description";
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
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
        EventDetailsViewController *eventdet = segue.destinationViewController;
        eventdet.fbEvent = [EventsList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)downloadEvents{
    [self sendRequests:@"303838247034/events?fields=name,start_time,cover,description,end_time,location,venue&before=NTQzMTUzNjA5MTAyMjQ3&limit=25"];
    NSLog(@"starting new login");
}




- (void)dealloc {
    [_requestConnection cancel];
}

-(BOOL)openFacebookSession {
    NSLog(@"Hi");
    __block BOOL userLoggedIn = false;
    EventsList = [[NSMutableArray alloc]init];
    if (FBSession.activeSession.isOpen) {
        // login is integrated with the send button -- so if open, we send
        userLoggedIn = true;
    } else {
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState status,
                                                          NSError *error) {
                                          // if login fails for any reason, we alert
                                          if (error) {
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                              [alert show];
                                              // if otherwise we check to see if the session is open, an alternative to
                                              // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
                                              // property of the session object; the macros are useful, however, for more
                                              // detailed state checking for FBSession objects
                                          } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                              // send our requests if we successfully logged in
                                              NSLog(@"user logged in");
                                              userLoggedIn = true;
                                          }
                                      }];
    }
    if(userLoggedIn) return true;
    else return false;
}

// FBSample logic
// Read the ids to request from textObjectID and generate a FBRequest
// object for each one.  Add these to the FBRequestConnection and
// then connect to Facebook to get results.  Store the FBRequestConnection
// in case we need to cancel it before it returns.
//
// When a request returns results, call requestComplete:result:error.
//
- (void)sendRequests:(NSString *)fbID {

    // extract the id's for which we will request the profile
    
    // create the connection object
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    // for each fbid in the array, we create a request object to fetch
    // the profile, along with a handler to respond to the results of the request
    
    // create a handler block to handle the results of the request for fbid's profile
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        // output the results of the request
        [self requestCompleted:connection result:result error:error];
    };
    
    // create the request object, using the fbid as the graph path
    // as an alternative the request* static methods of the FBRequest class could
    // be used to fetch common requests, such as /me and /me/friends
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                  graphPath:fbID];
    
    // add the request to the connection object, if more than one request is added
    // the connection object will compose the requests as a batch request; whether or
    // not the request is a batch or a singleton, the handler behavior is the same,
    // allowing the application to be dynamic in regards to whether a single or multiple
    // requests are occuring
    [newConnection addRequest:request completionHandler:handler];
    
    // if there's an outstanding connection, just cancel
    //[self.requestConnection cancel];
    
    // keep track of our connection, and start it
    self.requestConnection = newConnection;
    [newConnection start];
}

// FBSample logic
// Report any results.  Invoked once for each request we make.
- (void)requestCompleted:(FBRequestConnection *)connection
                  result:(id)result
                   error:(NSError *)error {
    // not the completion we were looking for...
    if (self.requestConnection &&
        connection != self.requestConnection) {
        return;
    }
    
    // clean this up, for posterity
    self.requestConnection = nil;
    
    NSString *text;
    if (error) {
        // error contains details about why the request failed
        text = error.localizedDescription;
    } else {
        NSMutableDictionary *dictionary = (NSMutableDictionary *)result;
        //
        //code to make objects from current dictionary
        //
        NSArray *nodes = (NSArray *)[dictionary objectForKey:@"data"];
        for (int i = 0; i < [nodes count]; i++) {
            // create the objects here and fill them up
            FacebookEvent * newEvent = [[FacebookEvent alloc]init];
            NSDictionary * thisEvent = [nodes objectAtIndex:i];
//            NSLog([thisEvent description]);
            newEvent.eventName = [thisEvent valueForKey:@"name"];
            newEvent.eventID = [thisEvent valueForKey:@"id"];
            newEvent.eventLongitude = [[thisEvent objectForKey:@"venue"] valueForKey:@"longitude"];
            newEvent.eventLatitude = [[thisEvent objectForKey:@"venue"] valueForKey:@"latitude"];
            newEvent.eventDescription = [thisEvent valueForKey:@"description"];
            newEvent.eventImageSource = [[thisEvent objectForKey:@"cover"] valueForKey:@"source"];
            newEvent.eventLocation = [thisEvent valueForKey:@"location"];
            NSString *startTempString =  [thisEvent valueForKey:@"start_time"];
            NSString *endTempString = [thisEvent valueForKey:@"end_time"];
            newEvent.eventStartDate = [startTempString substringWithRange:NSMakeRange(0, 10)];
            newEvent.eventEndDate = [endTempString substringWithRange:NSMakeRange(0, 10)];
            if([startTempString length] > 10){
               newEvent.eventStartTime = [startTempString substringWithRange:NSMakeRange(11, 5)];
            }
            else newEvent.eventStartTime = @"No Time Specified";
            if ([endTempString length] > 10) {
                newEvent.eventEndTime = [endTempString substringWithRange:NSMakeRange(11, 5)];
            }
            else newEvent.eventEndTime = @"No Time Specified";
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void){
                NSData *img = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:newEvent.eventImageSource]];
                newEvent.eventImage = [[UIImage alloc]initWithData:img];
                [self.tableView reloadData];
            });
            //            NSLog(@"%@", newEvent.eventName);
            //            NSLog(@"%@", newEvent.eventID);
            //            NSLog(@"%@", newEvent.eventStartTime);
            //            NSLog(@"%@", newEvent.eventEndTime);
            //            NSLog(@"%@", newEvent.eventLongitude);
            //            NSLog(@"%@", newEvent.eventLatitude);
            //            NSLog(@"%@", newEvent.eventDescription);
            //            NSLog(@"%@", newEvent.eventImageSource);
            //            NSLog(@"%@", newEvent.eventLocation);
            [EventsList addObject:newEvent];
        }
        
        //
        // check if there is any more events
        //
        if([dictionary valueForKeyPath:@"paging.next"]){
            NSString * val = (NSString *)[dictionary valueForKeyPath:@"paging.next"];
            NSString * formattedString = [val stringByReplacingOccurrencesOfString:@"https://graph.facebook.com/" withString:@""];
            [self sendRequests:formattedString];
        }
        else{
            //trigger table reload
            NSLog(@"done loading");
            [self triggerRefresh];
        }
    }
}
- (void)triggerRefresh{
    [self.tableView reloadData];
    [loadingIndicator stopAnimating];
    [loadingIndicator removeFromSuperview];
    NSLog(@"done refreshing");
    FacebookEvent *model = (FacebookEvent *)[EventsList objectAtIndex:1];
}

@end