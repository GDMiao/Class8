//
//  PianoCourseCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CourseModel;
@interface PianoCourseCell : UITableViewCell
{
    CGFloat height;
}
@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (assign, nonatomic) CourseModel *course;


+ (PianoCourseCell *)sharCourseCell;

- (CGFloat)setCourseCellContent:(CourseModel *)course sectionHidden:(BOOL)ishidden;

@end
