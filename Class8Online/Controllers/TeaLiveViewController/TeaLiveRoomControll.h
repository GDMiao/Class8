//
//  TeaLiveRoomControll.h
//  Class8Online
//
//  Created by chuliangliang on 15/11/24.
//  Copyright © 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeaLiveControllDelegate.h"

@interface TeaLiveRoomControll : NSObject
- (id)initWithCourseID:(long long) courseid classID:(long long)classid;
    
@property (weak, nonatomic) id<TeaLiveControllDelegate>delegate;
@property (assign, nonatomic) long long courseID,classID;
@property (assign, nonatomic) TeaLiveRoomSatus roomStatus;
@property (assign, nonatomic) CurrentClassModel classModel;

/**
 * isReconnect 是否重新连接之后 进入课堂
 **/
- (void)intoClassRoom:(BOOL)isReconnect;


/**
 * 离开课堂
 **/
- (void)leaveClassRoom;


/**
 * 课堂状态-> 上课/下课
 **/
- (void)classBeginOrEnd;
@end
