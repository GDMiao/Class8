//
//  MyCourseListCell.m
//  Class8Online
//
//  Created by chuliangliang on 15/5/12.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MyCourseListCell.h"
#import "UIImageView+WebCache.h"
#import "CourseModel.h"
#import "LiveViewController.h"

@implementation MyCourseListCell

- (void)dealloc {
    self.courseCover = nil;
    self.intoClassLiveButton = nil;
    self.courseName = nil;
    self.teaSexIcon = nil;
    self.teaName = nil;
    self.stuCountIcon = nil;
    self.stuCountLabel = nil;
    self.lessonIcon = nil;
    self.lessonNumLabel1 = nil;
    self.lessonNumLabel2 = nil;
    self.lessonNumLabel3  = nil;
    self.bottomLine = nil;
    self.course = nil;
    self.viewController = nil;
}

+ (MyCourseListCell *)shareCourseCell
{
    static MyCourseListCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyCourseListCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}


- (void)awakeFromNib {
    [self _initViews];
}
- (void)_initViews
{
    
    UIImage *lineImg = [UIImage imageNamed:@"分隔线"];
    lineImg = [lineImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.bottomLine.image = lineImg;
}

- (CGFloat) setCellContent:(CourseModel *)course
{
    self.course = course;
    cellHeight = 0;

    //课程名字
    self.courseName.text = self.course.courseName;
    [self.courseName sizeToFit];
    self.courseName.top = cellHeight+15;
    self.courseName.left = 16;
    self.courseName.width = SCREENWIDTH - self.courseName.left*2;
    cellHeight = self.courseName.bottom;

    [self.courseCover sd_setImageWithURL:[NSURL URLWithString:self.course.courseIcon] placeholderImage:[UIImage imageNamed:@"默认课程"]];
    self.courseCover.top = cellHeight+15;
    self.courseCover.left = self.courseName.left;
    self.intoClassLiveButton.frame = self.courseCover.frame;
    self.intoClassLiveButton.hidden = !(self.course.classingId > 0);
    

    self.teaSexIcon.top = cellHeight + 22;
    self.teaSexIcon.left = self.courseCover.right+16;

    
    self.teaName.text = [NSString stringWithFormat:@"%@",self.course.teaName];
    [self.teaName sizeToFit];
    self.teaName.left = self.teaSexIcon.right +  5;
    self.teaName.top = (self.teaSexIcon.height - self.teaName.height ) * 0.5 + self.teaSexIcon.top;
    cellHeight = self.teaSexIcon.bottom;
    
    self.stuCountIcon.left = self.teaSexIcon.left;
    self.stuCountIcon.top = cellHeight+10;
    
    self.stuCountLabel.text = [NSString stringWithFormat:@"共%d人",self.course.stuCount];
    [self.stuCountLabel sizeToFit];
    self.stuCountLabel.left = self.stuCountIcon.right + 5;
    self.stuCountLabel.top = self.stuCountIcon.top+ (self.stuCountIcon.height - self.stuCountLabel.height)*0.5;
    cellHeight = self.stuCountIcon.bottom;
    
    self.lessonIcon.left = self.stuCountIcon.left;
    self.lessonIcon.top = cellHeight+10;
    
    self.lessonNumLabel1.text = @"已上";
    [self.lessonNumLabel1 sizeToFit];
    self.lessonNumLabel1.left = self.lessonIcon.right+5;
    self.lessonNumLabel1.top = self.lessonIcon.top + (self.lessonIcon.height - self.lessonNumLabel1.height)*0.5;
    
    self.lessonNumLabel2.text = [NSString stringWithFormat:@"%d",self.course.didDoneCount];
    [self.lessonNumLabel2 sizeToFit];
    self.lessonNumLabel2.left = self.lessonNumLabel1.right;
    self.lessonNumLabel2.top = self.lessonNumLabel1.top;

    self.lessonNumLabel3.text = [NSString stringWithFormat:@"/%d节",self.course.tatolCount];
    [self.lessonNumLabel3 sizeToFit];
    self.lessonNumLabel3.left = self.lessonNumLabel2.right;
    self.lessonNumLabel3.top = self.lessonNumLabel2.top;
    cellHeight = self.lessonIcon.bottom;
    
    cellHeight = MAX(cellHeight, self.courseCover.bottom) + 17;
    self.bottomLine.frame = CGRectMake(0, cellHeight-1, SCREENWIDTH, 1);
    
    return cellHeight;
}

/**
 * 停止滑动时加载网络图片
 **/
- (void)beginLoadImg {
    [self.courseCover sd_setImageWithURL:[NSURL URLWithString:self.course.courseIcon] placeholderImage:[UIImage imageNamed:@"默认课程"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)intoClasslive:(UIButton *)sender {
    LiveViewController *liveRoomVC = [[LiveViewController alloc] initWithRoomName:self.course.courseName
                                                                          coureid:self.course.courseID
                                                                          classid:self.course.classingId];
    [self.viewController.navigationController pushViewController:liveRoomVC animated:YES];

}
@end
