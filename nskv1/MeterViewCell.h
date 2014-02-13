//
//  MeterViewCell.h
//  nskv1
//
//  Created by Omorr Faruk on 12/02/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeterViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *Meter;
@property (strong, nonatomic) IBOutlet UILabel *Value;
@property (strong, nonatomic) IBOutlet UILabel *MeterTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *optionalLabel;
@property float percentageOfMeter;
-(void)animateMeter;
@end
