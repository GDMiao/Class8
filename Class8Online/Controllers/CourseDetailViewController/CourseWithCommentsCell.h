//
//  CourseWithCommentsCell.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarsView.h"

@class CommentsModel;
@interface CourseWithCommentsCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UIView *totalScoreView;
@property (weak, nonatomic) IBOutlet UILabel *t_titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *t_pfLabel;
@property (weak, nonatomic) IBOutlet UILabel *t_lastLabel;
@property (weak, nonatomic) IBOutlet UIImageView *t_line;

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet StarsView *startView;
@property (weak, nonatomic) IBOutlet UILabel *commentTxtLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *line;

- (IBAction)userAvatarAction:(UIButton *)sender;
@property (assign, nonatomic) CGFloat totalScore;           //综合评分 当此属性为-1 时代表不需要此属性
@property (strong, nonatomic) CommentsModel *commentModel;
@property (assign, nonatomic) UIViewController *viewController;

+ (CourseWithCommentsCell *)shareCourseWithCommentsCell;
- (CGFloat)setCellContentModel:(CommentsModel *)commentModel;

@end


