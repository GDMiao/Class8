//
//  BestCourseCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/3/15.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CourseModel;
@interface BestCourseCell : UITableViewCell
{
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UIImageView *bestCourseImgView;
@property (weak, nonatomic) IBOutlet UILabel *bestTitleL;
@property (weak, nonatomic) IBOutlet UIImageView *teaImg;
@property (weak, nonatomic) IBOutlet UIImageView *lessonsImg;
@property (weak, nonatomic) IBOutlet UILabel *teaNameL;
@property (weak, nonatomic) IBOutlet UILabel *lessonsL;
@property (weak, nonatomic) IBOutlet UILabel *currentNum;
@property (weak, nonatomic) IBOutlet UILabel *totalNum;
@property (weak, nonatomic) IBOutlet UIView *bottomline;
@property (assign, nonatomic) CourseModel *course;



+ (BestCourseCell *)shareCourseCell;
- (CGFloat)setCellContentModel:(CourseModel *)course;
@end
