//
//  FbCachedEvent.h
//  nskv1
//
//  Created by Omorr Faruk on 20/05/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FbCachedEvent : NSManagedObject

@property (nonatomic, retain) NSString * eventID;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * eventLocation;
@property (nonatomic, retain) NSNumber * eventLongitude;
@property (nonatomic, retain) NSNumber * eventLatitude;
@property (nonatomic, retain) NSDate * eventStartDate;
@property (nonatomic, retain) NSDate * eventEndDate;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * eventImageSource;
@property (nonatomic, retain) NSData * eventImage;
@property (nonatomic, retain) NSNumber * eventAttending;

@end
