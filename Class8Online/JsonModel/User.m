//
//  User.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "User.h"


@implementation User

- (void)parse:(NSDictionary *)json {
    
    self.avatar = [json stringForKey:@"avatarUrl"];
    self.gender = [json intForKey:@"sex"];
    self.nickName = [json stringForKey:@"nickName"];
    self.realname = [json stringForKey:@"realName"];
    self.stuNo = [json stringForKey:@"studentUid"];
    self.grade = [json stringForKey:@"uname"];
    
}


//登录用户获取用户信息解析
- (id)initLoginUserInfoWithJSON:(NSDictionary *)json
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
        [self userInfoParse:json];
    }
    
    return self;
}



- (void)userInfoParse:(NSDictionary *)json {

    NSDictionary *userinfo = [json objectForKey:@"personaldata"];
    
    self.avatar = [userinfo stringForKey:@"avatarUrl"];
    self.gender = [userinfo intForKey:@"sex"];
    self.nickName = [userinfo stringForKey:@"nickName"];
    self.realname = [userinfo stringForKey:@"realName"];
    self.city = [userinfo stringForKey:@"resiCity"];
    self.resiAddress = [userinfo stringForKey:@"resiAddress"];
    self.company = [userinfo stringForKey:@"company"];
    
    
//    int biryear = [userinfo intForKey:@"birthYear"];
//    int birMonth = [userinfo intForKey:@"birthMonth"];
//    int birDay = [userinfo intForKey:@"birthDay"];
    
//    NSString *birthDayString = @"";
//    if (biryear >0 && birMonth > 0 && birDay > 0) {
//        birthDayString = [NSString stringWithFormat:@"%d年%d月%d日",biryear,birMonth,birDay];
//    }
//    self.birthDayString = birthDayString;
    
    self.birthday = [userinfo longForKey:@"birthDay"];
    
    self.signature = [userinfo stringForKey:@"signature"];
    self.description__ = [userinfo stringForKey:@"description"];
    self.uid = [userinfo longForKey:@"uid"];
    self.mobile = [userinfo stringForKey:@"mobile"];

    //用户教育信息
    NSDictionary *user_edu = [json objectForKey:@"eduinfo"];
    self.professional = [user_edu stringForKey:@"major"];
    self.schoolName = [user_edu stringForKey:@"university"];
    self.grade = [user_edu stringForKey:@"collegeClassName"];
    self.departments = [user_edu stringForKey:@"college"];
    self.stuNo = [user_edu stringForKey:@"studentid"];
    self.courseCount = [json intForKey:@"coursecount"];
    self.stuCount = [json intForKey:@"coursestudent"];
    self.pfCount = 5.0; //这里暂时写死
}

- (void)dealloc {
    self.resiAddress = nil;
    self.description__ = nil;
    self.nickName = nil;
    self.schoolName = nil;
    self.company = nil;
    self.city = nil;
    self.realname = nil;
    self.avatar = nil;
    self.mobile = nil;
    self.email = nil;
    self.stuNo = nil;
    self.grade = nil;
    self.signature = nil;
    self.pulladdr = nil;
    self.pushaddr = nil;
    self.departments = nil;
    self.professional = nil;
}

//学校主页教师用户信息初始化
- (id)initUserInfoWithJSON:(NSDictionary *)json
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
        [self parseTeaUserInfo:json];
    }
    
    return self;

}

- (void)parseTeaUserInfo:(NSDictionary *)json
{
    self.avatar = [json stringForKey:@"avatarUrl"];
    self.headimageUrl = [json stringForKey:@"headimageUrl"];
    self.gender = [json intForKey:@"sex"];
    self.nickName = [json stringForKey:@"nickName"];
    self.realname = [json stringForKey:@"realName"];
    self.uid = [json longForKey:@"userid"];
    self.teaUid = [json longForKey:@"teacherUid"];
    self.grade = [json stringForKey:@"uname"];
    self.company = [json stringForKey:@"company"];
    self.description__ = [json stringForKey:@"description"];
    self.courseCount = [json intForKey:@"countCourse"];
    self.stuCount = [json intForKey:@"countStudent"];
    self.pfCount = [json floatForKey:@"avgScore"];
    self.organization = [json stringForKey:@"company"];
}

@end


const int userListCount = 5;
@implementation UserList

- (void)dealloc {
    self.list = nil;
}




- (void)parse:(NSDictionary *)json {
    NSArray *stuList = [[json objectForKey:@"result"] arrayForKey:@"students"];
    
    NSMutableArray *tmpUserList = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in stuList) {
        User *u = [[User alloc] initWithJSON:dic];
        [tmpUserList addObject:u];
    }
    self.list = tmpUserList;
    if (self.list.count < userListCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
}


- (id)initWithSchoolUserList:(NSDictionary *)json
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
        
        [self parseSchoolUserList:json];
    }
    
    return self;

}

- (void)parseSchoolUserList:(NSDictionary *)json
{
//    NSArray *stuList = [[json objectForKey:@"result"] arrayForKey:@"list"];
//    NSMutableArray *tmpUserList = [[NSMutableArray alloc] init];
    NSArray *stuList = [json objectForKey:@"teachers"] ;
    NSMutableArray *tmpUserList = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in stuList) {
        User *u = [[User alloc] initUserInfoWithJSON:dic];
        [tmpUserList addObject:u];
    }
    self.list = tmpUserList;
    if (self.list.count < userListCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }

}

/**
 * 初始化全部教师列表
 **/
- (id)initWithSchoolAllTeachersUserList:(NSDictionary *)json
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
        
        [self parseSchoolAllTeachersUserList:json];
    }
    
    return self;

}

- (void)parseSchoolAllTeachersUserList:(NSDictionary *)json
{
    NSDictionary *teaDict = [json objectForKey:@"result"];
    NSArray *teaList = [teaDict objectForKey:@"list"];
    NSArray *stuList = [[json objectForKey:@"result"] arrayForKey:@"list"];
    
    NSMutableArray *tmpUserList = [[NSMutableArray alloc] init];
//    NSArray *stuList = [json objectForKey:@"teachers"] ;
//    NSMutableArray *tmpUserList = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in stuList) {
        User *u = [[User alloc] initUserInfoWithJSON:dic];
        [tmpUserList addObject:u];
    }
    self.list = tmpUserList;
    if (self.list.count < userListCount) {
        self.hasMore = NO;
    }else {
        self.hasMore = YES;
    }
    
}

- (void)addUserList:(UserList *)uList
{
    if (uList.list.count > 0) {
        [self.list addObjectsFromArray:uList.list];
    }
    self.hasMore = uList.hasMore;
}
@end