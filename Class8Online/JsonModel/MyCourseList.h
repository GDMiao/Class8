//
//  MyCourseList.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/24.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"
#import "CourseModel.h"

@interface MyCourseList : JSONModel
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, assign) BOOL hasMore;
- (void)addCourseList:(MyCourseList *)cList;
@end
