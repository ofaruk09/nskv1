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
@synthesize timeToEvent;
@synthesize thisWeatherEvent;
@synthesize windSpeedMeter;
@synthesize weatherActualTempLabel;
@synthesize weatherBackgroundImage;
@synthesize WeatherConditionLabel;
@synthesize WeatherFeelsLikeLabel;
@synthesize WindDirectionLabel;
@synthesize WindGustingLabel;
@synthesize windSpeedLabel;
@synthesize WarningMessages;
@synthesize VisibilityLabel;
@synthesize windGustingMeter;
@synthesize ScrollView;
@synthesize baseStationLabel;
NSString *baseWeatherAddress = @"http://datapoint.metoffice.gov.uk/public/data/";
NSString *apiKey = @"key=9a359b8e-179a-4164-8e29-dcfab50bed8a";
NSString *allLocations = @"val/wxfcs/all/json/sitelist";
NSString *baseStation = @"val/wxfcs/all/json/";
const NSArray *weatherTypes;
const float maxSpeed = 50;
const float meterMaxSize = 287;
const NSArray *weatherImages;

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
    thisWeatherEvent = [[WeatherEvent alloc]init];
    [ScrollView setContentSize: CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [ScrollView setScrollEnabled:true];
    FacebookEvent *temp = [[FacebookEvent alloc]init];
    temp.eventLongitude = 1.2724;
    temp.eventLatitude = 51.9271;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *startDate = [format dateFromString:@"2013-12-17T21:30:00+0000"];
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
    weatherImages = [[NSArray alloc]initWithObjects:@"ClearNightWeather",
                                                    @"SunnyWeather",
                                                    @"PartlyCloudyWeather",
                                                    @"CloudyWeather",
                                                    @"RainWeather",
                                                    @"HeavyRainWeather",
                                                    @"SnowWeather",
                                                    @"LightningWeather", nil];
    
    
    //Do some checks to see if 5 days from event
    //Do some checks if time exists in event information
    //[self startAnim];
    
    [self determineVenueLocation];
	// Do any additional setup after loading the view.
    // When sending a request, to get ALL the data including gust, we must provide the city!
}
- (void)startAnim
{
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
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"MetOffice Offline" message:@"The service is currently unavailable, please try again later" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
             
             [alert show];
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
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"MetOffice Offline" message:@"The service is currently unavailable, please try again later" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
             
             [alert show];
         }
     }];
}

