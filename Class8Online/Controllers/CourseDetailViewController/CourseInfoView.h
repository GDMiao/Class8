//
//  CourseInfoView.h
//  Class8Online
//
//  Created by chuliangliang on 15/5/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"



@interface IntoClassRoomAnimateButton : UIView
@property (strong, nonatomic) UIImageView *icon1,*icon2;
@property (strong, nonatomic) UIButton *btn;
- (void)addTarget:(id)target action:(SEL)action;
- (void)beginAnimate;
- (void)stopAnimate;
@end

@class CourseDetailModel;
@interface CourseInfoView : UIView
@property (strong, nonatomic) UIImageView *courseCoverImg;
@property (strong, nonatomic) UIImageView *courseCoverImgMask;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) IntoClassRoomAnimateButton *joinClassRoom;
@property (strong, nonatomic) HMSegmentedControl *segmentedControl;

- (void)updateCourseInfo:(CourseDetailModel *)courseModel;
@end
