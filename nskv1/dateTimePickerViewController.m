//
//  dateTimePickerViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 13/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "dateTimePickerViewController.h"

@interface dateTimePickerViewController ()

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
    NSDate *maxDate = [NSDate dateWithTimeInterval:432000 sinceDate:minDate];
    
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
    if([[segue identifier] isEqualToString:@"datePicker"]){
        fbEvent.eventStartDate = [dateAndTimePicker date];
        WeatherViewController *contr = segue.destinationViewController;
        contr.fbEvent = fbEvent;
    }
}

@end
