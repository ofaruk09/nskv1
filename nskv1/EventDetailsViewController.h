//
//  EventDetailsViewController.h
//  nskv1
//
//  Created by Omorr Faruk on 04/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookEvent.h"
#import "EventImageCell.h"
#import "WeatherTidesViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface EventDetailsViewController : UITableViewController
@property FacebookEvent *fbEvent;
@end
