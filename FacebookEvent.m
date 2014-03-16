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

// Selector Description:
// getting an instance of the facebook class so we can make requests.
+(id)getFacebookSingleton{
    static FacebookEvent *sharedFbEventClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFbEventClass = [[self alloc] init];
    });
    return sharedFbEventClass;
}

// Selector Description:
// Sends creates the relevant objects to begin downloading events from facebook
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

// Selector Description:
// Sends requests for the graph paths specified in the array that is passed to the selector
- (void)sendRequests:(NSArray *)fbPages {
    // Create a new facebook connection for the completion handler
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    // create a handler block to handle the results of the request for fbid's profile
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        // output the results of the request
        [self requestCompleted:connection result:result error:error];
    };
    
    // create the request object with the array containing the paths for the graph to get results
    for (int i = 0; i < fbPages.count; i++) {
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:[fbPages objectAtIndex:i]];
        // add the request for the page wanted
        [newConnection addRequest:request completionHandler:handler];
    }
    
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
    if (error) {
        // error contains details about why the request failed
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // first we convert the results into a dictionary so we can pluck the values we require out.
        NSMutableDictionary *dictionary = (NSMutableDictionary *)result;
        NSArray *nodes = (NSArray *)[dictionary objectForKey:@"data"];
        // Now we need to go through every node in the list of events and start creating a list of objects
        for (int i = 0; i < [nodes count]; i++) {
            // create the objects here and fill them up
            static FacebookEvent * newEvent;
            newEvent = [[FacebookEvent alloc]init];
            // grab the event at this index
            NSDictionary * thisEvent = [nodes objectAtIndex:i];
            
            // now we need to find out whether the user of this app is attending the event being downloaded
            newEvent.eventAttending = false;
            NSArray *attending = [[thisEvent objectForKey:@"attending"]objectForKey:@"data"];
            for (int i = 0; i < attending.count; i++) {
                // loop through each event and see if any of the ID's in here match the ID we have from before
                if ([[[attending objectAtIndex:i]valueForKey:@"id"] isEqualToString:userID]) {
                    newEvent.eventAttending = true;
                }
            }
            // get the rest of the properties
            newEvent.eventName = [thisEvent valueForKey:@"name"];
            newEvent.eventID = [thisEvent valueForKey:@"id"];
            newEvent.eventLongitude = [[[thisEvent objectForKey:@"venue"] valueForKey:@"longitude"]floatValue];
            newEvent.eventLatitude = [[[thisEvent objectForKey:@"venue"] valueForKey:@"latitude"]floatValue];
            newEvent.eventDescription = [thisEvent valueForKey:@"description"];
            newEvent.eventImageSource = [[thisEvent objectForKey:@"cover"] valueForKey:@"source"];
            newEvent.eventLocation = [thisEvent valueForKey:@"location"];
            NSString *startTempString =  [thisEvent valueForKey:@"start_time"];
            NSString *endTempString = [thisEvent valueForKey:@"end_time"];
            
            // Because we have more than 2 posible date formats, we have to the date formatter objects in the right way for the date given
            // first we do checks for the event start date
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
            // then we do checks for the event end date
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
            
            // Now we should check if the event is in the past
            
            NSDate *today = [NSDate date];
            bool addToList = true;
            if([today timeIntervalSinceDate:newEvent.eventStartDate] > 0){
                addToList = false;
            }
            
            // check if there are any matching events because events are duplicated across the members facebook page and the public facebook page
            for (FacebookEvent *ev in EventsList) {
                // to find a match, we compare the dates and the description
                NSString *listDate = ev.eventStartDate.description;
                NSString *currentEventDate = newEvent.eventStartDate.description;
                NSString *listName = [ev.eventName stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString *currentEventName = [newEvent.eventName stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                if([listDate isEqualToString:currentEventDate] && [listName isEqualToString:currentEventName]){
                    addToList = false;
                }
            }
            // if the event is corrupt and does not have a date, do not add it to the list
            if(newEvent.eventStartDate == nil)
            {
                addToList = false;
            }
            // if the event has passed all the checks, add it to the list
            if(addToList){
                [EventsList addObject:newEvent];
                if(newEvent.eventAttending) [PinnedList addObject:newEvent];
            }
        }
        
        // now we must download all the image for the event,
        // we do this by adding adding a async url request and when it is done we can notify any views that are waiting for this data to update
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

// Selector Description:
// get a list of all events
+ (NSMutableArray *)getEventsList
{
    return EventsList;
}

// Selector Description:
// get a list of pinned events
+ (NSMutableArray *)getPinnedList
{
    return PinnedList;
}

//singletons tutorial
//http://www.galloway.me.uk/tutorials/singleton-classes/

@end