//
//  EventsCell.h
//  nskv1
//
//  Created by Omorr Faruk on 25/11/2013.
//  Copyright (c) 2013 Omorr Faruk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *eventName;
@property (strong, nonatomic) IBOutlet UILabel *eventDesc;
@property (strong, nonatomic) IBOutlet UIImageView *eventThumb;
@property (strong, nonatomic) IBOutlet UIImageView *eventMode;

@end
