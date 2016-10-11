//
//  UserConterCell.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/16.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserCenterCellDelegate <NSObject>

@optional
- (void)userCenterCellMoreCourse;
@end

@class CourseModel;
@class User;
@interface UserCenterCell : UITableViewCell
{
    CGFloat cellHeight;
}

@property (weak, nonatomic) IBOutlet UIView *courseView;
@property (weak, nonatomic) IBOutlet UIImageView *courseIcon;
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *userTypeDesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *courseProIcon;
@property (weak, nonatomic) IBOutlet UILabel *courseProLabel1;
@property (weak, nonatomic) IBOutlet UILabel *courseProLabel2;

@property (weak, nonatomic) IBOutlet UILabel *isLiveOrRecord;
@property (weak, nonatomic) IBOutlet UIImageView *courseLine;

@property (weak, nonatomic) IBOutlet UIImageView *priceBgImg;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;



@property (weak, nonatomic) id<UserCenterCellDelegate>cellDelegate;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) CourseModel *course;
@property (nonatomic, assign) BOOL isTeaCell;
@property (nonatomic, strong) NSString *cellStyleTxt;
+ (UserCenterCell *)shareCourseCell;
- (CGFloat)setCreatCourseCell:(NSString *)model;
- (CGFloat)setCellContent:(CourseModel *)courseModel withCellStyleTxt:(NSString *)cellTxt userinfoModel:(User *)u;
@end
