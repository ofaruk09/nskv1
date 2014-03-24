//
//  MeterViewCell.m
//  nskv1
//
//  Created by Omorr Faruk on 12/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import "MeterViewCell.h"
@interface MeterViewCell ()

@end

@implementation MeterViewCell
@synthesize Meter;
@synthesize Value;
@synthesize percentageOfMeter;
@synthesize MeterTypeLabel;
@synthesize optionalLabel;
const float maxMeterSize = 287;

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
    
    //set up the animation here
    Meter.layer.anchorPoint = CGPointMake(0.0, 0.5);
    CABasicAnimation *anim;
    anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    anim.fromValue = [NSNumber numberWithFloat:0.1f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.duration = 1.0;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    // add the newly created animation to the view layer
    [Meter.layer addAnimation:anim forKey:@"position"];
    // change the layer size to the new meter size
    Meter.frame = CGRectMake(Meter.frame.origin.x, Meter.frame.origin.y, viewPercentage, 30);
    
    // add the animation to the label so it moves with the meter as it expands
    CABasicAnimation *labelAnim;
    [Value.layer addAnimation:labelAnim forKey:@"position"];
    [Value setFrame:CGRectMake(viewPercentage - 40, Value.frame.origin.y, 50, 20)];
}
@end
