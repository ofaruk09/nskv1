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
    // We have cases we have to deal with
    // 1.Worst Case:
    // No location Data is provided, Pretty much screwed, have to let the user know...
    // 2.Best Case:
    // Location Name along with longitude and latitude is given, we can reverse geocode this and get the city name
    // 3.Meh Case:
    // Location Name given no longitude and latitude, we might be able to reverse geocode this.
    // 4.Another Meh Case:
    // Longitude and latitude but no Location Name, we can reverse geocode this and get the city name;
    
    // Acceptable Cases:
    // 2 & 4
    // Exception Cases:
    // 1 & 3
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
	// Do any additional setup after loading the view.
    [self sendRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDictionary *)sendRequest
{
    __block NSDictionary * weatherData;
    NSString * weatherReqURLopen = @"http://api.openweathermap.org/data/2.5/weather?";
    // GET THIS FROM EVENT DATA
    NSString * lat = [NSString stringWithFormat:@"lat=%s","51.51"];
    NSString * lng = [NSString stringWithFormat:@"&lon=%s","-0.13"];
    NSString * weatherApiAddress = [NSString stringWithFormat:@"%@%@%@", weatherReqURLopen, lat,lng];
    NSURL *url = [NSURL URLWithString:weatherApiAddress];
    
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
             NSString *entireDictionary = (NSString *)[weatherData description];
             NSLog(@"%@",entireDictionary);
             NSString *temp = (NSString *)[weatherData valueForKeyPath:@"main.temp_max"];
             NSLog(@"%@", temp);
             
         }
         else if([data length]  ==  0 && error == nil){
             NSLog(@"Nothing came through");
         }
         if(error != nil) {
             NSLog(@"ERROR = %@", error);
         }
     }
     ];
    return weatherData;
}
// reference iOS 6 cookbook chapter 9.2
// reference serialize JSON response to dictionary: https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40010946-CH1-SW2
// using blocks to take stuff out the async bit of the code: https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html

@end
