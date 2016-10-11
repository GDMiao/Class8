//
//  BestCourseCell.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/15.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BestCourseCell.h"
#import "UIImageView+WebCache.h"
#import "CourseModel.h"

@implementation BestCourseCell


+ (BestCourseCell *)shareCourseCell
{
    static BestCourseCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BestCourseCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.bestCourseImgView = nil;
    self.bestTitleL = nil;
    self.teaImg = nil;
    self.lessonsImg = nil;
    self.teaNameL = nil;
    self.lessonsL = nil;
    self.currentNum = nil;
    self.totalNum = nil;
    self.bottomline = nil;
    self.course = nil;
}

- (void)awakeFromNib {
    // Initialization code
}

- (CGFloat)setCellContentModel:(CourseModel *)course
{
    cellHeight = 0;
    self.course = course;
    self.bestCourseImgView.top = 16;
    self.bestCourseImgView.left = 20.0;
    [self.bestCourseImgView sd_setImageWithURL:[NSURL URLWithString:self.course.courseIcon] placeholderImage:[UIImage imageNamed:@"默认课程"]];

    //课程名
    self.bestTitleL.text = self.course.courseName;
    [self.bestTitleL sizeToFit];
    self.bestTitleL.left = self.bestCourseImgView.right+12;
    self.bestTitleL.top = 16;
    self.bestTitleL.width = SCREENWIDTH - self.bestTitleL.left-20;

    self.teaImg.left = self.bestTitleL.left;
    self.teaImg.top = self.bestTitleL.bottom + 10;

    self.teaNameL.text =self.course.teaName;
    [self.teaNameL sizeToFit];
    self.teaNameL.top = self.teaImg.top + (self.teaImg.height - self.teaNameL.height) * 0.5;
    self.teaNameL.left = self.teaImg.right + 5;
    
    self.lessonsImg.top = self.teaNameL.bottom + 8;
    self.lessonsImg.left = self.teaImg.left;
    
    //进度
    self.lessonsL.text = @"已上";
    [self.lessonsL sizeToFit];
    self.lessonsL.top = self.lessonsImg.top + (self.lessonsImg.height - self.teaNameL.height) * 0.5;
    self.lessonsL.left = self.lessonsImg.right + 5;
    
    self.currentNum.text = [NSString stringWithFormat:@"%d",self.course.didDoneCount];
    [self.currentNum sizeToFit];
    self.currentNum.top = self.lessonsL.top;
    self.currentNum.left = self.lessonsL.right;
    
    self.totalNum.text = [NSString stringWithFormat:@"/%d节",self.course.tatolCount];
    [self.totalNum sizeToFit];
    self.totalNum.top = self.currentNum.top;
    self.totalNum.left = self.currentNum.right;
    
    cellHeight = self.bestCourseImgView.bottom+18;

    
    self.bottomline.frame = CGRectMake(0, cellHeight-1, SCREENWIDTH, 1);
    return cellHeight;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
