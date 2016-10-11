//
//  HttpRequest.m
//  IShowCatena
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "HttpRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "ASIDownloadCache.h"
#import "Reachability.h"

@interface HttpRequest ()
{
    ASIHTTPRequest *request_;
    ASIFormDataRequest *fRequest_;
    int timeoutSeconds_;
    NSMutableArray *httpArry;

}
@end

@implementation HttpRequest


-(HttpRequest *) init
{
    self = [super init];
    if(self)
    {
        httpArry = [[NSMutableArray alloc] init];
        
        fRequest_=nil;
        request_=nil;
    }
    return self;
}


-(void)clearDelegatesAndCancel
{
    if (httpArry) {
        [httpArry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ASIHTTPRequest *http = obj;
            [http clearDelegatesAndCancel];
        }];
    }
}
-(void)dealloc
{
    if (httpArry) {
        [httpArry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ASIHTTPRequest *http = obj;
            [http clearDelegatesAndCancel];
        }];
        httpArry = nil;
    }
    
    if (request_) {
        request_ = nil;
    }
    if (fRequest_) {
        fRequest_ = nil;
    }
}


//MD5加密
- (NSString *)md5HexDigest:(NSString*)input
{
    const char *str = [input UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *md5 = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                     r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return md5;
}

-(NSString *) encodeURIComponent:(NSString *)url
{
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)url,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8));
    return outputStr;
}


/**
 * 添加了判断是否强制刷新 GET 请求
 */
-(void) doGet:(NSString *) url
jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
     refresh:(BOOL) refresh
{
//    NSString* openUDID = [OpenUDID value];
    NSString *tmpUrlStr = url;
    NSURL *nsUrl = [NSURL URLWithString:[tmpUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CSLog (@"---http get:%@", tmpUrlStr);
    request_ = [ASIHTTPRequest requestWithURL:nsUrl];
    [httpArry addObject:request_];
    /*
     缓存策略
     */
    [request_ setDownloadCache:[ASIDownloadCache sharedCache]];
    //    if(timeoutSeconds_>0){
    //        [request_ setTimeOutSeconds:timeoutSeconds_];
    //    }
    
    //判断网络是否存在，是否是强制刷新
    if (refresh)
    {
        [request_ setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
    }
    else
    {
        // 每次都向服务器询问是否有新的内容可用，
        // 如果请求失败, 使用cache的数据，即使这个数据已经过期了
        [request_ setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
        //        [request_ setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
        [request_ setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        /**/
        //request.shouldCompressRequestBody=YES;
        
    }
   	[request_ setDelegate:jsonResponseDelegate];
    [request_ startAsynchronous];
}


/**
 * POST 求情
 */
-(void) doPost:(NSString *) url
       params:(NSMutableDictionary *)params
jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSURL *nsUrl = [NSURL URLWithString:url];
    
    NSMutableString *urlLog = [[NSMutableString alloc] initWithString:url];
//    [urlLog appendString:@"?foo=1"];
//    [urlLog appendFormat:@"&ikaolaVersion=%@",[self getCFBundleVersion]];
//    NSString* openUDID = [OpenUDID value];
//    [urlLog appendFormat:@"&imei=%@",openUDID];
    fRequest_ = [ASIFormDataRequest requestWithURL:nsUrl];
    [httpArry addObject:fRequest_];
    //request.shouldCompressRequestBody=YES;
//    [fRequest_ setPostValue:[self encodeURIComponent:[self getCFBundleVersion]] forKey:@"ikaolaVersion"];
//    [fRequest_ setPostValue:openUDID forKey:@"imei"];
    NSArray *aryKeys= [params allKeys];
    for (id key in aryKeys)
    {
        id idValue= [params objectForKeyIgnoreNull:key];
        if (!idValue)
        {
            idValue = @"";
        }
        //如果key为file，则按照文件方式处理上传，否则为普通的字符串值。
        if(key && [key isEqualToString:@"file"]){
            [fRequest_ setFile:[idValue description] forKey:[key description]];
        }else{
            [fRequest_ setPostValue:[self encodeURIComponent:[idValue description]] forKey:[key description]];
                        [fRequest_ setPostValue:[idValue description] forKey:[key description]];
        }
        [urlLog appendString:@"&"];
        [urlLog appendString:[key description]];
        [urlLog appendString:@"="];
        [urlLog appendString:[idValue description]];
        
    }
    CSLog (@"---http post:%@", urlLog);
    [fRequest_ setDelegate:jsonResponseDelegate];
    [fRequest_ startAsynchronous];
}

//===================================
// HTTP 请求
//===================================

/**
 * 表单上传
 **/
- (void)upLoadFile:(NSString *)path userid:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate {
    NSString *url = [NSString stringWithFormat:@"%@/up/user_avatar?",BASIC_UPLoad_API];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setFile:path forKey:@"myfile"];
    [request setPostValue:[NSString stringWithFormat:@"%lld",uid] forKey:@"uid"];
    [request setDelegate:jsonResponseDelegate];
    [request startAsynchronous];
}

/**
 *上传用户头像 图片base64
 **/
- (void)uploadUserAvatar:(NSData *)image userId:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *imageBaseString = [image base64Encoding];
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/upload/avatar?",API_HOST,DEVICE_TYPE];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/upload/avatar?",Piano_API_HOST,DEVICE_TYPE];
    [self doPost:Url params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLongLong:uid],@"uid",imageBaseString,@"dataUrl", nil] jsonResponseDelegate:jsonResponseDelegate];

}


