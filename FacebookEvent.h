//
//  FacebookEvent.h
//  nskv1
//
//  Created by Omorr Faruk on 26/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookEvent : NSObject

@property NSString * eventID;
@property NSString * eventName;
@property NSString * eventLocation;
@property float eventLongitude;
@property float eventLatitude;
@property NSDate * eventStartDate;
@property NSDate * eventEndDate;
@property NSString * eventDescription;
@property NSString * eventImageSource;
@property UIImage * eventImage;
@property NSDateFormatter *dateFormatterStart;
@property NSDateFormatter *dateFormatterEnd;


@end
