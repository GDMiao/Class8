//
//  SettingTableViewCell.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "SettingTableViewCell.h"

@implementation SettingTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    self.iconMaskImgView.image = [UIImage imageNamed:@"学生大头像遮罩"];
}

- (void)dealloc {
    self.titleLab = nil;
    self.subTitleLab = nil;

    self.bgImg = nil;
    self.lineImg = nil;
    self.rightImg = nil;
    self.onlywifi = nil;

}

- (void)setContentDic:(NSDictionary *)dic
{
    
    self.backgroundColor = [UIColor whiteColor];

    self.rightImg.right = SCREENWIDTH - 13;
    self.rightImg.top = (self.height - self.rightImg.height) * 0.5;
    self.onlywifi.hidden = YES;
    self.onlywifi.right = self.rightImg.right;
    self.onlywifi.top = (self.height - self.onlywifi.height) * 0.5;
    self.onlywifi.onTintColor = MakeColor(0xc9, 0xc9, 0xc9);
    self.onlywifi.thumbTintColor = MakeColor(0x4f, 0xb8, 0x34);
    
    NSString *rightText = [dic stringForKey:SETTINGCELL_RIGHTTITLE];
    if ([Utils objectIsNotNull:rightText]) {
        self.subTitleLab.text = rightText;
        self.subTitleLab.top = (self.height - self.subTitleLab.height) * 0.5;
        self.subTitleLab.right = self.rightImg.left - 7;
        self.subTitleLab.textColor = MakeColor(0x4f, 0xb8, 0x34);
        self.subTitleLab.hidden = NO;
        
    }
    else {
        self.subTitleLab.hidden = YES;
    }
    
    
    
    self.titleLab.text = [dic stringForKey:SETTINGCELL_LEFTTITLE];
    self.titleLab.left = 20;
    self.titleLab.top = (self.height - self.titleLab.height) * 0.5;
    self.titleLab.textColor = [UIColor blackColor];
    [self.titleLab sizeToFit];
    
    self.lineImg.top = 0;
    self.lineImg.left = 20;
    self.lineImg.right = SCREENWIDTH - 13;
}

- (void)lineShow
{
    _lineImg.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
