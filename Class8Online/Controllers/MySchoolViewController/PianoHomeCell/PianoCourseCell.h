//
//  PianoCourseCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PianoCourseCell : UITableViewCell
{
    CGFloat height;
}
@property (weak, nonatomic) IBOutlet UIView *sectionView;



+ (PianoCourseCell *)sharCourseCell;

- (CGFloat)setCourseCellContent:(NSString *)title sectionHidden:(BOOL)ishidden;

@end
