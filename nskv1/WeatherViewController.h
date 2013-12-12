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
@property FacebookEvent *fbEvent;
@property double timeToEvent;
@property WeatherEvent *thisWeatherEvent;
@property (strong, nonatomic) IBOutlet UIView *windSpeedMeter;
@property (strong, nonatomic) IBOutlet UIView *windGustingMeter;
@property (strong, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *WindGustingLabel;
@property (strong, nonatomic) IBOutlet UILabel *WindDirectionLabel;
@property (strong, nonatomic) IBOutlet UILabel *WeatherFeelsLikeLabel;
@property (strong, nonatomic) IBOutlet UILabel *WeatherConditionLabel;
@property (strong, nonatomic) IBOutlet UILabel *VisibilityLabel;
@property (strong, nonatomic) IBOutlet UILabel *weatherActualTempLabel;
@property (strong, nonatomic) IBOutlet UILabel *WarningMessages;
@property (strong, nonatomic) IBOutlet UIImageView *weatherBackgroundImage;
@property (strong, nonatomic) IBOutlet UIScrollView *ScrollView;
@property (strong, nonatomic) IBOutlet UILabel *baseStationLabel;
- (void) downloadSiteList: (CLLocation *)thisLocation;
- (void) determineVenueLocation;
- (void) findWeatherDataForTimeAndPlace:(CLLocation*)myLocation locationList:(NSDictionary*)locationList;
- (void) createWeatherObject:(NSDictionary *)weather;

@end
