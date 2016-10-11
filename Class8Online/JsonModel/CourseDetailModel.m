//
//  CourseDetailModel.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CourseDetailModel.h"

@implementation CourseDetailModel
- (void)dealloc
{
    self.courseName = nil;
    self.courseCoverURL = nil;
    self.courseBeginTime = nil;
    self.courseEndTime = nil;
    self.schoolName = nil;
    self.teaName = nil;
    self.teaAvatar = nil;
    self.courseDescription = nil;
}
- (void)parse:(NSDictionary *)json
{
    
    NSDictionary *resultDic = [json objectForKey:@"result"];
    
    self.canEnterClass = [resultDic boolForKey:@"canEnterClassid"];
    
    self.courseID = [resultDic longForKey:@"courseid"];
    self.teaUid = [resultDic longForKey:@"teacherUid"];
    self.currentClassID = [resultDic longForKey:@"canEnterClassid"]; //canEnterClassid
    
    self.coursePrice = [resultDic floatForKey:@"priceTotal"];
    self.courseName = [resultDic stringForKey:@"courseName"];
    self.courseCoverURL = [resultDic stringForKey:@"coverUrl"];
    self.courseBeginTime = [resultDic stringForKey:@"courseStartTime"];
    self.courseEndTime = [resultDic stringForKey:@"courseEndTime"];
    self.schoolName = [resultDic stringForKey:@"schoolName"];
    self.teaAvatar = [resultDic stringForKey:@"teacherAvatarUrl"];
    self.teaName = [resultDic stringForKey:@"teacherName"];
    self.courseDescription = [resultDic stringForKey:@"description"];
    
    
    
    self.studentTotal = [resultDic intForKey:@"studentTotal"];
    self.lessonTotal = [resultDic intForKey:@"classTotal"];
    
    self.avgScore = [resultDic floatForKey:@"avgScore"];
    self.signupStatus = [resultDic intForKey:@"singupStatus"];
    self.canEnterClassID = [resultDic longForKey:@"canEnterClassid"];
    self.classHadFinished = [resultDic intForKey:@"classHadFinished"];

}

- (id)initCourseDetailJosn:(NSDictionary *)json
{
    self.code_ = 500;
    self = [self init];
    if(self && json && [json isKindOfClass:[NSDictionary class]])
    {
        self.json_ =json;
        //代码
        id code = [self.json_ objectForKeyIgnoreNull:@"status"];
        if(code)
        {
            @try {
                self.code_= [[code description] intValue];
            }
            @catch (NSException *exception) {
            }
        }
        //消息
        id message = [self.json_ objectForKeyIgnoreNull:@"message"];
        if (message) {
            @try {
                self.message_= [message description];
            }
            @catch (NSException *exception) {
            }
        }else {
            self.message_ = CSLocalizedString(@"json_error_unknown");
        }
        self.SysCurMills = [self.json_ doubleForKey:@"SysCurMills"];
        //数据内容
        
        [self parse:json];
    }
    
    return self;
}


@end
