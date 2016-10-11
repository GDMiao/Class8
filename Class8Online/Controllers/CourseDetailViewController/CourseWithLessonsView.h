//
//  CourseWithLessonsView.h
//  Class8Online
//
//  Created by chuliangliang on 15/5/14.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LessonsList;
@interface CourseWithLessonsView : UIView
@property (strong, nonatomic) NSString *lessonImgURl,*teaName,*avatarURL;
- (void)updateClassInfo:(LessonsList *)cModel;

@end
