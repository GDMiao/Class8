//
//  SettingTableViewCell.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SETTINGCELL_ICON @"SETTING_icon"
#define SETTINGCELL_LEFTTITLE @"SETTINGCELL_leftTitle"
#define SETTINGCELL_RIGHTTITLE @"SETTINGCELL_rightTitle"

@interface SettingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *onlywifi;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLab;
@property (weak, nonatomic) IBOutlet UIImageView *lineImg;
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UIImageView *rightImg;

- (void)setContentDic:(NSDictionary *)dic;
@end
