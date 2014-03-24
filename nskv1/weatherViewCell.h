//
//  weatherViewCell.h
//  nskv1
//
//  Created by Omorr Faruk on 13/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *weatherImage;
@property (strong, nonatomic) IBOutlet UILabel *weatherActualTemperature;
@property (strong, nonatomic) IBOutlet UILabel *weatherFeelsLikeTemperature;
@property (strong, nonatomic) IBOutlet UILabel *weatherTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *weatherVisibilityLabel;
-(void)animateImage;
@end
