//
//  Utils.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassModel.h"
@interface Utils : NSObject

/**
 * 判断手机号是否合法
 **/
+ (BOOL)checkTellPhoneNumber:(NSString *)aString;
/**
 * 检测密码是否合法
 **/
+(BOOL)isPasswordStandard:(NSString *)str;
/**
 * 对象是否为空
 **/
+ (BOOL)objectIsNull:(NSObject *)value;
/**
 * 对象是否不为空
 **/
+ (BOOL)objectIsNotNull:(NSObject *)value;
/**
 * Toast 提示
 **/
+ (void)showToast:(NSString *)title;

/**
 * UIAlertView 提示
 **/
+ (void)showAlert:(NSString *)title;
/**
 * 错误状态
 **/
+ (void)showHUDEorror:(NSString *)title;

/**
 * 成功状态
 **/
+ (void)showHUDSuccess:(NSString *)title;

/**
 * 显示指示器
 **/
+ (void)showHUD:(NSString *)title;

/**
 * 隐藏指示器
 **/
+ (void)hiddenHUD;

/**
 * 获取日期 时间戳格式化
 **/
+ (NSString *)getDateString:(long long )time;


/**
 * 获取启动页 背景图名称
 **/
+ (NSString *)vcbgImgName;

/**
 * 获取启动过度图片
 **/
+ (NSString *)covertImgName;

/**
 * 获取PDF 文件名
 **/
+ (NSString *)getPdfFileName:(NSString *)string;

/**
 * 获取pdf 下载名
 **/
+ (NSString *)getPDFDownLoadPath:(NSString *)string;

/**
 *判断是否是图片课件
 **/
+ (BOOL) isImgCourse:(NSString *)string;

/**
 *判断是否是音频/视频课件
 **/
+ (BOOL) isAudioCourse:(NSString *)string;

/**
 * 获取img 图片 下载路径
 **/
+ (NSString *) getImgCoursePath:(NSString *)string;

/**
 * 获取 音频/视频课件 下载路径
 **/
+ (NSString *) getAudioCoursePath:(NSString *)string;

#define ClassRoomAudioRul @"audioUrl"
/**
 * 匹配出教师的主视频地址视频
 **/
+ (NSDictionary *)getTeacherMainVideo:(NSString *)string;

/**
 * 计算PDF 文件 id  130326336
 **/
+ (uint)crc32Value:(NSString *)string;

/**
 * 检查网络是否是3G
 **/
+ (BOOL) IsEnable3G;

/**
 * 检查网络是否是3G
 **/
+ (BOOL) IsEnableWIFI;

/**
 * 检查网络是否可用
 **/
+ (BOOL) IsEnableNetWork;

/**
 *我的课程页 上课时间转换处理 传入1=13:22-14:22 传出 周一13:22-14:22
 **/
+ (NSString *)getMyCourseTimes:(NSString *)string;


//================================================================
//TODO: new add for C8 new 2015/9/23
//================================================================
/**
 *判断是否是视频课件
 **/
+ (BOOL)isVideoCourseWare:(NSString *)string;


/**
 * 获取媒体课件下载路径
 **/
+ (NSString *)getMediaURLSubPath:(NSString *)string;

/**
 * 获取课件名的通用方法 用于课件列表展示名字使用
 **/
+ (NSString *)getCourseWareName:(NSString *)string;

/**
 * 根据文件名获取文件的icon 图片
 **/
+ (NSString *)getCourseWareIcon:(NSString *)string;

/**
 * 获取我的学校背景图片
 **/
+ (NSString *)getMySchoolBjImg;

/**
 * 转换文件的大小
 **/
+ (NSString *)fileSizeString:(long long) size;

/**
 * 判断是否有音频地址
 **/
+ (BOOL )hasAudioUrl:(NSString *)string;

/**
 * 是否有使用摄像头的权限
 **/
+ (BOOL)hasCameraAuthor;

/**
 * 是否有权限使用麦克风
 **/
+ (BOOL)canUseMic;

/**
 *获取设备名
 **/
+(NSString*)deviceString;

/**
 * 时间字符串格式化 输入2016-1-25 11:55:49 返回  时:分
 **/
+ (NSString *)timeString:(NSString *)time;

/**
 * 日期字符串格式化 输入2016-1-25 11:55:49 返回  年-月-日
 **/
+ (NSString *)dateString:(NSString *)time;

/**
 *生日字符串格式化
 **/
+ (NSString *)birthdayString:(long long)time;
@end
