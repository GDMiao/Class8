//
//  CourseWithCommentsCell.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CourseWithCommentsCell.h"
#import "CommentsModel.h"
#import "UIImageView+WebCache.h"
#import "UserCenterViewController.h"

@implementation CourseWithCommentsCell

- (void)dealloc
{
    self.totalScoreView = nil;
    self.t_titleLabel = nil;
    self.t_pfLabel = nil;
    self.t_lastLabel = nil;
    self.t_line = nil;
    
    self.userAvatar = nil;
    self.avatarButton = nil;
    self.userNameLabel = nil;
    self.startView = nil;
    self.commentTxtLabel = nil;
    self.dateLabel = nil;
    self.timeLabel = nil;
    self.line = nil;
    self.commentModel = nil;
    self.viewController = nil;
}

+ (CourseWithCommentsCell *)shareCourseWithCommentsCell
{
    static CourseWithCommentsCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CourseWithCommentsCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}


- (void)awakeFromNib {
    // Initialization code
    self.avatarButton.adjustsImageWhenDisabled = NO;
    self.avatarButton.adjustsImageWhenHighlighted = NO;
    [self.avatarButton setImage:[UIImage imageNamed:@"学生大头像遮罩"] forState:UIControlStateNormal];
}


- (CGFloat)setCellContentModel:(CommentsModel *)commentModel
{
    cellHeight = 0;
    self.commentModel = commentModel;
    
    if (self.totalScore != -1) {
        self.totalScoreView.hidden = NO;
        [self setTotalScoreViewContent];
        cellHeight = self.totalScoreView.bottom;
    }else {
        self.totalScoreView.hidden = YES;
    }
    
    self.userAvatar.left = 14;
    self.userAvatar.top = cellHeight + 10;
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:self.commentModel.owerAvatar] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    self.avatarButton.frame = self.userAvatar.frame;
    
    
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ 说:",self.commentModel.owerName];
    [self.userNameLabel sizeToFit];
    self.userNameLabel.left = self.userAvatar.right + 8;
    self.userNameLabel.top = cellHeight + 14;
    
    self.startView.frame = CGRectMake(self.userNameLabel.left, self.userNameLabel.bottom+8, 72, 12);
    [self.startView updateContent:self.commentModel.score];


    
    CGFloat txtMaxWidth = SCREENWIDTH - self.userNameLabel.left - 20;
    self.commentTxtLabel.width = txtMaxWidth;
    self.commentTxtLabel.text = self.commentModel.contenTxt;
    [self.commentTxtLabel sizeToFit];
    self.commentTxtLabel.left = self.userNameLabel.left;
    self.commentTxtLabel.top = self.startView.bottom + 13;
    
    self.dateLabel.text = [Utils dateString:self.commentModel.dateString];
    [self.dateLabel sizeToFit];
    self.dateLabel.left = self.userNameLabel.left;
    self.dateLabel.top = self.commentTxtLabel.bottom + 17;
    
    self.timeLabel.text = [Utils timeString:self.commentModel.dateString];
    [self.timeLabel sizeToFit];
    self.timeLabel.left = self.dateLabel.right + 5;
    self.timeLabel.top = self.dateLabel.top;
    
    cellHeight = MAX(self.userAvatar.bottom, self.timeLabel.bottom) + 9;
    self.line .frame = CGRectMake(13, cellHeight-1, SCREENWIDTH-26, 1);
    
    return cellHeight;
}

- (void)setTotalScoreViewContent
{
    self.totalScoreView.frame = CGRectMake(0, cellHeight, SCREENWIDTH, 10);
    
    self.t_titleLabel.text = @"综合评分:";
    [self.t_titleLabel sizeToFit];
    self.t_titleLabel.left = 14;
    self.t_titleLabel.top = 12;
    
    self.t_pfLabel.text = [NSString stringWithFormat:@"%0.1f",self.totalScore];
    [self.t_pfLabel sizeToFit];
    self.t_pfLabel.left = self.t_titleLabel.right + 10;
    self.t_pfLabel.bottom = self.t_titleLabel.bottom;
    
    self.t_lastLabel.text = @"分";
    self.t_lastLabel.left = self.t_pfLabel.right;
    self.t_lastLabel.bottom = self.t_pfLabel.bottom;
    
    self.totalScoreView.height = self.t_titleLabel.bottom + 12;
    self.t_line .frame = CGRectMake(13, self.totalScoreView.height-1, SCREENWIDTH-26, 1);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)userAvatarAction:(UIButton *)sender {
    UserCenterViewController *userCenter = [[UserCenterViewController alloc] initWithUiD:self.commentModel.owerUid isTeacher:NO];
    [self.viewController.navigationController pushViewController:userCenter animated:YES];

}
@end
