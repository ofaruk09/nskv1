//
//  WeatherEvent.m
//  nskv1
//
//  Created by Omorr Faruk on 08/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "WeatherEvent.h"

@interface WeatherEvent()
- (void) findWeatherDataForTimeAndPlace:(CLLocation*)myLocation
                           locationList:(NSDictionary*)locationList
                       andFacebookEvent:(FacebookEvent*)fbEvent;
- (void) createWeatherObject:(NSDictionary *)weather;
@end

@implementation WeatherEvent
@synthesize eventFeelsLikeTemperature;
@synthesize eventTemperature;
@synthesize eventVisibility;
@synthesize eventWeatherType;
@synthesize eventWeatherTypeValue;
@synthesize eventWindDirection;
@synthesize eventWindGusting;
@synthesize eventWindSpeed;
@synthesize baseStation;
@synthesize eventWeatherImage;
@synthesize userMessage;
@synthesize percentageOfMaxWindSpeedWind;
@synthesize percentageOfMaxWindSpeedGust;
NSString *baseWeatherAddress = @"http://datapoint.metoffice.gov.uk/public/data/";
NSString *apiKey = @"key=9a359b8e-179a-4164-8e29-dcfab50bed8a";
NSString *allLocations = @"val/wxfcs/all/json/sitelist";
NSString *dataFormat = @"val/wxfcs/all/json/";
float const MAX_WIND_SPEED = 50;
int const WEATHER_TOTAL_STEPS = 4;
int steps = WEATHER_TOTAL_STEPS;

+(NSArray*) weatherTypes
{
    NSArray *weatherTypes = [[NSArray alloc]initWithObjects: @"Clear Night",
                @"Sunny Day",
                @"Partly Cloudy (Night)",
                @"Partly Cloudy (Day)",
                @"Not Used",
                @"Mist",
                @"Fog",
                @"Cloudy",
                @"Overcast",
                @"Light Rain Shower (Night)",
                @"Light Rain Shower (Day)",
                @"Drizzle",
                @"Light Rain",
                @"Heavy Rain Shower (Night)",
                @"Heavy Rain Shower (Day)",
                @"Heavy Rain",
                @"Sleet Shower (Night)",
                @"Sleet Shower (Day)",
                @"Sleet",
                @"Hail Shower (Night)",
                @"Hail Shower (Day)",
                @"Hail",
                @"Light Snow Shower (Night)",
                @"Light Snow Shower (Day)",
                @"Light Snow",
                @"Heavy Snow Shower (Night)",
                @"Heavy Snow Shower (Day)",
                @"Heavy Snow",
                @"Thunder Shower (Night)",
                @"Thunder Shower (Day)",
                @"Thunder", nil];
    return weatherTypes;
}

- (id)initWithLocation:(CLLocation *)thisLocation
      forFacebookEvent:(FacebookEvent *)fbEvent
{
    if ( self = [super init] ) {
        [self downloadWeatherDataWithLocation:thisLocation forFacebookEvent:fbEvent];
        return self;
    } else
        return nil;
}

