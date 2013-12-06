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

@interface WeatherViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *WeatherLabelOutput;
@property float longitude;
@property float latitude;
@property NSString *location;
- (void) downloadSiteList: (CLLocation *)thisLocation;
- (void) determineVenueLocation;
- (NSString *) findClosestBaseStation:(CLLocation *)thisLocation;

@end
