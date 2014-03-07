//
//  kayakingConditionsButtonCell.m
//  nskv1
//
//  Created by Omorr Faruk on 05/03/2014.
//  Copyright (c) 2014 Omorr Faruk. All rights reserved.
//

#import "kayakingConditionsButtonCell.h"

@implementation kayakingConditionsButtonCell
@synthesize conditionsButton;
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

@end
