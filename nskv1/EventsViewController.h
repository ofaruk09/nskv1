//
//  EventsViewController.h
//  nskv1
//
//  Created by Omorr Faruk on 25/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventsCell.h"
#import "AppDelegate.h"
#import "FacebookService.h"
#import "FacebookEvent.h"
#import "EventsViewController.h"

@interface EventsViewController : UITableViewController

@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property NSMutableArray *EventsList;

- (void)sendRequests:(NSString *)fbID;

- (void)requestCompleted:(FBRequestConnection *)connection
                  result:(id)result
                   error:(NSError *)error;

- (BOOL)openFacebookSession;

- (void)downloadEvents;

- (void)triggerRefresh;

@end
