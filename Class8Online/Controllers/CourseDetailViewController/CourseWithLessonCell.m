//
//  CourseWithLessonCell.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CourseWithLessonCell.h"
#import "LessonsModel.h"
#import "UIImageView+WebCache.h"

@implementation CourseWithLessonCell


- (void)dealloc
{

    self.horizontalLine = nil;
    self.teaNameLabel = nil;
    self.lessonNameLabel = nil;
    self.lessonPIcon = nil;
    self.lesttonTIcon = nil;
    self.lessonDateLabel = nil;
    self.lessonModel = nil;
    self.lessonImgURl = nil;
}

+ (CourseWithLessonCell *)shareCourseWithLessonCell
{
    static CourseWithLessonCell *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CourseWithLessonCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}


- (void)awakeFromNib {
    // Initialization code

}

- (CGFloat )setCellContentModel:(LessonsModel *)lesson
{
    cellHeight = 0;

    self.lessonModel = lesson;
    
    self.lessonImgView.left = 12;
    self.lessonImgView.top = 17;
    [self.lessonImgView sd_setImageWithURL:[NSURL URLWithString:self.avatarURL] placeholderImage:[UIImage imageNamed:@"默认课程"]];
    
    self.lessonNameLabel.text = self.lessonModel.lessonsName;
    [self.lessonNameLabel sizeToFit];
    self.lessonNameLabel.left = self.lessonImgView.right + 12;
    self.lessonNameLabel.top = 20;
    self.lessonNameLabel.width = SCREENWIDTH - self.lessonNameLabel.left -10;
    
    self.lessonPIcon.left = self.lessonNameLabel.left;
    self.lessonPIcon.top = self.lessonNameLabel.bottom + 12;
    if (![self.teaName isEqualToString:@""]) {
        self.teaNameLabel.text = self.teaName;
    }else{
        self.teaNameLabel.text = @"      ";
    }
    
    [self.teaNameLabel sizeToFit];
    self.teaNameLabel.left = self.lessonPIcon.right + 10;
    self.teaNameLabel.top = self.lessonNameLabel.bottom + 10;
    self.teaNameLabel.width = SCREENWIDTH - self.teaNameLabel.left -10;
    
    self.lesttonTIcon.left = self.lessonPIcon.left;
    self.lesttonTIcon.top = self.lessonPIcon.bottom + 14;
    
    self.lessonDateLabel.text = self.lessonModel.lessonsBeginTime;
    [self.lessonDateLabel sizeToFit];
    self.lessonDateLabel.left = self.lesttonTIcon.right + 10;
    self.lessonDateLabel.top = self.teaNameLabel.bottom + 10;
    
    self.horizontalLine.top = self.lessonImgView.bottom + 16;
    self.horizontalLine.left = 0;
    self.horizontalLine.width = SCREENWIDTH;
    
    
    
    cellHeight = self.lessonImgView.bottom + 17;
    
    return cellHeight;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

}

@end
