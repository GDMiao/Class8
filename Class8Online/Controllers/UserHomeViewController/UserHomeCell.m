//
//  UserHomeCell.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/14.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "UserHomeCell.h"

@implementation UserHomeCell

- (void)awakeFromNib {
    // Initialization code
    self.line.backgroundColor = MakeColor(0xe3, 0xe4, 0xe5);
    self.topLine.backgroundColor = MakeColor(0xe3, 0xe4, 0xe5);
    self.topLine.hidden = YES;
    self.jtImg.image = [UIImage imageNamed:@"icon_14"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellContent:(NSDictionary *)dic
{
    CGFloat cellHieght = 48;
    
    self.icon.top = (cellHieght-self.icon.height) *0.5;
    self.icon.left = 20;
    self.icon.image = [UIImage imageNamed:[dic stringForKey:IconName]];
    
    self.titleLabel.text = [dic stringForKey:TitleTxt_left];
    [self.titleLabel sizeToFit];
    self.titleLabel.top = (cellHieght-self.titleLabel.height)*0.5;
    self.titleLabel.left = self.icon.right + 7;
    
    self.jtImg.right = SCREENWIDTH - 13;
    self.jtImg.top = (cellHieght - self.jtImg.height) *0.5;
    
    
    if (self.idx ==0 && !self.isLastCell) {
        self.topLine.hidden = NO;
        self.topLine.frame = CGRectMake(0, 0, SCREENWIDTH, 1);
    }else {
        self.topLine.hidden = YES;
    }
    if (self.isLastCell) {
        self.line.frame = CGRectMake(0, cellHieght-1, SCREENWIDTH, 1);
    }else {
        self.line.frame = CGRectMake(15, cellHieght-1, SCREENWIDTH-30, 1);
    }
}
@end
