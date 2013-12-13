//
//  VenueFinderViewController.m
//  nskv1
//
//  Created by Omorr Faruk on 13/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import "VenueFinderViewController.h"

@interface VenueFinderViewController ()

@end

@implementation VenueFinderViewController
@synthesize crossHairView;
@synthesize mapView;
@synthesize selectLocationButton;

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
    float x = ((mapView.frame.size.width)/2) - 20;
    float y = ((mapView.frame.size.height)/2) - 20;
    CGRect crossHair = CGRectMake(x, y, 40, 40);
    [crossHairView setFrame:crossHair];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"datePicker"]){
        CLLocationCoordinate2D position = mapView.centerCoordinate;
        FacebookEvent *tempEvent = [[FacebookEvent alloc]init];
        tempEvent.eventLongitude = position.longitude;
        tempEvent.eventLatitude = position.latitude;
        
        dateTimePickerViewController *contr = segue.destinationViewController;
        contr.fbEvent = tempEvent;
    }
}

@end
