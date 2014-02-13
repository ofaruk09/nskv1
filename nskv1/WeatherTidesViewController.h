//
//  WeatherTidesViewController.h
//  nskv1
//
//  Created by Omorr Faruk on 12/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookEvent.h"
#import "WeatherEvent.h"
#import "TidalEvent.h"
#import "MeterViewCell.h"
#import "WeatherViewCell.h"


@interface WeatherTidesViewController : UITableViewController
@property FacebookEvent *fbEvent;
@property double timeToEvent;
@property WeatherEvent *thisWeatherEvent;
@property TidalEvent * thisTidalEvent;
- (void) determineVenueLocation;
@end
