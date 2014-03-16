//
//  weatherViewCell.m
//  nskv1
//
//  Created by Omorr Faruk on 13/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import "WeatherViewCell.h"

@implementation WeatherViewCell
@synthesize WeatherActualTemperature;
@synthesize WeatherFeelsLikeTemperature;
@synthesize WeatherImage;
@synthesize WeatherTypeLabel;
@synthesize WeatherVisibilityLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)animateImage
{
    CABasicAnimation *weatherBackgroundAnimation;
    weatherBackgroundAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    weatherBackgroundAnimation.fromValue = [NSNumber numberWithFloat:0.1f];
    weatherBackgroundAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    weatherBackgroundAnimation.duration = 1.0;
    weatherBackgroundAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [WeatherImage.layer addAnimation:weatherBackgroundAnimation forKey:@"alpha"];
    [WeatherImage setAlpha:1];
}

@end
