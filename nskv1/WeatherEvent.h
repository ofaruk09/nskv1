//
//  WeatherEvent.h
//  nskv1
//
//  Created by Omorr Faruk on 08/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookEvent.h"

@interface WeatherEvent : NSObject
@property NSString * eventTemperature;
@property NSString * eventWindDirection;
@property NSString * eventWindSpeed;
@property NSString * eventWindGusting;
@property NSString * eventWeatherType;
@property NSString * eventWeatherTypeValue;
@property NSString * eventVisibility;
@property NSString * eventFeelsLikeTemperature;
@property NSString * baseStation;
@property NSString * userMessage;
@property UIImage *eventWeatherImage;
@property float percentageOfMaxWindSpeedWind;
@property float percentageOfMaxWindSpeedGust;
extern float const MAX_WIND_SPEED;
extern int const WEATHER_TOTAL_STEPS;

+ (NSArray*) weatherTypes;
- (void) downloadWeatherDataWithLocation:(CLLocation *)thisLocation
                        forFacebookEvent:(FacebookEvent *)fbEvent;
- (id)initWithLocation:(CLLocation *)thisLocation
      forFacebookEvent:(FacebookEvent *)fbEvent;
@end
