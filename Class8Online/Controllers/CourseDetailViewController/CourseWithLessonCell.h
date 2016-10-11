//
//  CourseWithLessonCell.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LessonsModel;
@interface CourseWithLessonCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UIImageView *lessonImgView;

@property (weak, nonatomic) IBOutlet UILabel *teaNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *horizontalLine; //水平线
@property (weak, nonatomic) IBOutlet UIImageView *lessonPIcon;
@property (weak, nonatomic) IBOutlet UIImageView *lesttonTIcon;
@property (weak, nonatomic) IBOutlet UILabel *lessonNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lessonDateLabel;
@property (strong, nonatomic) NSString *lessonImgURl,*teaName,*avatarURL;

@property (strong, nonatomic) LessonsModel *lessonModel;
+ (CourseWithLessonCell *)shareCourseWithLessonCell;
- (CGFloat )setCellContentModel:(LessonsModel *)lesson;
@end
