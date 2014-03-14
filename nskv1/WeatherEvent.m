//
//  WeatherEvent.m
//  nskv1
//
//  Created by Omorr Faruk on 08/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "WeatherEvent.h"

@interface WeatherEvent()
- (void) findWeatherDataForPlace:(CLLocation*)myLocation
                    locationList:(NSDictionary*)locationList
                andFacebookEvent:(FacebookEvent*)fbEvent;
- (void) createWeatherObject:(NSDictionary *)weather
           withFacebookEvent:(FacebookEvent *)fbEvent;
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
float const MAX_WIND_SPEED = 15;
int const WEATHER_TOTAL_STEPS = 4;
int steps = WEATHER_TOTAL_STEPS;
// this const is used for the conversion of mph to kt
const float mpHtokt = 0.868976;

+(NSArray*) weatherTypes
{
    // this array contains all the weather definitions returned by the weather
    // service
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
                                              cachePolicy:NSURLCacheStorageAllowed
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
             [self findWeatherDataForPlace:thisLocation locationList:weatherData andFacebookEvent:fbEvent];
         }
         else if([data length]  ==  0 && error == nil){
             [self notifyForError:@"Cannot access the internet"];
         }
         if(error != nil) {
             [self notifyForError:@"MetOffice is currently unavailable, please try again later"];
         }
     }];
}
- (void) findWeatherDataForPlace:(CLLocation*)myLocation
                           locationList:(NSDictionary*)locationList
                       andFacebookEvent:(FacebookEvent*)fbEvent
{
    //NSLog([locationList description]);
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
    NSString * weatherSite = [[NSString alloc]initWithFormat:@"%@%@%@?res=3hourly&%@",baseWeatherAddress,dataFormat,closestStationID,apiKey];
    NSURL *url = [NSURL URLWithString:weatherSite];
    NSURLRequest * request = [NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLCacheStorageNotAllowed
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
             [self createWeatherObject:weatherData withFacebookEvent:fbEvent];
         }
         else if([data length]  ==  0 && error == nil){
             [self notifyForError:@"Cannot access the internet"];
         }
         if(error != nil) {
             [self notifyForError:@"MetOffice is currently unavailable, please try again later"];
         }
     }];
}
- (void) createWeatherObject:(NSDictionary *)weather
           withFacebookEvent:(FacebookEvent *)fbEvent
{
    NSDictionary *locationData = [[[weather objectForKey:@"SiteRep"] objectForKey:@"DV"]objectForKey:@"Location"];
    
    baseStation = [locationData valueForKey:@"name"];
    NSArray *weekForecast = [[[[weather objectForKey:@"SiteRep"]objectForKey:@"DV"]objectForKey:@"Location"] objectForKey:@"Period"];
    NSDictionary *weatherContent = [self findDataForDayUsingPeriods:weekForecast andDate:fbEvent.eventStartDate];
    
    if(weatherContent == nil)
    {
        [self notifyForError:@"Weather information is currently unavailable for this location, please try again later"];
    }

    //Pull all the values here
    eventTemperature = [weatherContent valueForKey:@"T"];
    eventFeelsLikeTemperature = [weatherContent valueForKey:@"F"];
    NSUInteger wTemp = [[weatherContent valueForKey:@"W"] integerValue];
    eventWeatherType = [[WeatherEvent weatherTypes] objectAtIndex:wTemp];
    eventWeatherTypeValue = [NSString stringWithFormat:@"%lu",(unsigned long)wTemp];
    eventWindDirection = [weatherContent valueForKey:@"D"];
    
    //Conversion of mph to kt
    
    eventWindGusting = [weatherContent valueForKey:@"G"];
    eventWindGusting = [NSString stringWithFormat:@"%.01f",eventWindGusting.floatValue*mpHtokt];
    
    eventWindSpeed = [weatherContent valueForKey:@"S"];
    eventWindSpeed = [NSString stringWithFormat:@"%.01f",eventWindSpeed.floatValue*mpHtokt];
    
    //converting visibility label into something human readable
    
    eventVisibility = [weatherContent valueForKey:@"V"];
    if([eventVisibility isEqualToString:@"UN"]) eventVisibility = @"Unknown";
    else if([eventVisibility isEqualToString:@"VP"]) eventVisibility = @"Very Poor";
    else if([eventVisibility isEqualToString:@"PO"]) eventVisibility = @"Poor";
    else if([eventVisibility isEqualToString:@"MO"]) eventVisibility = @"Moderate";
    else if([eventVisibility isEqualToString:@"GO"]) eventVisibility = @"Good";
    else if([eventVisibility isEqualToString:@"VG"]) eventVisibility = @"Very Good";
    else if([eventVisibility isEqualToString:@"EX"]) eventVisibility = @"Excellent";
    
    //SOLVING PERCENTAGE OF MAX WIND SPEED
    // we need to calculate the percentage of the max wind speed this events wind speed is.
    
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
    // create the right message for the user to display in the table
    if([eventWindGusting floatValue] > MAX_WIND_SPEED)
    {
        userMessage = @"Wind gust exceeds general guideline of 15kt";
    }
    else {
        userMessage = @"No message";
    }
    [self notifyProgressForWeather];
}

-(NSDictionary *)findDataForDayUsingPeriods:(NSArray *)listOfPeriods
                                    andDate:(NSDate *)targetDate;
{
    //first we need to find the right day of the week so must match target date from list of periods
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit) fromDate:targetDate];
    NSString *jsonDate = [NSString stringWithFormat:@"%04li-%02li-%02liZ",(long)components.year,(long)components.month,(long)components.day];
    //now perform the matching
    NSArray *targetWeek = nil;
    for (NSDictionary *dict in listOfPeriods) {
        NSString *value = [dict valueForKey:@"value"];
        if ([value isEqualToString:jsonDate]) {
            targetWeek = [dict objectForKey:@"Rep"];
        }
    }
    //Now we must find the matching hour
    long hour = [components hour];
    //round up to the hour to the nearest multiple of 3 because forecasts are 3 hourly starting at 0 then divide by 3 to get the index of the 3-hourly forecast we want
    hour = (long)ceil(hour / 3);
    for (NSDictionary * dict in targetWeek) {
        long weatherHour = (long)[[dict valueForKey:@"$"] integerValue]/180;
        if (weatherHour == hour) {
            NSDictionary *hourForecast = dict;
            return hourForecast;
        }
    };
    return nil;
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
