//
//  CourseWareListView.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassRoomEventModel.h"
@interface CourseWareListView : UIView
- (id)initWithFrame:(CGRect)frame atTableViewData:(NSArray *)data;

#pragma mark-
#pragma mark- 添加/删除/关闭课件 这里这负责列表数据同步 关闭课件不在这里处理
- (void)updateCourseWare:(AddCourseWareModel *)cwModel;

#pragma mark-
#pragma mark- 下课清缓存
- (void)classOver;

@end
