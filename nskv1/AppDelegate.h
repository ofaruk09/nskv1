//
//  AppDelegate.h
//  nskv1
//
//  Created by Omorr Faruk on 25/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookEvent.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property NSString *userID;

+ (NSMutableArray *) getEventsList;
+ (NSMutableArray *) getPinnedList;
- (void)sendRequests:(NSString *)fbID;
- (void)requestCompleted:(FBRequestConnection *)connection
                  result:(id)result
                   error:(NSError *)error;
- (void)openFacebookSession;
- (void)downloadEvents;
@end
