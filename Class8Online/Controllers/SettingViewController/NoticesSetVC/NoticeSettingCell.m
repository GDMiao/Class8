//
//  NoticeSettingCell.m
//  Class8Online
//
//  Created by chuliangliang on 15/9/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "NoticeSettingCell.h"

@implementation NoticeSettingCell

- (void)awakeFromNib {
    
    UIImage *lineImg = [UIImage imageNamed:@"分隔线"];
    lineImg = [lineImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.line.image = lineImg;
    
    self.rightIcon.image = [UIImage imageNamed:@"文件保存"];
}

- (void)setContentlabelText:(NSString *)text
{
    
    self.rightIcon.right = SCREENWIDTH - 16;
    self.rightIcon.top = (48 - self.rightIcon.height) * 0.5;
    
    
    self.titleLable.text = text;
    [self.titleLable sizeToFit];
    self.titleLable.left = 16;
    self.titleLable.width = self.rightIcon.left - self.titleLable.left - 10;
    self.titleLable.top = (48- self.titleLable.height) * 0.5;
    
    self.line.frame = CGRectMake(0, 47, SCREENWIDTH, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.rightIcon.hidden = !selected;
}

@end
