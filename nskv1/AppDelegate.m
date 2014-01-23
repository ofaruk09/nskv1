//
//  AppDelegate.m
//  nskv1
//
//  Created by Omorr Faruk on 25/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize requestConnection = _requestConnection;
@synthesize userID;
static NSMutableArray* EventsList = nil;
static NSMutableArray* PinnedList = nil;
int LoadedCount = 0;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
    
}
+ (NSMutableArray *)getEventsList
{
    return EventsList;
}
+ (NSMutableArray *)getPinnedList
{
    return PinnedList;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    PinnedList = [[NSMutableArray alloc]init];
    EventsList = [[NSMutableArray alloc]init];
    [self openFacebookSession];
    NSLog(@"becameActive");
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
- (void)test
{
    NSLog(@"test method");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)downloadEvents{
    [self sendRequests:@"303838247034/events?fields=attending,name,start_time,cover,description,end_time,location,venue&before=NTQzMTUzNjA5MTAyMjQ3&limit=25"];
    NSLog(@"starting new login");
}

- (void)dealloc {
    [_requestConnection cancel];
}

-(void)openFacebookSession {
    NSLog(@"Hi");
    NSArray *perm = [[NSArray alloc]initWithObjects:@"rsvp_event", nil];
    [FBSession openActiveSessionWithPublishPermissions:perm defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
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
        }
        if (FB_ISSESSIONOPENWITHSTATE(status)) {
            // send our requests if we successfully logged in
            NSLog(@"permission granted");
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSMutableDictionary *dictionary = (NSMutableDictionary *)result;
                NSLog([dictionary description]);
                userID = [dictionary objectForKey:@"id"];
                [self downloadEvents];
            }];
        }
    }];
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
        //NSLog([dictionary description]);
        //code to make objects from current dictionary
        //
        NSArray *nodes = (NSArray *)[dictionary objectForKey:@"data"];
        for (int i = 0; i < [nodes count]; i++) {
            // create the objects here and fill them up
            static FacebookEvent * newEvent;
            newEvent = [[FacebookEvent alloc]init];
            NSDictionary * thisEvent = [nodes objectAtIndex:i];
            newEvent.eventAttending = false;
            NSArray *attending = [[thisEvent objectForKey:@"attending"]objectForKey:@"data"];
            for (int i = 0; i < attending.count; i++) {
                if ([[[attending objectAtIndex:i]valueForKey:@"id"] isEqualToString:userID]) {
                    newEvent.eventAttending = true;
                }
            }
            //            NSLog([thisEvent description]);
            newEvent.eventName = [thisEvent valueForKey:@"name"];
            newEvent.eventID = [thisEvent valueForKey:@"id"];
            newEvent.eventLongitude = [[[thisEvent objectForKey:@"venue"] valueForKey:@"longitude"]floatValue];
            newEvent.eventLatitude = [[[thisEvent objectForKey:@"venue"] valueForKey:@"latitude"]floatValue];
            newEvent.eventDescription = [thisEvent valueForKey:@"description"];
            newEvent.eventImageSource = [[thisEvent objectForKey:@"cover"] valueForKey:@"source"];
            newEvent.eventLocation = [thisEvent valueForKey:@"location"];
            NSString *startTempString =  [thisEvent valueForKey:@"start_time"];
            NSString *endTempString = [thisEvent valueForKey:@"end_time"];
            if([startTempString length] > 10){
                NSDateFormatter *format = [[NSDateFormatter alloc]init];
                [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
                NSDate *startDate = [format dateFromString:startTempString];
                newEvent.eventStartDate = startDate;
                newEvent.dateFormatterStart = format;
            }
            else{
                NSDateFormatter *format = [[NSDateFormatter alloc]init];
                [format setDateFormat:@"yyyy-MM-dd"];
                NSDate *startDate = [format dateFromString:startTempString];
                newEvent.eventStartDate = startDate;
                newEvent.dateFormatterStart = format;
            }
            if ([endTempString length] > 10) {
                NSDateFormatter *format = [[NSDateFormatter alloc]init];
                [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
                NSDate *startDate = [format dateFromString:endTempString];
                newEvent.eventEndDate = startDate;
                newEvent.dateFormatterEnd = format;
            }
            else{
                if(endTempString != nil){
                    NSDateFormatter *format = [[NSDateFormatter alloc]init];
                    [format setDateFormat:@"yyyy-MM-dd"];
                    NSDate *startDate = [format dateFromString:endTempString];
                    newEvent.eventEndDate = startDate;
                    newEvent.dateFormatterEnd = format;
                }
            }
            
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
            if(newEvent.eventAttending) [PinnedList addObject:newEvent];
        }
        
        //
        // check if there is any more events
        //
        //trigger table reload
        NSLog(@"done loading");
        NSLog(@"Event Count: %i",[EventsList count]);
        for (int i = 0; i < (int)[EventsList count]; i++) {
            FacebookEvent *ev = [EventsList objectAtIndex:i];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void){
                NSData *img = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:ev.eventImageSource]];
                ev.eventImage = [[UIImage alloc]initWithData:img];
                LoadedCount++;
                NSLog(@"%i - %i",[EventsList count], LoadedCount);
                if([EventsList count] == LoadedCount){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshEventList" object:self];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPinnedList" object:self];
                }
            });
            
        }
    }
}
-(void)testing
{
    NSLog(@"test works");
}

//singletons tutorial
//http://www.galloway.me.uk/tutorials/singleton-classes/
@end