- (void) downloadWeatherDataWithLocation:(CLLocation *)thisLocation
                        forFacebookEvent:(FacebookEvent *)fbEvent
{
    NSString * siteList = [[NSString alloc]initWithFormat:@"%@%@?%@",baseWeatherAddress,allLocations,apiKey];
    
    __block NSDictionary * weatherData;
    NSURL *url = [NSURL URLWithString:siteList];
    NSURLRequest * request = [NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                          timeoutInterval:30.0f];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest: request
     queue:queue
     completionHandler:^(NSURLResponse * response,
                         NSData * data,
                         NSError * error) {
         if([data length] > 0 && error == nil){
             weatherData = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error: &error];
             // HANDLE DATA HERE
             
             [self notifyProgressForWeather];
             [self findWeatherDataForTimeAndPlace:thisLocation locationList:weatherData andFacebookEvent:fbEvent];
         }
         else if([data length]  ==  0 && error == nil){
             NSLog(@"Nothing came through");
         }
         if(error != nil) {
             [self notifyForError:@"MetOffice is currently unavailable, please try again later1"];
         }
     }];
}
- (void) findWeatherDataForTimeAndPlace:(CLLocation*)myLocation
                           locationList:(NSDictionary*)locationList
                       andFacebookEvent:(FacebookEvent*)fbEvent
{
    NSString *closestStationID;
    NSArray *dict = (NSArray*)[[locationList objectForKey:@"Locations"] objectForKey:@"Location"];
    double savedDistance = DBL_MAX;
    for (int i = 0; i < [dict count]; i++) {
        NSDictionary *dictStation = [dict objectAtIndex:i];
        CLLocation *currentStation = [[CLLocation alloc]initWithLatitude:[[dictStation valueForKey:@"latitude"] doubleValue] longitude:[[dictStation valueForKey:@"longitude"] doubleValue]];
        //NSLog(@"%f",savedDistance);
        double currentDistance = [myLocation distanceFromLocation:currentStation];
        if(savedDistance > currentDistance){
            savedDistance = currentDistance;
            closestStationID = [dictStation valueForKey:@"id"];
        }
    }
    [self notifyProgressForWeather];
    //WE NOW HAVE THE CLOSEST STATION ID;
    //WE CAN REQUEST THE WEATHER INFORMATION FOR THAT PARTICULAR STATION
    NSString *eventTimeAndDate = [fbEvent.dateFormatterStart stringFromDate:fbEvent.eventStartDate];
    eventTimeAndDate = [[eventTimeAndDate substringWithRange:NSMakeRange(0, 19)] stringByAppendingString:@"Z"];
    NSString * weatherSite = [[NSString alloc]initWithFormat:@"%@%@%@?time=%@&res=3hourly&%@",baseWeatherAddress,dataFormat,closestStationID,eventTimeAndDate,apiKey];
    NSURL *url = [NSURL URLWithString:weatherSite];
    NSURLRequest * request = [NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                          timeoutInterval:30.0f];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest: request
     queue:queue
     completionHandler:^(NSURLResponse * response,
                         NSData * data,
                         NSError * error) {
         if([data length] > 0 && error == nil){
             NSLog(@"Data Recieved");
             NSDictionary * weatherData = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error: &error];
             [self notifyProgressForWeather];
             [self createWeatherObject:weatherData];
         }
         else if([data length]  ==  0 && error == nil){
             NSLog(@"Nothing came through");
         }
         if(error != nil) {
             [self notifyForError:@"MetOffice is currently unavailable, please try again later2"];
         }
     }];
}
- (void) createWeatherObject:(NSDictionary *)weather
{
    NSDictionary *locationData = [[[weather objectForKey:@"SiteRep"] objectForKey:@"DV"]objectForKey:@"Location"];
    baseStation = [locationData valueForKey:@"name"];
    NSDictionary *weatherContent = [[[[[weather objectForKey:@"SiteRep"] objectForKey:@"DV"]objectForKey:@"Location"]objectForKey:@"Period"]objectForKey:@"Rep"];
    eventTemperature = [weatherContent valueForKey:@"T"];
    eventFeelsLikeTemperature = [weatherContent valueForKey:@"F"];
    eventVisibility = [weatherContent valueForKey:@"V"];
    //NSLog([weatherContent])
    NSUInteger wTemp = [[weatherContent valueForKey:@"W"] integerValue];
    eventWeatherType = [[WeatherEvent weatherTypes] objectAtIndex:wTemp];
    eventWeatherTypeValue = [NSString stringWithFormat:@"%i",wTemp];
    eventWindDirection = [weatherContent valueForKey:@"D"];
    eventWindGusting = [weatherContent valueForKey:@"G"];
    eventWindSpeed = [weatherContent valueForKey:@"S"];
    
    //SOLVING PERCENTAGE OF MAX WIND SPEED
    
    if ([eventWindSpeed floatValue] <= MAX_WIND_SPEED) {
        percentageOfMaxWindSpeedWind= ([eventWindSpeed floatValue]/MAX_WIND_SPEED)*100;
    }
    else{
        percentageOfMaxWindSpeedWind = 100;
    }
    if([eventWindGusting floatValue] <= MAX_WIND_SPEED){
        percentageOfMaxWindSpeedGust= ([eventWindGusting floatValue]/MAX_WIND_SPEED)*100;
    }
    else{
        percentageOfMaxWindSpeedGust = 100;
    }
    
    //CONDITIONING MESSAGE
    
    if([eventWindGusting floatValue] > MAX_WIND_SPEED)
    {
        userMessage = @"Wind gust exceeds 20mph, contact the event supervisor for more information";
    }
    else {
        userMessage = @"It seems ok to go kayaking in these conditions";
    }
    NSLog(@"%@",[WeatherEvent weatherTypes][0]);
    
    [self notifyProgressForWeather];
}

-(void)notifyProgressForWeather
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyProgressForWeather" object:self];
}
-(void)notifyForError:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"errorDownloadingData" object:message];
}

@end
