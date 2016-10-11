//
//  MyCalendarClassCell.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassModel.h"
@interface MyCalendarClassCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *startIcon;
@property (weak, nonatomic) IBOutlet UIImageView *endIcon;
@property (weak, nonatomic) IBOutlet UILabel *haveLessonsL;
@property (weak, nonatomic) IBOutlet UILabel *currentLessons;
@property (weak, nonatomic) IBOutlet UILabel *totalLessons;
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *line2View;

@property (assign, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) ClassModel *data;

- (IBAction)avatarAction:(UIButton *)sender;
+ (MyCalendarClassCell *)shareCalendarCell;

- (CGFloat)setContentData:(ClassModel *)aData;
@end
