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
@property NSString * eventLongitude;
@property NSString * eventLatitude;
@property NSString * eventStartTime;
@property NSString * eventEndTime;
@property NSString * eventDescription;
@property NSString * eventImageSource;
@property UIImage * eventImage;


@end
