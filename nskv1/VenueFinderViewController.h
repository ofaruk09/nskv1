//
//  VenueFinderViewController.h
//  nskv1
//
//  Created by Omorr Faruk on 13/12/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FacebookEvent.h"
#import "dateTimePickerViewController.h"

@interface VenueFinderViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *selectLocationButton;
@property (strong, nonatomic) IBOutlet UIImageView *crossHairView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
