//
//  dateTimePickerViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 13/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "DateTimePickerViewController.h"

@interface dateTimePickerViewController ()
@property (strong, nonatomic) IBOutlet UIDatePicker *dateAndTimePicker;
@end

@implementation dateTimePickerViewController
@synthesize fbEvent;
@synthesize dateAndTimePicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSDate *minDate = [NSDate date];
    // 432000 is the number of seconds in 5 days
    NSDate *maxDate = [NSDate dateWithTimeInterval:432000 sinceDate:minDate];
    // set the max bounds for the date picter
    [dateAndTimePicker setMinimumDate:minDate];
    [dateAndTimePicker setMaximumDate:maxDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    fbEvent.eventStartDate = [dateAndTimePicker date];
    WeatherTidesViewController *contr = segue.destinationViewController;
    contr.fbEvent = fbEvent;
}

@end
