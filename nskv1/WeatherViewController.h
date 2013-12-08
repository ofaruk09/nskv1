//
//  WeatherViewController.h
//  nskv1
//
//  Created by Omorr Faruk on 05/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EventDetailsViewController.h"
#import "FacebookEvent.h"
#import "WeatherEvent.h"

@interface WeatherViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *WeatherLabelOutput;
@property FacebookEvent *fbEvent;
@property double timeToEvent;
@property WeatherEvent *weatherEvent;
- (void) downloadSiteList: (CLLocation *)thisLocation;
- (void) determineVenueLocation;
- (void) findWeatherDataForTimeAndPlace:(CLLocation*)myLocation locationList:(NSDictionary*)locationList;
- (void) createWeatherObject:(NSDictionary *)weather;

@end
