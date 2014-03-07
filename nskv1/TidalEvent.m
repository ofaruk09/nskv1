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
    if ( self = [super init] ) {
        TidesData = [[NSMutableArray alloc]init];
        [self downloadTideDataWithLocation:thisLocation forFacebookEvent:fbEvent];
        return self;
    } else
        return nil;
}
- (void) downloadTideDataWithLocation:(CLLocation *)thisLocation
                     forFacebookEvent:(FacebookEvent *)fbEvent
{
    NSString *address = @"http://somecoolname.com/tideWebService/api/port";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    
    [request setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError)
        {
            [self notifyForError:@"Cannot access the internet"];
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error: &connectionError];
        [self notifyProgressForTides];
        [self findTideDataForPlace:thisLocation locationList:dict andFacebookEvent:fbEvent];
    }];
}
- (void) findTideDataForPlace:(CLLocation*)myLocation
                        locationList:(NSDictionary*)locationList
                    andFacebookEvent:(FacebookEvent*)fbEvent
{
    NSString *closestStationID;
    NSArray *dict = (NSArray*)locationList;
    double savedDistance = DBL_MAX;
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
    [self notifyProgressForTides];
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
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError)
        {
            [self notifyForError:@"Cannot access the internet"];
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error: &connectionError];
        [self notifyProgressForTides];
        [self createTidesObject:dict andFacebookEvent:fbEvent];
    }];
}

- (void) createTidesObject:(NSDictionary *)tides
          andFacebookEvent:(FacebookEvent *)fbEvent
{
    float maxTempHeight = 0;
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:fbEvent.eventStartDate];
    NSString *eventsDate = [NSString stringWithFormat:@"%i/%i/%i",comp.month,comp.day,comp.year];
    NSDictionary *nodes = [tides objectForKey:@"portForecast"];
    for (NSDictionary *subNodes in nodes) {
        //NSLog([subNodes description]);
        if([[subNodes objectForKey:@"Date"] isEqualToString:eventsDate]){
            NSArray *data = [subNodes objectForKey:@"EventData"];
            for (NSDictionary *values in data) {
                TidalEvent *tEvent = [[TidalEvent alloc]init];
                tEvent.WaterMode = [values valueForKey:@"WaterMode"];
                tEvent.time = [values valueForKey:@"Time"];
                tEvent.height = [values valueForKey:@"Height"];
                [TidesData addObject:tEvent];
                if([tEvent.height floatValue]>maxTempHeight){
                    maxTempHeight = [tEvent.height floatValue];
                }
            }
        }
    }
    for (TidalEvent *tide in TidesData) {
        tide.percentageOfMaxTideHeight = [tide.height floatValue]/maxTempHeight *100;
    }
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