//获取课程详情 + 课节信息
- (void)eduPlatformuserid:(long long)uid courseId:(long long)courseid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/detail?",API_HOST,DEVICE_TYPE];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/detail?",Piano_API_HOST,DEVICE_TYPE];
    [self doPost:Url params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLongLong:uid],@"uid",[NSNumber numberWithLongLong:courseid],@"courseid", nil] jsonResponseDelegate:jsonResponseDelegate];
}

//课程详情之 学生列表
- (void)studentList:(int)startCount endRows:(int)rows courseId:(long long)cid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/StudentList?",API_HOST,DEVICE_TYPE];
     NSString *Url = [NSString stringWithFormat:@"%@/%d/StudentList?",Piano_API_HOST,DEVICE_TYPE];
    [self doPost:Url params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLongLong:cid],@"courseid",[NSNumber numberWithInt:startCount],@"start",[NSNumber numberWithInt:rows],@"rows", nil] jsonResponseDelegate:jsonResponseDelegate];

}

/**
 * 课程详情之 课件列表
 **/
- (void)getCourseFileList:(long long) uid courseid:(long long)cid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/getCourseFileList?uid=%lld&courseid=%lld",API_HOST,DEVICE_TYPE,uid,cid];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/getCourseFileList?uid=%lld&courseid=%lld",Piano_API_HOST,DEVICE_TYPE,uid,cid];
    [self doGet:Url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 我的课程列表
 **/
- (void)myCourseList:(int)start listRows:(int)rows userType:(int)uType jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/courseList?uid=%lld&starts=%d&rows=%d&nUserType=%d",API_HOST,DEVICE_TYPE,[UserAccount shareInstance].uid,start,rows,uType];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/courseList?uid=%lld&starts=%d&rows=%d&nUserType=%d",Piano_API_HOST,DEVICE_TYPE,[UserAccount shareInstance].uid,start,rows,uType];
    [self doGet:Url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 修改密码
 **/
- (void)changeUserPassWord:(long long) uid oldPwd:(NSString *)oldP newPwd:(NSString *)np jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mchangepasswordbyold?",API_HOST,DEVICE_TYPE];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mchangepasswordbyold?",Piano_API_HOST,DEVICE_TYPE];
        [self doPost:Url params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLongLong:[UserAccount shareInstance].uid],@"uid",[self md5HexDigest:oldP],@"oldPassword",[self md5HexDigest:np],@"newPassword", nil] jsonResponseDelegate:jsonResponseDelegate];
}

/**
 *  重置密码
 **/
