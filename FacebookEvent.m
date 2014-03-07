//
//  FacebookEvent.m
//  nskv1
//
//  Created by Omorr Faruk on 26/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "FacebookEvent.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookEvent()
- (void)sendRequests:(NSArray *)fbPages;
- (void)requestCompleted:(FBRequestConnection *)connection
                  result:(id)result
                   error:(NSError *)error;
@end

@implementation FacebookEvent
@synthesize eventID;
@synthesize eventName;
@synthesize eventDescription;
@synthesize eventLatitude;
@synthesize eventLocation;
@synthesize eventLongitude;
@synthesize eventImage;
@synthesize eventImageSource;
@synthesize eventStartDate;
@synthesize eventEndDate;
@synthesize dateFormatterStart;
@synthesize dateFormatterEnd;
@synthesize eventAttending;
@synthesize requestConnection = _requestConnection;
@synthesize userID;
static NSMutableArray* EventsList = nil;
static NSMutableArray* PinnedList = nil;

const NSString *PUBLIC_FACEBOOK_EVENTS = @"303838247034/events?fields=attending,name,start_time,cover,description,end_time,location,venue&before=NTQzMTUzNjA5MTAyMjQ3&limit=25";
const NSString *PRIVATE_FACEBOOK_EVENTS = @"457577170988971/events?fields=attending,name,start_time,cover,description,end_time,location,venue";

+(id)getFacebookSingleton{
    static FacebookEvent *sharedFbEventClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFbEventClass = [[self alloc] init];
    });
    return sharedFbEventClass;
}

- (void)downloadEvents{
    EventsList = [[NSMutableArray alloc]init];
    PinnedList = [[NSMutableArray alloc]init];
    NSArray *events = [[NSArray alloc]initWithObjects:PUBLIC_FACEBOOK_EVENTS,
                       PRIVATE_FACEBOOK_EVENTS, nil];
    [self sendRequests:events];
}

- (void)dealloc {
    [_requestConnection cancel];
}
// FBSample logic
// Read the ids to request from textObjectID and generate a FBRequest
// object for each one.  Add these to the FBRequestConnection and
// then connect to Facebook to get results.  Store the FBRequestConnection
// in case we need to cancel it before it returns.
//
// When a request returns results, call requestComplete:result:error.
//
- (void)sendRequests:(NSArray *)fbPages {
    
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
    for (int i = 0; i < fbPages.count; i++) {
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                      graphPath:[fbPages objectAtIndex:i]];
        // add the request to the connection object, if more than one request is added
        // the connection object will compose the requests as a batch request; whether or
        // not the request is a batch or a singleton, the handler behavior is the same,
        // allowing the application to be dynamic in regards to whether a single or multiple
        // requests are occuring
        [newConnection addRequest:request completionHandler:handler];
        
        
        
    }
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
            
            NSDate *today = [NSDate date];
            bool addToList = true;
            if([today timeIntervalSinceDate:newEvent.eventStartDate] > 0){
                addToList = false;
            }
            for (FacebookEvent *ev in EventsList) {
                NSString *listDate = ev.eventStartDate.description;
                NSString *currentEventDate = newEvent.eventStartDate.description;
                NSString *listName = [ev.eventName stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *currentEventName = [newEvent.eventName stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                if([listDate isEqualToString:currentEventDate] && [listName isEqualToString:currentEventName]){
                    NSLog(@"Match found at event: %@ <-->: %@", ev.eventName, newEvent.eventName);
                    addToList = false;
                }
            }
            if(newEvent.eventStartDate == nil)
            {
                addToList = false;
            }
            if(addToList){
                [EventsList addObject:newEvent];
                if(newEvent.eventAttending) [PinnedList addObject:newEvent];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        }
        //
        // check if there is any more events
        //
        //trigger table reload
        for (int i = 0; i < (int)[EventsList count]; i++) {
            
            FacebookEvent *ev = [EventsList objectAtIndex:i];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void){
                NSData *img = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:ev.eventImageSource]];
                ev.eventImage = [[UIImage alloc]initWithData:img];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshEventList" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPinnedList" object:self];
            });
        }
    }
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}

+ (NSMutableArray *)getEventsList
{
    return EventsList;
}
+ (NSMutableArray *)getPinnedList
{
    return PinnedList;
}

//singletons tutorial
//http://www.galloway.me.uk/tutorials/singleton-classes/

@end