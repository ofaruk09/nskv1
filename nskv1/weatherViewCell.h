//
//  weatherViewCell.h
//  nskv1
//
//  Created by Omorr Faruk on 13/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *WeatherImage;
@property (strong, nonatomic) IBOutlet UILabel *WeatherActualTemperature;
@property (strong, nonatomic) IBOutlet UILabel *WeatherFeelsLikeTemperature;
@property (strong, nonatomic) IBOutlet UILabel *WeatherTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *WeatherVisibilityLabel;
-(void)animateImage;
@end