- (void)resetPwd:(NSString *)mobiString mobileVerifySerialid:(NSString *)mvsString verifyCode:(NSString *)codeString strNewPwd:(NSString *)newPwdString
jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobileresetpwd?",API_HOST,DEVICE_TYPE];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobileresetpwd?",Piano_API_HOST,DEVICE_TYPE];
    [self doPost:Url params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:mobiString,@"strMobile",[self md5HexDigest:newPwdString],@"strNewPwd",  mvsString,@"mobileVerifySerialid", codeString,@"verifyCode", nil] jsonResponseDelegate:jsonResponseDelegate];
}


/**
 *获取用户信息
 **/
- (void)getUserInfo:(long long)uid userType:(int)utype jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/eduPlatform/%d/mlistpersonaldata?",@"http://10.5.33.64:8080",DEVICE_TYPE];
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mlistpersonaldata?",API_HOST,DEVICE_TYPE];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mlistpersonaldata?",Piano_API_HOST,DEVICE_TYPE];
    [self doPost:Url params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLongLong:uid],@"uid",[NSNumber numberWithInt:utype],@"userType", nil] jsonResponseDelegate:jsonResponseDelegate];

}

/**
 * 更新用户信息
 **/
- (void)updateUserInfoparams:(NSMutableDictionary *)p jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobileupdatepersonaldata",API_HOST,DEVICE_TYPE];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobileupdatepersonaldata",Piano_API_HOST,DEVICE_TYPE];
    [self doPost:Url params:p jsonResponseDelegate:jsonResponseDelegate];
    
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobileupdatepersonaldata",@"http://10.5.33.227:8080",DEVICE_TYPE];
//    [self doPost:Url params:p jsonResponseDelegate:jsonResponseDelegate];

}

/**
 * 获取手机验证码
 **/
- (void)getuserMobile:(NSString *)telNum numberType:(int)ntpye jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate

{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/msendBindMobileVerifyCode?",API_HOST,DEVICE_TYPE];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/msendBindMobileVerifyCode?",Piano_API_HOST,DEVICE_TYPE];
    [self doPost:Url params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:telNum,@"telnum",[NSNumber numberWithLongLong:[UserAccount shareInstance].uid],@"uid",[NSNumber numberWithInt:ntpye],@"nType",nil] jsonResponseDelegate:jsonResponseDelegate];
}


/**
 * 验证手机验证码 并绑定手机号
 **/
- (void)verifyTelCode:(long long)mobileVerifySerialid userid:(long long)uid telNum:(NSString *)tel telCode:(NSString *)code jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mverifyBindMobile?",API_HOST,DEVICE_TYPE];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mverifyBindMobile?",Piano_API_HOST,DEVICE_TYPE];
    [self doPost:Url params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLongLong:mobileVerifySerialid],@"mobileVerifySerialid",code,@"verifyCode",[NSNumber numberWithLongLong:uid],@"uid",tel,@"telNum",nil] jsonResponseDelegate:jsonResponseDelegate];
}


/**
 * 我的日历 按天获取课程
 * day : 例如day=2015-7-21    8/1/?day=2015-7-21&uid=21931
 **/
- (void)myCalendar:(long long) uid date:(NSString *)day userType:(int)uType jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobilelistCourseByDay?uid=%lld&day=%@&nUserType=%d",API_HOST,DEVICE_TYPE,uid,day,uType];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobilelistCourseByDay?uid=%lld&day=%@&nUserType=%d",Piano_API_HOST,DEVICE_TYPE,uid,day,uType];
    [self doGet:Url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 签到上传图片
 **/
- (void)upLoadPic:(NSString *)picPath courseid:(long long)cid classid:(long long)classid userid:(long long)uid  jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate {
    
    NSString *url = [NSString stringWithFormat:@"%@/%lld/%d?",SignPicUpLoad,cid,0/*classid*/];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setFile:picPath forKey:@"myfile"];
    [request setPostValue:[NSString stringWithFormat:@"%lld.jpg",uid] forKey:@"name"];
    [request setDelegate:jsonResponseDelegate];
    [request startAsynchronous];
}


/**
 * 获取用户教育信息
 **/
- (void)getUserEduInfo:(long long) uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobilelistpersonaledudata?uid=%lld",API_HOST,DEVICE_TYPE,uid];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobilelistpersonaledudata?uid=%lld",Piano_API_HOST,DEVICE_TYPE,uid];
    [self doGet:Url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}


