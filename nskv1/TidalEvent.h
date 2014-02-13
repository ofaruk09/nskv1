//
//  TidalEvent.h
//  nskv1
//
//  Created by Omorr Faruk on 12/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookEvent.h"

@interface TidalEvent : NSObject
@property NSString *WaterMode;
@property NSString *time;
@property NSString *height;
@property float percentageOfMaxTideHeight;
@property NSString *baseStation;
extern int const TIDE_TOTAL_STEPS;

- (void) downloadTideDataWithLocation:(CLLocation *)thisLocation
                        forFacebookEvent:(FacebookEvent *)fbEvent;
- (id)initWithLocation:(CLLocation *)thisLocation
      forFacebookEvent:(FacebookEvent *)fbEvent;
+ (NSMutableArray *) getTidesData;

@end
