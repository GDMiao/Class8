//
//  MyCalendarClassCell.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MyCalendarClassCell.h"
#import "UIImageView+WebCache.h"
#import "UserCenterViewController.h"
#import "MyCalendarViewController.h"
@interface MyCalendarClassCell ()
{
    CGFloat cellHeight;
}

@end

@implementation MyCalendarClassCell

- (IBAction)avatarAction:(UIButton *)sender {
    CSLog(@"头像点击");
    UserCenterViewController *userCenter = [[UserCenterViewController alloc] initWithUiD:self.data.teacherId isTeacher:YES];
    MyCalendarViewController  *calenderVC = (MyCalendarViewController *)self.viewController;
    [calenderVC.tabbarVC.navigationController pushViewController:userCenter animated:YES];

}

+ (MyCalendarClassCell *)shareCalendarCell
{
    static MyCalendarClassCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyCalendarClassCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.startIcon = nil;
    self.endIcon = nil;
    self.haveLessonsL = nil;
    self.currentLessons = nil;
    self.totalLessons = nil;
    self.iconImg = nil;
    self.avatarButton = nil;
    self.startTimeLabel = nil;
    self.nameLabel = nil;
    self.line2View = nil;
    self.data = nil;
    self.viewController = nil;
}
- (void)awakeFromNib {
    UIImage *lineImg = [UIImage imageNamed:@"分隔线"];
//    lineImg = [lineImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.line2View.image = lineImg;
    self.startIcon.image = [UIImage imageNamed:@"icon_21"];
    self.endIcon.image = [UIImage imageNamed:@"icon_2"];
    [self.avatarButton setBackgroundImage:[UIImage imageNamed:@"课程日历头像遮罩"] forState:UIControlStateNormal ];
}

- (CGFloat)setContentData:(ClassModel *)aData
{
    cellHeight = 0;
    self.data = aData;
    
    NSString *showText = self.data.name;
    if ([Utils objectIsNotNull:self.data.teaNick]) {
        showText = [NSString stringWithFormat:@"%@(%@)",showText,self.data.teaNick];
    }
    self.nameLabel.text = self.data.name;
    [self.nameLabel sizeToFit];
    self.nameLabel.left = 21;
    self.nameLabel.top = 21;
    
    self.startIcon.left = self.nameLabel.left;
    self.startIcon.top = self.nameLabel.bottom + 13;
    
    
    self.startTimeLabel.left = self.startIcon.right + 5;
    self.startTimeLabel.top = self.startIcon.top;
    NSString *itemTime = [NSString stringWithFormat:@"%@-%@",[Utils timeString:self.data.startTime],[Utils timeString:self.data.endTime]];
    self.startTimeLabel.text = itemTime;
    [self.startTimeLabel sizeToFit];
    
    
    self.endIcon.top = self.startTimeLabel.top;
    self.endIcon.left = self.startTimeLabel.right + 12;
    
    
    [self.haveLessonsL sizeToFit];
    self.haveLessonsL.top = self.startTimeLabel.top;
    self.haveLessonsL.left = self.endIcon.right + 5;
    
    self.currentLessons.text = self.data.finishedclass;
    [self.currentLessons sizeToFit];
    self.currentLessons.left = self.haveLessonsL.right + 5;
    self.currentLessons.top = self.haveLessonsL.top;
    
    self.totalLessons.text = [NSString stringWithFormat:@"/%@节",self.data.totalclass];
    [self.totalLessons sizeToFit];
    self.totalLessons.left = self.currentLessons.right;
    self.totalLessons.top = self.currentLessons.top;
    
    self.iconImg.right = SCREENWIDTH - 30;

    [self.iconImg sd_setImageWithURL:[NSURL URLWithString:self.data.teaImgUrl] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    
    cellHeight = self.startIcon.bottom + 21;
    self.iconImg.top = (cellHeight - self.iconImg.height) * 0.5;
    self.avatarButton.frame = self.iconImg.frame;
    self.line2View.frame = CGRectMake(17, cellHeight -1, SCREENWIDTH - 2*17 , 1);
    
    return cellHeight;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
