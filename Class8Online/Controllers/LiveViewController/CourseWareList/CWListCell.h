//
//  CWListCell.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWModel.h"

@interface CWListCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UIImageView *cwIcon;
@property (weak, nonatomic) IBOutlet UILabel *cwNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *cwRightBtn;
@property (strong, nonatomic) CWModel *cwModel;
@property (assign, nonatomic) CGFloat contentWidth;
@property (weak, nonatomic) IBOutlet UIImageView *line;

- (void)setCourseWare:(CWModel *)cwModel;

+ (CWListCell *)shareCWListCell;
- (CGFloat)cellHeight:(CWModel *)value;

@end
