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
@synthesize longitude;
@synthesize latitude;
@synthesize WeatherLabelOutput;
@synthesize location;
NSString *baseWeatherAddress = @"http://datapoint.metoffice.gov.uk/public/data/";
NSString *apiKey = @"?key=9a359b8e-179a-4164-8e29-dcfab50bed8a";
NSString *allLocations = @"val/wxfcs/all/json/sitelist";

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
    if(longitude != 0 && latitude != 0){
        // we have the long/lat we can find the closest base station
        CLLocation *longLat = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [self downloadSiteList:longLat];
    }
    else if (location != nil){
        // we MIGHT be able to use geocoders
        [geocoder geocodeAddressString:location completionHandler:^(NSArray *placemarks, NSError *error) {
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
    NSString * siteList = [[NSString alloc]initWithFormat:@"%@%@%@",baseWeatherAddress,allLocations,apiKey];
    NSLog(siteList);
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
             [self findClosestBaseStation:thisLocation: weatherData];
         }
         else if([data length]  ==  0 && error == nil){
             NSLog(@"Nothing came through");
         }
         if(error != nil) {
             NSLog(@"ERROR = %@", error);
         }
     }];
}

- (NSString *) findClosestBaseStation:(CLLocation *)thisLocation:(NSDictionary *)locationList
{
    NSString *closestStationID;
    NSArray *dict = (NSArray*)[[locationList objectForKey:@"Locations"] objectForKey:@"Location"];
    double savedDistance = DBL_MAX;
    for (int i = 0; i < [dict count]; i++) {
        NSDictionary *dictStation = [dict objectAtIndex:i];
        CLLocation *currentStation = [[CLLocation alloc]initWithLatitude:[[dictStation valueForKey:@"latitude"] doubleValue] longitude:[[dictStation valueForKey:@"longitude"] doubleValue]];
        //NSLog(@"%f",savedDistance);
        double currentDistance = [thisLocation distanceFromLocation:currentStation];
        if(savedDistance > currentDistance){
            savedDistance = currentDistance;
            closestStationID = [dictStation valueForKey:@"id"];
        }
    }
    //WE NOW HAVE THE CLOSEST STATION ID;
    //WE CAN REQUEST THE WEATHER INFORMATION FOR THAT PARTICULAR STATION
    return nil;
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
