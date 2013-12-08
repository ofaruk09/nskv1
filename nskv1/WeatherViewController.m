//
//  WeatherViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 05/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "WeatherViewController.h"

@interface WeatherViewController ()

@end

@implementation WeatherViewController
@synthesize fbEvent;
@synthesize WeatherLabelOutput;
@synthesize timeToEvent;
@synthesize weatherEvent;
NSString *baseWeatherAddress = @"http://datapoint.metoffice.gov.uk/public/data/";
NSString *apiKey = @"key=9a359b8e-179a-4164-8e29-dcfab50bed8a";
NSString *allLocations = @"val/wxfcs/all/json/sitelist";
NSString *baseStation = @"val/wxfcs/all/json/";
const NSArray *weatherTypes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    FacebookEvent *temp = [[FacebookEvent alloc]init];
    temp.eventLongitude = 1.2724;
    temp.eventLatitude = 51.9271;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *startDate = [format dateFromString:@"2013-12-12T21:30:00+0000"];
    temp.eventStartDate = startDate;
    temp.dateFormatterStart = format;
    fbEvent = temp;
    timeToEvent = 4.96;
    weatherTypes = [[NSArray alloc]initWithObjects: @"Clear Night",
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
    
    //Do some checks to see if 5 days from event
    //Do some checks if time exists in event information
    
    [self determineVenueLocation];
	// Do any additional setup after loading the view.
    // When sending a request, to get ALL the data including gust, we must provide the city!
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:true];
}
- (void) determineVenueLocation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    if(fbEvent.eventLongitude != 0 && fbEvent.eventLatitude != 0){
        // we have the long/lat we can find the closest base station
        CLLocation *longLat = [[CLLocation alloc]initWithLatitude:fbEvent.eventLatitude longitude:fbEvent.eventLongitude];
        [self downloadSiteList:longLat];
    }
    else if (fbEvent.eventLocation != nil){
        // we MIGHT be able to use geocoders
        [geocoder geocodeAddressString:fbEvent.eventLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if(error){
                NSLog(@"ERROR");
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Location Found" message:@"No Location was found to display weather statistics" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alert show];
            }
            else{
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                [self downloadSiteList:[placemark location]];
            }
        }];
    }
    else{
        // no chance
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Location Found" message:@"No Location was found to display weather statistics" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void) downloadSiteList:(CLLocation *)thisLocation
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
             NSLog(@"Data Recieved");
             weatherData = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error: &error];
             // HANDLE DATA HERE
             //NSLog([weatherData description]);
             [self findWeatherDataForTimeAndPlace:thisLocation locationList:weatherData];
         }
         else if([data length]  ==  0 && error == nil){
             NSLog(@"Nothing came through");
         }
         if(error != nil) {
             NSLog(@"ERROR = %@", error);
         }
     }];
}

- (void) findWeatherDataForTimeAndPlace:(CLLocation*)myLocation locationList:(NSDictionary*)locationList;
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
    //WE NOW HAVE THE CLOSEST STATION ID;
    //WE CAN REQUEST THE WEATHER INFORMATION FOR THAT PARTICULAR STATION
    NSString *eventTimeAndDate = [fbEvent.dateFormatterStart stringFromDate:fbEvent.eventStartDate];
    eventTimeAndDate = [[eventTimeAndDate substringWithRange:NSMakeRange(0, 19)] stringByAppendingString:@"Z"];
    NSLog(eventTimeAndDate);
    NSString * weatherSite = [[NSString alloc]initWithFormat:@"%@%@%@?time=%@&res=3hourly&%@",baseWeatherAddress,baseStation,closestStationID,eventTimeAndDate,apiKey];
    NSLog(weatherSite);
    __block NSDictionary * weatherData;
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
             weatherData = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error: &error];
             //NSLog([weatherData description]);
             [self createWeatherObject:weatherData];
         }
         else if([data length]  ==  0 && error == nil){
             NSLog(@"Nothing came through");
         }
         if(error != nil) {
             NSLog(@"ERROR = %@", error);
         }
     }];
}

- (void) createWeatherObject:(NSDictionary *)weather
{
    //NSLog([weather description]);
    NSDictionary *weatherContent = [[[[[weather objectForKey:@"SiteRep"] objectForKey:@"DV"]objectForKey:@"Location"]objectForKey:@"Period"]objectForKey:@"Rep"];
    NSLog([weatherContent description]);
    weatherEvent.eventTemperature = [weatherContent valueForKey:@"T"];
    weatherEvent.eventFeelsLikeTemperature = [weatherContent valueForKey:@"F"];
    weatherEvent.eventVisibility = [weatherContent valueForKey:@"V"];
    NSUInteger wTemp = [[weatherTypes valueForKey:@"W"] integerValue];
    weatherEvent.eventWeatherType = [weatherTypes objectAtIndex:wTemp];
    weatherEvent.eventWeatherTypeValue = [NSString stringWithFormat:@"%i",wTemp];
    weatherEvent.eventWindDirection = [weatherContent valueForKey:@"D"];
    weatherEvent.eventWindGusting = [weatherContent valueForKey:@"G"];
    weatherEvent.eventWindSpeed = [weatherContent valueForKey:@"S"];
    
    //Remove Spinner Here
    //Start Building View
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// reference iOS 6 cookbook chapter 9.2
// reference serialize JSON response to dictionary: https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40010946-CH1-SW2
// using blocks to take stuff out the async bit of the code: https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html
@end
