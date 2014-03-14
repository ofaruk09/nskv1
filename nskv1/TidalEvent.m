//
//  TidalEvent.m
//  nskv1
//
//  Created by Omorr Faruk on 12/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import "TidalEvent.h"
@interface TidalEvent()
- (void) findTideDataForPlace:(CLLocation*)myLocation
                 locationList:(NSDictionary*)locationList
             andFacebookEvent:(FacebookEvent*)fbEvent;
- (void) createTidesObject:(NSDictionary *)tides
          andFacebookEvent:(FacebookEvent *)fbEvent;
@end
@implementation TidalEvent
@synthesize WaterMode;
@synthesize height;
@synthesize time;
@synthesize percentageOfMaxTideHeight;
@synthesize baseStation;
static NSMutableArray *TidesData;
int const TIDE_TOTAL_STEPS = 4;

- (id)initWithLocation:(CLLocation *)thisLocation
      forFacebookEvent:(FacebookEvent *)fbEvent
{
    // custom init which takes a facebook event and location
    if ( self = [super init] ) {
        TidesData = [[NSMutableArray alloc]init];
        [self downloadTideDataWithLocation:thisLocation forFacebookEvent:fbEvent];
        return self;
    } else
        return nil;
}

// selector description:
// gets a list of ports from the tides service.
- (void) downloadTideDataWithLocation:(CLLocation *)thisLocation
                     forFacebookEvent:(FacebookEvent *)fbEvent
{
    // creates the request here
    NSString *address = @"http://somecoolname.com/tideWebService/api/port";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    
    [request setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    // sends the request
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError)
        {
            // send an error message to the user
            [self notifyForError:@"Cannot access the internet"];
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error: &connectionError];
        // pass the request to the next selector
        // and notify for progress
        [self notifyProgressForTides];
        [self findTideDataForPlace:thisLocation locationList:dict andFacebookEvent:fbEvent];
    }];
}
// selector description:
// this selector finds the closest port to the location passed to the selector,
// then requests the information for that port
- (void) findTideDataForPlace:(CLLocation*)myLocation
                        locationList:(NSDictionary*)locationList
                    andFacebookEvent:(FacebookEvent*)fbEvent
{
    // we need to keep the closest station id which is used to request from the tide service
    NSString *closestStationID;
    NSArray *dict = (NSArray*)locationList;
    double savedDistance = DBL_MAX;
    // loops through every entry in the list of ports, if it finds a closer one to the last saved id and replaces it.
    for (int i = 0; i < [dict count]; i++) {
        NSDictionary *dictStation = [dict objectAtIndex:i];
        CLLocation *currentStation = [[CLLocation alloc]initWithLatitude:[[dictStation valueForKey:@"Longitude"] doubleValue] longitude:[[dictStation valueForKey:@"Latitude"] doubleValue]];
        double currentDistance = [myLocation distanceFromLocation:currentStation];
        if(savedDistance > currentDistance){
            savedDistance = currentDistance;
            closestStationID = [dictStation valueForKey:@"portID"];;
            baseStation = [dictStation valueForKey:@"portName"];
        }
    }
    // notify for progress
    [self notifyProgressForTides];
    
    // set up the request for the information for the port from the tides service
    NSString *address = @"http://somecoolname.com/tideWebService/api/Values";
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              closestStationID, @"portID",
                              nil];
    
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    // send the request
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError)
        {
            [self notifyForError:@"Cannot access the internet"];
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error: &connectionError];
        // send progress update
        [self notifyProgressForTides];
        //start building the tide object list
        [self createTidesObject:dict andFacebookEvent:fbEvent];
    }];
}

// selector description:
// this selector gets the response from the tide service about a given port
// and turns them into objects for the application
- (void) createTidesObject:(NSDictionary *)tides
          andFacebookEvent:(FacebookEvent *)fbEvent
{
    // we need to determine the max tide height in the list of tide items we recieved for the meters in the view to display correctly
    float maxTempHeight = 0;
    // find the event date in the format the tide service provides
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:fbEvent.eventStartDate];
    NSString *eventsDate = [NSString stringWithFormat:@"%li/%li/%li",(long)comp.month,(long)comp.day,(long)comp.year];
    
    // the service gives data for 6 days, we only need one of those days
    NSDictionary *nodes = [tides objectForKey:@"portForecast"];
    for (NSDictionary *subNodes in nodes) {
        // gets the correct day from the list of days
        if([[subNodes objectForKey:@"Date"] isEqualToString:eventsDate]){
            NSArray *data = [subNodes objectForKey:@"EventData"];
            for (NSDictionary *values in data) {
                // creates the tide events for that day
                TidalEvent *tEvent = [[TidalEvent alloc]init];
                tEvent.WaterMode = [values valueForKey:@"WaterMode"];
                tEvent.time = [values valueForKey:@"Time"];
                tEvent.height = [values valueForKey:@"Height"];
                [TidesData addObject:tEvent];
                // we need this to get the highest tide
                if([tEvent.height floatValue]>maxTempHeight){
                    maxTempHeight = [tEvent.height floatValue];
                }
            }
        }
    }
    // we use the highest tide to create the percentages of the meters they will take
    for (TidalEvent *tide in TidesData) {
        tide.percentageOfMaxTideHeight = [tide.height floatValue]/maxTempHeight *100;
    }
    // last notify, downloading tide data complete.
    [self notifyProgressForTides];
}
+ (NSMutableArray *) getTidesData
{
    return TidesData;
}
-(void)notifyProgressForTides
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyProgressForTides" object:self];
}
-(void)notifyForError:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"errorDownloadingData" object:message];
}
@end
