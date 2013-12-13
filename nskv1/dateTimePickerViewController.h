//
//  dateTimePickerViewController.h
//  nskv1
//
//  Created by Omorr Faruk on 13/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookEvent.h"
#import "WeatherViewController.h"

@interface dateTimePickerViewController : UIViewController
@property FacebookEvent *fbEvent;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateAndTimePicker;
@end
