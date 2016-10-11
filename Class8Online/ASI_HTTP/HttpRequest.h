//
//  HttpRequest.h
//  IShowCatena
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "HttpRequestDelegate.h"
#import "NSDictionary+JSON.h"
#import "ASIHTTPRequest+JSON.h"



#define DEVICE_TYPE 1 //http 设备类型 iOS 固定为 1


@interface HttpRequest : NSObject
/**
 * 上传头像 弃用
 **/
#warning 弃用....
- (void)upLoadFile:(NSString *)path userid:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 *上传用户头像 图片base64
 **/
- (void)uploadUserAvatar:(NSData *)image userId:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

    
/**
 *获取课程详情 + 课节信息
 **/
//- (void)eduPlatform:(long long)courseid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;
- (void)eduPlatformuserid:(long long)uid courseId:(long long)courseid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 课程详情之 学生列表
 **/
- (void)studentList:(int)startCount endRows:(int)rows courseId:(long long)cid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;


/**
 * 课程详情之 课件列表
 **/
- (void)getCourseFileList:(long long) uid courseid:(long long)cid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 我的课程列表
 * userType: nUserType 30 表示学生，40表示老师
 **/
- (void)myCourseList:(int)start listRows:(int)rows userType:(int)uType jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;


/**
 * 修改密码 http://10.5.33.64:8080
 **/
- (void)changeUserPassWord:(long long) uid oldPwd:(NSString *)oldP newPwd:(NSString *)np jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 *  重置密码
 **/
- (void)resetPwd:(NSString *)mobiString mobileVerifySerialid:(NSString *)mvsString verifyCode:(NSString *)codeString strNewPwd:(NSString *)newPwdString
jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;


/**
 *获取用户信息
 **/
- (void)getUserInfo:(long long)uid userType:(int)utype jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 更新用户信息
 **/
- (void)updateUserInfoparams:(NSMutableDictionary *)p jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 获取手机验证码  1 ==> 手机注册  2==>绑定手机  11 ==> 找回密码 12==> 更改手机号
 **/
- (void)getuserMobile:(NSString *)telNum numberType:(int)ntpye jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 验证手机验证码 并绑定手机号
 **/
- (void)verifyTelCode:(long long)mobileVerifySerialid userid:(long long)uid telNum:(NSString *)tel telCode:(NSString *)code jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 我的日历 按天获取课程
 * day : 例如day=2015-7-21    8/1/mobilelistCourseByDay?day=2015-7-21&uid=21931
 * userType: nUserType 30 表示学生，40表示老师
 **/
- (void)myCalendar:(long long) uid date:(NSString *)day userType:(int)uType jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;


/**
 * 签到上传图片
 **/
- (void)upLoadPic:(NSString *)picPath courseid:(long long)cid classid:(long long)classid userid:(long long)uid  jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 获取用户教育信息
 **/
- (void)getUserEduInfo:(long long) uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;


/**
 *获取消息中心消息列表
 * type : 消息类型  0:个人私信、 50:公开信-课程消息、60:公开信-教务消息、 100:公开信-全站系统消息
 **/
- (void)getNoticeMessage:(long long)uid msgStart:(int)start msgLoadCount:(int)count msgType:(int)mType jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 标记消息已经阅读
 **/
- (void)noticeMessageDidRead:(long long)msgID userid:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 *删除消息
 **/
- (void)delNoticeMessage:(long long)msgID userid:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 获取教师首页最新课程
 * page 页码，目前可固定为1
 * rows 条数，目前可固定为6
 **/
- (void)getTeaLastCourse:(long long)teaUID pageNum:(int)page rows:(int)rows jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 获取教师全部课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 **/
- (void)getTeaAllCourse:(long long)teaUID pageNum:(int)page rows:(int)rows jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 获取学生正在学习的课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 **/
- (void)getstuLearningCourse:(long long)stuUID pageNum:(int)page rows:(int)rows jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
* 获取学生已经学完的课程
* page 页码，从1开始。没有0页
* rows 条数，一页显示的条数
**/
- (void)getstuLearnedCourse:(long long)stuUID pageNum:(int)page rows:(int)rows jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 *  获取学校基本信息
 */
- (void)getSchoolInfo:(long long)uid jsonResponseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate
;

/**
 * 学校公告接口
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 */
- (void)getSchoolPublicInfo:(long long)schoolUID pageNum:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;
/**
 * 学校课程接口
 * sort 排序规则(非必需), 1：热门课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 */
- (void)getschoolCourseInfo:(long long)schoolUID sort:(int)sort pageNum:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 学校老师接口
 * sort 排序规则(非必需), 1：热门课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 */
- (void)getSchoolTeacherInfo:(long long)schoolUID sort:(int)sort pageNum:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 *获取课程的课节目录
 **/
- (void)getCourseLessons:(long long)courseID jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 *获取课程评论 course/comments
 **/
- (void)getCourseComment:(long long)courseID page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/////////////////////////////////////////////////////////////////////////////

/**
 * 获取推荐课程
 **/
- (void)getPianoRecommendCourse_jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 获取推荐老师
 **/
- (void)getPianoNewRecommendTea_jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;


/**
 * 获取全部课程
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 * String keyword
 * Double minPrice
 * Double maxPrice
 * String startTime
 * String endTime
 */
- (void)getPianogetCoursesByConditionwithKeyWord:(NSString *)keyword
                                        minPrice:(double)minprice maxPrice:(double)maxprice startTime:(NSString *)starttime endTime:(NSString *)endtime page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 获取全部老师  http://piano.class8.com/1/getTeachersByCondition?teacherName=&pageNum=&pageSize
 * page 页码，从1开始。没有0页
 * rows 条数，一页显示的条数
 * String teacherName

 */
- (void)getPianogetTeachersByConditionwithTeacherName:(NSString *)teacherName
                                         page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

/**
 * 获取我创建的课程
 * uid:用户id(必须)
 * status:课程状态 0:全部 1:已完成 2:已取消
 * page:页码 默认为1
 * rows:条目，默认为10
 ****/
- (void)getPianoMyCreatedCoursesWith:(long long)uid Status:(int)status
                                page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;
/**
 * 获取我订购的课程
 * uid:用户id(必须)
 * status:课程状态 0:全部 1:已完成 2:已取消
 * page:页码 默认为1
 * rows:条目，默认为10
 ****/
- (void)getPianoMyOrderedCoursesWith:(long long)uid Status:(int)status
                                page:(int)page rows:(int)rows jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;

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
- (void)getInquiryOrderInfoWithCourseid:(NSString *)orderID jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;



/**
 * 提交订单  *url:http://xxx/{mobileType}/commitOrder
 * 参数列表
 * uid:用户id
 * courseid:课程id
 * classid:课节id
 **/
- (void)getPianoCommitOrderWithUid:(long long)uid Courseid:(long long)courseid Classid:(long long)classid jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;


/*
 * 支付订单 *url:http://xxx/{mobileType}/payOrder
 *参数列表
 *uid：用户id
 *orderid:订单id
 *返回值
 *status:0:成功
        -1:订单不存在
        -100:服务器端错误
 *params:调用微信支付需要的参数
 *
 */
- (void)getPianopayOrderWithUid:(long long)uid OrderIDStr:(NSString *)orderid jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;


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
- (void)getPianoImmediatelySignUpWithUid:(long long)uid Courseid:(long long)courseid Classid:(long long)classid jsonResPonseDelegate:(id<HttpRequestDelegate>)jsonResponseDelegate;









@end
