//
//  AllCoursesCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/14.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ClassModel;
@interface AllCoursesCell : UITableViewCell
{
    CGFloat height;
}
@property (assign, nonatomic) ClassModel *classmodel;


+ (AllCoursesCell *)sharCourseCell;

- (CGFloat)setCourseCellContent:(ClassModel *)model;
@end
