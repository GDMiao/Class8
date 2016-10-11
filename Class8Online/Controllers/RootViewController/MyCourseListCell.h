//
//  MyCourseListCell.h
//  Class8Online
//
//  Created by chuliangliang on 15/5/12.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CourseModel;
@interface MyCourseListCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UIImageView *courseCover;
@property (weak, nonatomic) IBOutlet UILabel *courseName;

@property (weak, nonatomic) IBOutlet UIImageView *teaSexIcon;
@property (weak, nonatomic) IBOutlet UILabel *teaName;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLine;

@property (weak, nonatomic) IBOutlet UIImageView *stuCountIcon;
@property (weak, nonatomic) IBOutlet UILabel *stuCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lessonIcon;
@property (weak, nonatomic) IBOutlet UILabel *lessonNumLabel1;
@property (weak, nonatomic) IBOutlet UILabel *lessonNumLabel2;
@property (weak, nonatomic) IBOutlet UILabel *lessonNumLabel3;
@property (weak, nonatomic) IBOutlet UIButton *intoClassLiveButton;

@property (assign, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) CourseModel *course;

- (IBAction)intoClasslive:(UIButton *)sender;
/**
 * 停止滑动时加载网络图片
 **/
- (void)beginLoadImg;
+ (MyCourseListCell *)shareCourseCell;
- (CGFloat) setCellContent:(CourseModel *)course;
@end
