//
//  NotificationTableViewCell.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/11.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

- (void)dealloc
{
    self.iconImg = nil;
    self.titleLab = nil;
    self.sevenSwitch = nil;
}

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    
    self.width = SCREENWIDTH;
    
    self.iconImg.left = 20;
    self.titleLab.left = self.iconImg.right + 15;
    self.titleLab.textColor = [UIColor whiteColor];
    
    self.sevenSwitch = [[SevenSwitch alloc] init];
    self.sevenSwitch.width = 50;
    self.sevenSwitch.height = 25;
    self.sevenSwitch.top = 12.5;
    self.sevenSwitch.right = self.width - 15;
    self.sevenSwitch.inactiveColor = [UIColor whiteColor];
    self.sevenSwitch.onTintColor = [UIColor whiteColor];
    self.sevenSwitch.borderColor = [UIColor whiteColor];
    self.sevenSwitch.thumbTintColor = [UIColor colorWithRed:87/255.0 green:234/255.0 blue:26/255.0 alpha:1];
    
    [self addSubview:self.sevenSwitch];
    
    UIImageView * lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.titleLab.left, self.height - 1, self.width, 1)];
    lineImg.image = [UIImage imageNamed:@"sz_line"];
    lineImg.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:lineImg];
    lineImg.width = self.sevenSwitch.right - self.titleLab.left;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
