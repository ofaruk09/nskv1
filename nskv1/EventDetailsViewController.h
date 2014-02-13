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
#import "WeatherViewController.h"
#import "WeatherTidesViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface EventDetailsViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UINavigationItem *ViewController;
- (IBAction)PinEvent:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pinButton;
@property FacebookEvent *fbEvent;
@end
