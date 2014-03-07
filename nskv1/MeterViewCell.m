//
//  MeterViewCell.m
//  nskv1
//
//  Created by Omorr Faruk on 12/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import "MeterViewCell.h"

@implementation MeterViewCell
@synthesize Meter;
@synthesize Value;
@synthesize percentageOfMeter;
@synthesize MeterTypeLabel;
@synthesize optionalLabel;

float maxMeterSize = 287;
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

-(void)animateMeter
{
    float viewPercentage = maxMeterSize * (percentageOfMeter/100);
    if(viewPercentage < 50.0f) viewPercentage = 50.0f; // so meter does not become too small to see text
    Meter.layer.anchorPoint = CGPointMake(0.0, 0.5);
    CABasicAnimation *anim;
    anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    anim.fromValue = [NSNumber numberWithFloat:0.1f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.duration = 1.0;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [Meter.layer addAnimation:anim forKey:@"position"];
    Meter.frame = CGRectMake(Meter.frame.origin.x, Meter.frame.origin.y, viewPercentage, 30);
    
    CABasicAnimation *labelAnim;
    [Value.layer addAnimation:labelAnim forKey:@"position"];
    [Value setFrame:CGRectMake(viewPercentage - 40, Value.frame.origin.y, 50, 20)];
}
@end
