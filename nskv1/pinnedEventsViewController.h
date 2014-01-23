//
//  pinnedEventsViewController.h
//  nskv1
//
//  Created by Omorr Faruk on 14/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventsViewController.h"
#import "AppDelegate.h"
#import "FacebookEvent.h"
#import "EventsCell.h"

@interface pinnedEventsViewController : UITableViewController
-(void) refreshView;
@property NSMutableArray *PinnedEvents;
@end