- (void) createWeatherObject:(NSDictionary *)weather
{
    NSLog([weather description]);
    NSDictionary *locationData = [[[weather objectForKey:@"SiteRep"] objectForKey:@"DV"]objectForKey:@"Location"];
    thisWeatherEvent.baseStation = [locationData valueForKey:@"name"];
    NSDictionary *weatherContent = [[[[[weather objectForKey:@"SiteRep"] objectForKey:@"DV"]objectForKey:@"Location"]objectForKey:@"Period"]objectForKey:@"Rep"];
    thisWeatherEvent.eventTemperature = [weatherContent valueForKey:@"T"];
    thisWeatherEvent.eventFeelsLikeTemperature = [weatherContent valueForKey:@"F"];
    thisWeatherEvent.eventVisibility = [weatherContent valueForKey:@"V"];
    //NSLog([weatherContent])
    NSUInteger wTemp = [[weatherContent valueForKey:@"W"] integerValue];
    thisWeatherEvent.eventWeatherType = [weatherTypes objectAtIndex:wTemp];
    thisWeatherEvent.eventWeatherTypeValue = [NSString stringWithFormat:@"%i",wTemp];
    thisWeatherEvent.eventWindDirection = [weatherContent valueForKey:@"D"];
    thisWeatherEvent.eventWindGusting = [weatherContent valueForKey:@"G"];
    thisWeatherEvent.eventWindSpeed = [weatherContent valueForKey:@"S"];
    //Remove Spinner Here
    
    float percentWindSpeed;
    float percentWindGust;
    NSString *message;
    
    //CONDITIONING MESSAGE
    if([thisWeatherEvent.eventWindGusting floatValue] > maxSpeed)
    {
        message = @"Wind gust exceeds 20mph, contact the event supervisor for more information";
    }
    else {
        message = @"It seems ok to go kayaking in these conditions";
    }
    //CONDITIONING IMAGE
    if (wTemp == 0 ) {
        thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[0]];
    }
    else if (wTemp == 1){
        thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[1]];
    }
    else if (wTemp > 1 && wTemp <= 4){
        thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[2]];
    }
    else if (wTemp > 4 && wTemp <=8){
        thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[3]];
    }
    else if(wTemp > 8 && wTemp <= 12){
        thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[4]];
    }
    else if(wTemp > 12 && wTemp <= 15){
        thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[5]];
    }
    else if(wTemp > 15 && wTemp <= 27){
        thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[6]];
    }
    else{
        thisWeatherEvent.eventWeatherImage = [UIImage imageNamed:weatherImages[7]];
    }
    //CONDITIONING METER
    if ([thisWeatherEvent.eventWindSpeed floatValue] <= maxSpeed) {
        percentWindSpeed= ([thisWeatherEvent.eventWindSpeed floatValue]/maxSpeed)*meterMaxSize;
    }
    else{
        percentWindSpeed = meterMaxSize;
    }
    if([thisWeatherEvent.eventWindGusting floatValue] <= maxSpeed){
         percentWindGust= ([thisWeatherEvent.eventWindGusting floatValue]/maxSpeed)*meterMaxSize;
    }
    else{
        percentWindGust = meterMaxSize;
    }
    //Start Building View
    dispatch_async(dispatch_get_main_queue(), ^{
        ///////////////////////////////////////////////////////////////////////////
        weatherActualTempLabel.text = [thisWeatherEvent.eventTemperature stringByAppendingString:@"°C"];
        WeatherFeelsLikeLabel.text = [thisWeatherEvent.eventFeelsLikeTemperature stringByAppendingString:@"°C"];
        WeatherConditionLabel.text = thisWeatherEvent.eventWeatherType;
        VisibilityLabel.text = thisWeatherEvent.eventVisibility;
        windSpeedLabel.text = thisWeatherEvent.eventWindSpeed;
        WindGustingLabel.text = thisWeatherEvent.eventWindGusting;
        WindDirectionLabel.text = thisWeatherEvent.eventWindDirection;
        WarningMessages.text = message;
        baseStationLabel.text = thisWeatherEvent.baseStation;
        weatherBackgroundImage.image = thisWeatherEvent.eventWeatherImage;
        //calc bar percentage
        
        windSpeedMeter.layer.anchorPoint = CGPointMake(0.0, 0.5);
        CABasicAnimation *windSpeedAnimation;
        windSpeedAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        windSpeedAnimation.fromValue = [NSNumber numberWithFloat:0.1f];
        windSpeedAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        windSpeedAnimation.duration = 1.0;
        windSpeedAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [windSpeedMeter.layer addAnimation:windSpeedAnimation forKey:@"position"];
        windSpeedMeter.frame = CGRectMake(windSpeedMeter.frame.origin.x, windSpeedMeter.frame.origin.y, percentWindSpeed, 30);
        
        windGustingMeter.layer.anchorPoint = CGPointMake(0.0, 0.5);
        CABasicAnimation *windGustAnimation;
        windGustAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        windGustAnimation.fromValue = [NSNumber numberWithFloat:0.1f];
        windGustAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        windGustAnimation.duration = 1.0;
        windGustAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [windGustingMeter.layer addAnimation:windGustAnimation forKey:@"position"];
        windGustingMeter.frame = CGRectMake(windGustingMeter.frame.origin.x, windGustingMeter.frame.origin.y, percentWindGust, 30);
        
        CABasicAnimation *windSpeedLabelAnimation;
        windGustAnimation = [CABasicAnimation animationWithKeyPath:@"transform.position.x"];
        windGustAnimation.fromValue = [NSNumber numberWithFloat:0.1f];
        windGustAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        windGustAnimation.duration = 1.0;
        windGustAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [windSpeedLabel.layer addAnimation:windSpeedLabelAnimation forKey:@"position"];
        [windSpeedLabel setFrame:CGRectMake(percentWindSpeed - 25, windSpeedLabel.frame.origin.y, 20, 20)];
        CABasicAnimation *windGustLabelAnimation;
        windGustAnimation = [CABasicAnimation animationWithKeyPath:@"transform.position.x"];
        windGustAnimation.fromValue = [NSNumber numberWithFloat:0.1f];
        windGustAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        windGustAnimation.duration = 1.0;
        windGustAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [WindGustingLabel.layer addAnimation:windGustLabelAnimation forKey:@"position"];
        [WindGustingLabel setFrame:CGRectMake(percentWindGust - 25, WindGustingLabel.frame.origin.y, 20, 20)];
        
        CABasicAnimation *weatherBackgroundAnimation;
        windGustAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        windGustAnimation.fromValue = [NSNumber numberWithFloat:0.1f];
        windGustAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        windGustAnimation.duration = 1.0;
        windGustAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [weatherBackgroundImage.layer addAnimation:windGustAnimation forKey:@"alpha"];
        [weatherBackgroundImage setAlpha:1];
        ///////////////////////////////////////////////////////////////////////
    });
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// reference iOS 6 cookbook chapter 9.2
// reference serialize JSON response to dictionary: https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40010946-CH1-SW2
// using blocks to take stuff out the async bit of the code: https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html

// IMG SOURCE
// http://www.stockvault.net/photo/124678/dawn
// http://www.stockvault.net/photo/133780/cloudy-blue-sky
// http://www.stockvault.net/photo/147063/early-foggy-morning
// http://www.stockvault.net/photo/101022/early-morning-rain
// http://www.stockvault.net/photo/101628/rain-cloud-series-image-15-of-15
// http://www.stockvault.net/photo/150904/tropical-storm-window-raindrops
// http://www.stockvault.net/photo/102038/path-in-the-snow
// http://www.stockvault.net/photo/131885/lightning

@end
