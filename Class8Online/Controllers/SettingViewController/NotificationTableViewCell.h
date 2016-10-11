//
//  NotificationTableViewCell.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/11.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SevenSwitch.h"

@interface NotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (strong,nonatomic) SevenSwitch * sevenSwitch;

@end
