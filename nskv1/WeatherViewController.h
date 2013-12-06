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

@interface WeatherViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *WeatherLabelOutput;
@property NSString *longitude;
@property NSString *latitude;
@property NSString *location;

@end