/**
 *获取消息中心消息列表
 **/
- (void)getNoticeMessage:(long long)uid msgStart:(int)start msgLoadCount:(int)count msgType:(int)mType jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    /**
     * 参数说明  notread:   0 未读 1 已读 2：全部
     **/
//    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobilemessageAll?uid=%lld&notread=2&start=%d&count=%d&type=%d",API_HOST,DEVICE_TYPE,uid,start,count,mType];
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobilemessageAll?uid=%lld&notread=2&start=%d&count=%d&type=%d",Piano_API_HOST,DEVICE_TYPE,uid,start,count,mType];
    [self doGet:Url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 标记消息已经阅读
 **/
- (void)noticeMessageDidRead:(long long)msgID userid:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *Url = [NSString stringWithFormat:@"%@/%d/mobileshowMessagePage?uid=%lld&messageid=%lld",API_HOST,DEVICE_TYPE,uid,msgID];
    [self doGet:Url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 *删除消息
 **/
- (void)delNoticeMessage:(long long)msgID userid:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *Url = [NSString stringWithFormat:@"%@/eduPlatform/%d/mobileDeleteMessage?uid=%lld&messageid=%lld",API_HOST,DEVICE_TYPE,uid,msgID];
    NSString *Url = [NSString stringWithFormat:@"%@/eduPlatform/%d/mobileDeleteMessage?uid=%lld&messageid=%lld",Piano_API_HOST,DEVICE_TYPE,uid,msgID];
    [self doGet:Url jsonResponseDelegate:jsonResponseDelegate refresh:YES];

}

/**
 * 获取教师首页最新课程
 * page 页码，目前可固定为1
 * rows 条数，目前可固定为6
 **/
- (void)getTeaLastCourse:(long long)teaUID pageNum:(int)page rows:(int)rows jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/getLastestCourses?teacherUid=%lld&pageNum=%d&pageSize=%d",API_HOST,DEVICE_TYPE,teaUID,page,rows];
    NSString *url = [NSString stringWithFormat:@"%@/%d/getLastestCourses?teacherUid=%lld&pageNum=%d&pageSize=%d",Piano_API_HOST,DEVICE_TYPE,teaUID,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 获取教师全部课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 **/
- (void)getTeaAllCourse:(long long)teaUID pageNum:(int)page rows:(int)rows jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/getAllCourses?teacherUid=%lld&pageNum=%d&pageSize=%d",API_HOST,DEVICE_TYPE,teaUID,page,rows];
    NSString *url = [NSString stringWithFormat:@"%@/%d/getAllCourses?teacherUid=%lld&pageNum=%d&pageSize=%d",Piano_API_HOST,DEVICE_TYPE,teaUID,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 获取学生正在学习的课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 **/
- (void)getstuLearningCourse:(long long)stuUID pageNum:(int)page rows:(int)rows jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/getLearningCourses?studentUid=%lld&pageNum=%d&pageSize=%d",API_HOST,DEVICE_TYPE,stuUID,page,rows];
    NSString *url = [NSString stringWithFormat:@"%@/%d/getLearningCourses?studentUid=%lld&pageNum=%d&pageSize=%d",Piano_API_HOST,DEVICE_TYPE,stuUID,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];

}

/**
 * 获取学生已经学完的课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 **/
- (void)getstuLearnedCourse:(long long)stuUID pageNum:(int)page rows:(int)rows jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/getLearnedCourses?studentUid=%lld&pageNum=%d&pageSize=%d",API_HOST,DEVICE_TYPE,stuUID,page,rows];
    NSString *url = [NSString stringWithFormat:@"%@/%d/getLearnedCourses?studentUid=%lld&pageNum=%d&pageSize=%d",Piano_API_HOST,DEVICE_TYPE,stuUID,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
    
}

/**
 * 获取学校基本信息
 */
- (void)getSchoolInfo:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/getSchoolInfo?uid=%lld",API_HOST,DEVICE_TYPE,uid];
    NSString *url = [NSString stringWithFormat:@"%@/%d/getSchoolInfo?uid=%lld",Piano_API_HOST,DEVICE_TYPE,uid];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 学校公告接口
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 */
- (void)getSchoolPublicInfo:(long long)schoolUID pageNum:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/school/messages?schoolId=%lld&page=%d&rows=%d",API_HOST,DEVICE_TYPE,schoolUID,page,rows];
    NSString *url = [NSString stringWithFormat:@"%@/%d/school/messages?schoolId=%lld&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,schoolUID,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 学校课程接口
 * sort 排序规则(非必需), 1：热门课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 */
- (void)getschoolCourseInfo:(long long)schoolUID sort:(int)sort pageNum:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = nil;
    if (sort > 0) {
//        url = [NSString stringWithFormat:@"%@/%d/school/courses?schoolId=%lld&sort=%d&page=%d&rows=%d",API_HOST,DEVICE_TYPE,schoolUID,sort,page,rows];
        url = [NSString stringWithFormat:@"%@/%d/school/courses?schoolId=%lld&sort=%d&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,schoolUID,sort,page,rows];
    }else
    {
//        url = [NSString stringWithFormat:@"%@/%d/school/courses?schoolId=%lld&page=%d&rows=%d",API_HOST,DEVICE_TYPE,schoolUID,page,rows];
        url = [NSString stringWithFormat:@"%@/%d/school/courses?schoolId=%lld&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,schoolUID,page,rows];
    }
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}
/**
 * 学校老师接口
 * sort 排序规则(非必需), 1：热门课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 */
- (void)getSchoolTeacherInfo:(long long)schoolUID sort:(int)sort pageNum:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    
    NSString *url = nil;
    if (sort > 0) {
//        url = [NSString stringWithFormat:@"%@/%d/school/teachers?schoolId=%lld&sort=%d&page=%d&rows=%d",API_HOST,DEVICE_TYPE,schoolUID,sort,page,rows];
        url = [NSString stringWithFormat:@"%@/%d/school/teachers?schoolId=%lld&sort=%d&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,schoolUID,sort,page,rows];
    }else
    {
//        url = [NSString stringWithFormat:@"%@/%d/school/teachers?schoolId=%lld&page=%d&rows=%d",API_HOST,DEVICE_TYPE,schoolUID,page,rows];
        url = [NSString stringWithFormat:@"%@/%d/school/teachers?schoolId=%lld&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,schoolUID,page,rows];

    }
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}


/**
 *获取课程的课节目录
 **/
- (void)getCourseLessons:(long long)courseID jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/course/classs?courseid=%lld",API_HOST,DEVICE_TYPE,courseID];
    NSString *url = [NSString stringWithFormat:@"%@/%d/course/classs?courseid=%lld",Piano_API_HOST,DEVICE_TYPE,courseID];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 *获取课程评论 course/comments
 **/
- (void)getCourseComment:(long long)courseID page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/course/comments?courseid=%lld&page=%d&rows=%d",API_HOST,DEVICE_TYPE,courseID,page,rows];
    NSString *url = [NSString stringWithFormat:@"%@/%d/course/comments?courseid=%lld&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,courseID,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}


/**
 * 获取推荐课程
 **/
- (void)getPianoRecommendCourse_jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/getRecommendCourses",Piano_API_HOST,DEVICE_TYPE];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 获取推荐老师
 **/
- (void)getPianoNewRecommendTea_jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/getNewRecommendTeachers",Piano_API_HOST,DEVICE_TYPE];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}


/**
 * 获取全部课程 和 老师
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 * String keyword
 * Double minPrice
 * Double minPrice
 * String startTime
 * String endTime
 */
- (void)getPianogetCoursesByConditionwithKeyWord:(NSString *)keyword minPrice:(double)minprice maxPrice:(double)maxprice startTime:(NSString *)starttime endTime:(NSString *)endtime page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
//    NSString *url = [NSString stringWithFormat:@"%@/%d/course/comments?courseid=%lld&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,courseID,page,rows];
    NSString *url = [NSString stringWithFormat:@"%@/%d/getCoursesByCondition?keyword=%@&minPrice=%f&maxPrice=%f&startTime=%@&endTime=%@&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,keyword,minprice,maxprice,starttime,endtime,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 获取全部老师  http://piano.class8.com/1/getTeachersByCondition?teacherName=&pageNum=&pageSize
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 * String teacherName
 
 */
- (void)getPianogetTeachersByConditionwithTeacherName:(NSString *)teacherName
                                                 page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/getTeachersByCondition?teacherName=%@&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,teacherName,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/**
 * 获取我创建的课程
 * uid:用户id(必须)
 * status:课程状态 0:全部 1:已完成 2:已取消
 * page:页码 默认为1
 * rows:条目，默认为10
 *.返回值：
 *.status:
 0:成功
 -100:服务器端错误
 *.result:
 只有当status为0时返回需要的数据
 ****/
- (void)getPianoMyCreatedCoursesWith:(long long)uid Status:(int)status
                                page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/getMyCreatedCourses?uid=%lld&status=%d&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,uid,status,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}
/**
 * 获取我订购的课程
 * uid:用户id(必须)
 * status:课程状态 0:全部 1:已完成 2:已取消
 * page:页码 默认为1
 * rows:条目，默认为10
 *
 *.返回值：
 *.status:
 0:成功
 -100:服务器端错误
 *.result:
 只有当status为0时返回需要的数据
 ***/
- (void)getPianoMyOrderedCoursesWith:(long long)uid Status:(int)status
                                page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/getMyOrderedCourses?uid=%lld&status=%d&page=%d&rows=%d",Piano_API_HOST,DEVICE_TYPE,uid,status,page,rows];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}
/**
 *查询订单的支付信息
	*url:http://xxx/{mobileType}/getOrderPayResult
	*参数列表
 *status:
 0:成功
 -1:订单不存在
 -100:服务器端错误
 *order:订单的信息
 *
 **/
- (void)getInquiryOrderInfoWithCourseid:(NSString *)orderID jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/getOrderPayResult?courseid=%@",Piano_API_HOST,DEVICE_TYPE,orderID];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}



/**
 * 提交订单  *url:http://xxx/{mobileType}/commitOrder
 * 参数列表
 * uid:用户id
 * courseid:课程id
 * classid:课节id
 *返回值
 *status:
 0:成功
 -1:学校已经把学生加入课程，不需要报名
 -2:学生已经报名了，不用重复报，或者已经付款了
 -3:课程id对应的课程不存在
 -4:报名人数已满
 -100:服务器端错误
 *orderid:订单id，只有status为0时返回
 *course:课程基本信息，只有status为0时返回
 **/
- (void)getPianoCommitOrderWithUid:(long long)uid Courseid:(long long)courseid Classid:(long long)classid jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/commitOrder?uid=%lld&courseid=%lld&classid=%lld",Piano_API_HOST,DEVICE_TYPE,uid,courseid,classid];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}

/*
 * 支付订单 *url:http://xxx/{mobileType}/payOrder
 *参数列表
 *uid：用户id
 *orderid:订单id
 *返回值
 *status:
 0:成功
 -1:订单不存在
 -100:服务器端错误
 *params:调用微信支付需要的参数
 *
 */
- (void)getPianopayOrderWithUid:(long long)uid OrderIDStr:(NSString *)orderid jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/payOrder?uid=%lld&orderid=%@",Piano_API_HOST,DEVICE_TYPE,uid,orderid];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}


/*
 * 零元课程立即报名
 url:http://xxx/{mobileType}/signup
 params:
 uid:用户id
 courseid:课程id
 classid:课节id
 return:
 0:可以报名
 1:报名成功
 -1:学校已经把学生加入了课程，不需要报名
 -2:学生已经报名，不用重复报，或者已经付款了
 -3:课程id对应的课程已经不存在
 -4:报名人数已满
 -100:服务器错误
 */
- (void)getPianoImmediatelySignUpWithUid:(long long)uid Courseid:(long long)courseid Classid:(long long)classid jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
{
    NSString *url = [NSString stringWithFormat:@"%@/%d/signup?uid=%lld&courseid=%lld&classid=%lld",Piano_API_HOST,DEVICE_TYPE,uid,courseid,classid];
    [self doGet:url jsonResponseDelegate:jsonResponseDelegate refresh:YES];
}


@end
