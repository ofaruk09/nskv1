//
//  WeatherEvent.h
//  nskv1
//
//  Created by Omorr Faruk on 08/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@property UIImage *eventWeatherImage;
@end
