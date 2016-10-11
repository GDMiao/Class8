//
//  Utils.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "Utils.h"
#import "iToast.h"
#import "RegexKitLite.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import <math.h>

#import <AVFoundation/AVFoundation.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "base64.h"
@implementation Utils
/**
 * 判断手机号是否合法
 **/

+ (BOOL)checkTellPhoneNumber:(NSString *)aString {
    if (aString.length != 11 || !aString) {
        return NO;
    }
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,2-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:aString];
}

/**
 * 检测密码是否合法
 **/

+(BOOL)isPasswordStandard:(NSString *)str
{
    if (!str || str.length == 0) {
        return NO;
    }
    
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc] initWithPattern:@"^[a-zA-Z0-9_]{6,20}$"options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    
    if(numberofMatch > 0)
    {
        return YES;
    }
    return NO;
    
    
    //1.8.2 密码检测只判断位数
    //    if (!str || str.length < 6 || str.length > 16) {
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}

/**
 * 对象是否为空
 **/

+(BOOL)objectIsNull:(NSObject *)value
{
    if(!value || [ value isEqual:[NSNull null]] || [ [value description]isEqualToString:@""] || [[value description] isEqualToString:@"<null>"] || [[value description] isEqualToString:@"None"]){
        return YES;
    }
    return NO;
}
/**
 * 对象是否不为空
 **/

+(BOOL)objectIsNotNull:(NSObject *)value
{
    return ![self objectIsNull:value];
}

/**
 * Toast 提示
 **/
+(void)showToast:(NSString *)title
{
    if ([self objectIsNull:title]) {
        title = CSLocalizedString(@"utils_unKnown_error");
    }
    [[[iToast makeText:title]
      setGravity:iToastGravityCenter] show];
}

/**
 * UIAlertView 提示
 **/
+ (void)showAlert:(NSString *)title {
    title = [Utils objectIsNotNull:title]?title:CSLocalizedString(@"utils_unKnown_error");
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:title
                                                  delegate:nil
                                         cancelButtonTitle:CSLocalizedString(@"utils_ok")
                                         otherButtonTitles:nil, nil];
    [alert show];
}

/**
 * 错误状态
 **/
+ (void)showHUDEorror:(NSString *)title {
    [SVProgressHUD showErrorWithStatus:title];
}

/**
 * 成功状态
 **/
+ (void)showHUDSuccess:(NSString *)title {
    [SVProgressHUD showSuccessWithStatus:title];
}

/**
 * 显示指示器
 **/
+ (void)showHUD:(NSString *)title
{
    title = title ? title : @"";
    if (!(title.length > 0)) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }else {
        [SVProgressHUD showWithStatus:title maskType:SVProgressHUDMaskTypeBlack];
    }
}

/**
 * 隐藏指示器
 **/
+ (void)hiddenHUD {
    [SVProgressHUD dismiss];
}

/**
 * 获取日期 时间戳格式化
 **/
+ (NSString *)getDateString:(long long )time
{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}


/**
 * 获取登录/注册/启动页 背景图名称
 **/
+ (NSString *)vcbgImgName
{
    NSString *img = @"启动页iphone4";
    if (iPhone5) {
        img = @"启动页iphone5";
    }else if (iPhone6) {
        img = @"启动页iphone6";
    }else if (iPhone6P) {
       img = @"启动页iphone6p";
    }
    return img;
}

/**
 * 获取启动过度图片
 **/
+ (NSString *)covertImgName
{
    NSString *img = @"Default";
    if (iPhone5) {
        img = @"Default-568h";
    }else if (iPhone6) {
        img = @"Default-375w-667h";
    }else if (iPhone6P) {
        img = @"Default-414w-736h";
    }
    return img;
}


/**
 * 获取PDF 文件名
 **/
+ (NSString *)getPdfFileName:(NSString *)string {
    NSString *regex1 = @"/{0,0}[a-zA-Z0-9\\u4e00-\\u9fa5]+.pdf";
    NSString *regexText= [string stringByMatching:regex1];
    if (!regexText) {
        NSString *regex2 = @"/{0,0}[a-zA-Z0-9\\u4e00-\\u9fa5]+(.pdf)?:";
        regexText= [string stringByMatching:regex2];
        if (regexText) {
            regexText = [[regexText stringByReplacingOccurrencesOfString:@":" withString:@""] stringByReplacingOccurrencesOfString:@".pdf" withString:@""];
            regexText = [NSString stringWithFormat:@"%@.pdf",regexText];
        }
    }
    return regexText;
}

/**
 * 获取pdf 下载名
 **/
+ (NSString *)getPDFDownLoadPath:(NSString *)string
{
    NSString *subDownloadPath = [[string componentsSeparatedByString:@":"] firstObject];
    if ([subDownloadPath rangeOfString:@".pdf"].location != NSNotFound) {
        
    }else if ([subDownloadPath componentsSeparatedByString:@"."].count == 1){
        subDownloadPath = [NSString stringWithFormat:@"12/%@.pdf",subDownloadPath];
    }else {
        return nil;
    }
    return subDownloadPath;
}

/**
 *判断是否是图片课件
 **/
+ (BOOL) isImgCourse:(NSString *)string
{
    if ([string rangeOfString:@".jpg"].location != NSNotFound || [string rangeOfString:@".png"].location != NSNotFound) {
        return YES;
    }
    return NO;
}

/**
 *判断是否是音频课件
 **/
+ (BOOL) isAudioCourse:(NSString *)string
{
    if ([string rangeOfString:@".mp3"].location != NSNotFound || [string rangeOfString:@"mp4"].location != NSNotFound) {
        return YES;
    }
    return NO;
}



/**
 * 获取img 图片 下载路径
 **/
+ (NSString *) getImgCoursePath:(NSString *)string
{
    NSString *subDownloadPath = [[string componentsSeparatedByString:@":"] firstObject];
    return subDownloadPath;
}

/**
 * 获取 音频课件 下载路径
 **/
+ (NSString *) getAudioCoursePath:(NSString *)string
{
    NSString *subDownloadPath = [[string componentsSeparatedByString:@":"] firstObject];
    return subDownloadPath;
}


/**
 *匹配出教师的主视频地址视频
 **/
+ (NSDictionary *)getTeacherMainVideo:(NSString *)string
{
    NSMutableDictionary *videoConfigDic = [[NSMutableDictionary alloc] init];
    
    NSArray *videoAndAudioUrlArr = [string componentsSeparatedByString:@"|@|"];
    NSString *audioUrl = [videoAndAudioUrlArr lastObject]; //音频地址
    NSString *videoUrl = [videoAndAudioUrlArr firstObject]; //多路视频地址
    if (audioUrl) {
        [videoConfigDic setObject:audioUrl forKey:ClassRoomAudioRul];
    }
   
    
    NSString *videoBaseUrlRegex = @"rtmp://[.:/\?a-zA-Z0-9\\u4e00-\\u9fa5]+/live/";
    NSString *subVideosRegex = @"live/[_|&=/\?a-zA-Z0-9\\u4e00-\\u9fa5]+"; //视频子地址集合
    if ([Utils objectIsNull:videoUrl]) {
        return videoConfigDic;
    }
    
    NSString *videoBaseUrl= [videoUrl stringByMatching:videoBaseUrlRegex]; //视频主地址
    NSString *videoSubUrls = [[videoUrl stringByMatching:subVideosRegex] stringByReplacingOccurrencesOfString:@"live/" withString:@""];   //视频多路地址
    
    if ([Utils objectIsNull:videoBaseUrl]||[Utils objectIsNull:videoSubUrls] ) {
        return videoConfigDic;
    }
    NSArray *subVideoUrlArr = [videoSubUrls componentsSeparatedByString:@"|&|"];
    for (int i = 0; i < subVideoUrlArr.count; i++) {
        NSString *videoUrl = [NSString stringWithFormat:@"%@%@",videoBaseUrl,[subVideoUrlArr objectAtIndex:i]];
        [videoConfigDic setObject:videoUrl forKey:[NSString stringWithFormat:@"%d",i+1]];
    }
    return videoConfigDic;
}

static unsigned int _CRC32[256] = {0};
static char  _bInit = 0;

//初始化表
static void init_table()
{
    int	i,j;
    uint  crc;
    for(i = 0;i < 256;i++)
    {
        crc = i;
        for(j = 0;j < 8;j++)
        {
            if(crc & 1)
            {
                crc = (crc >> 1) ^ 0xEDB88320;
            }
            else
            {
                crc = crc >> 1;
            }
        }
        _CRC32[i] = crc;
    }
}

//crc32实现函数
unsigned int crc32(unsigned char * buf, int len)
{
    uint ret = 0xFFFFFFFF;
    int   i;
    if( !_bInit )
    {
        init_table();
        _bInit = 1;
    }
    for(i = 0; i < len;i++)
    {
        ret = _CRC32[((ret & 0xFF) ^ buf[i])] ^ (ret >> 8);
    }
    ret = ~ret;
    
    return ret;
}
/**
 * 计算PDF 文件 id
 **/
+ (uint)crc32Value:(NSString *)string
{
    return crc32([string UTF8String], string.length);
}

/**
 * 检查网络是否是3G
 **/
+ (BOOL) IsEnable3G {
    
    return ([[ReachabilityNetwork reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN);
}

/**
 * 检查网络是否是3G
 **/
+ (BOOL) IsEnableWIFI {
    return ([[ReachabilityNetwork reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi);
}

/**
 * 检查网络是否可用
 **/
+ (BOOL) IsEnableNetWork {
        return ([[ReachabilityNetwork reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

/**
 *我的课程页 上课时间转换处理 传入1=13:22-14:22 传出 周一13:22-14:22
 **/
+ (NSString *)getMyCourseTimes:(NSString *)string
{
    NSString *timeString = @"";
    NSArray *arr = [string componentsSeparatedByString:@"="];
    int firstObj = [[arr firstObject] intValue];
    switch (firstObj) {
        case 1:
        {
            timeString = [NSString stringWithFormat:@"%@%@",CSLocalizedString(@"utils_week_1"),[arr lastObject]];
        }
            break;
        case 2:
        {
            timeString = [NSString stringWithFormat:@"%@%@",CSLocalizedString(@"utils_week_2"),[arr lastObject]];
        }
            break;
            
        case 3:
        {
            timeString = [NSString stringWithFormat:@"%@%@",CSLocalizedString(@"utils_week_3"),[arr lastObject]];
        }
            break;
        case 4:
        {
            timeString = [NSString stringWithFormat:@"%@%@",CSLocalizedString(@"utils_week_4"),[arr lastObject]];
        }
            break;

        case 5:
        {
            timeString = [NSString stringWithFormat:@"%@%@",CSLocalizedString(@"utils_week_5"),[arr lastObject]];
        }
            break;

        case 6:
        {
            timeString = [NSString stringWithFormat:@"%@%@",CSLocalizedString(@"utils_week_6"),[arr lastObject]];
        }
            break;
        case 7:
        {
            timeString = [NSString stringWithFormat:@"%@%@",CSLocalizedString(@"utils_week_7"),[arr lastObject]];
        }
            break;
        default:
            break;
    }
    return timeString;
}


/**
 *判断是否是视频课件
 **/
+ (BOOL)isVideoCourseWare:(NSString *)string
{
    if ([string rangeOfString:@".mp4"].location != NSNotFound) {
        return YES;
    }
    return NO;
}

/**
 * 获取媒体课件下载路径
 **/
+ (NSString *)getMediaURLSubPath:(NSString *)string
{
    NSString *subDownloadPath = [[string componentsSeparatedByString:@":"] firstObject];
    return subDownloadPath;
}

/**
 * 获取课件名的通用方法 用于课件列表展示名字使用
 **/
+ (NSString *)getCourseWareName:(NSString *)string
{
    NSString *sub = [[string componentsSeparatedByString:@":"] lastObject];
    NSString *obj_string = sub;
    CSLog(@"截取原始课件名字: %@",obj_string);
    return obj_string;
}

/**
 * 根据文件名获取文件的icon 图片
 **/
+ (NSString *)getCourseWareIcon:(NSString *)string
{
    NSArray *icons= [string componentsSeparatedByString:@"."];
    NSString *fileTypeString = [icons lastObject];
    NSString *iconString = @"默认文件";
    if ([fileTypeString rangeOfString:@"doc"].location != NSNotFound) {
        iconString = @"word";
    }else if ([fileTypeString rangeOfString:@"xlsx"].location != NSNotFound) {
        iconString = @"excel";
    }else if ([fileTypeString rangeOfString:@"mp3"].location != NSNotFound || [fileTypeString rangeOfString:@"wav"].location != NSNotFound) {
        iconString = @"music";
    }else if ([fileTypeString rangeOfString:@"jpg"].location != NSNotFound || [fileTypeString rangeOfString:@"png"].location != NSNotFound) {
        iconString = @"image";
    }else if ([fileTypeString rangeOfString:@"ppt"].location != NSNotFound) {
        iconString = @"ppt";
    }else if ([fileTypeString rangeOfString:@"mp4"].location != NSNotFound || [fileTypeString rangeOfString:@"flv"].location != NSNotFound) {
        iconString = @"video";
    }else if ([fileTypeString rangeOfString:@"pdf"].location != NSNotFound) {
        iconString = @"pdf";
    }
    
    return iconString;
}


/**
 * 获取我的学校背景图片
 **/
+ (NSString *)getMySchoolBjImg
{
    NSString *imgString = @"我的学校960底图";
    if (!iPhone4) {
        imgString = @"我的学校底图";
    }
    return imgString;
}

+ (NSString *)fileSizeString:(long long) size {
    NSString *sizeTypeW = @"kb";
    float fileSize = 0.0;
    if (size < 1) {
        return @"0KB";
    }else {
        size = size/1024;
        if (size > 0) {
            fileSize = size;
            sizeTypeW = @"KB";
            
        }
        if (size >= 1024) {
            fileSize = size/ 1024.0;
            sizeTypeW = @"MB";
        }
        size = size /1024;
        if (size >= 1024) {
            fileSize = size / 1024;
            sizeTypeW = @"GB";
        }
    }
    return [[NSString alloc]initWithFormat:@"%d%@" ,(int)fileSize, sizeTypeW];
}


/**
 * 判断是否有音频地址
 **/
+ (BOOL )hasAudioUrl:(NSString *)string
{
    NSArray *arr= [string componentsSeparatedByString:@"|@|"];
    if (arr.count == 2) {
        return YES;
    }
    return NO;
}

/**
 * 是否有使用摄像头的权限
 **/
+ (BOOL)hasCameraAuthor {
    if (IS_IOS7) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];  //获取对摄像头的访问权限
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
            [Utils showAlert:CSLocalizedString(@"utils_camera_no")];
            return NO;
        }
    }
    return YES;
}

/**
 * 是否有权限使用麦克风
 **/
+ (BOOL)canUseMic {
    __block BOOL bCanRecord = YES;
    if (IS_IOS7)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    if (!bCanRecord) {
        [Utils showAlert:CSLocalizedString(@"utils_mic_no")];
    }
    return bCanRecord;
}

/**
 *获取设备名
 **/
+(NSString*)deviceString
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *deviceString = [NSString stringWithFormat:@"%s", machine];
    free(machine);
    
    CSLog(@"device type: %@", deviceString);
    
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    //iPod
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    
    
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini";
    
    //模拟器
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    
    return [UIDevice currentDevice].model;
}

/**
 * 时间字符串格式化 输入2016-1-25 11:55:49 返回  时:分
 **/
+ (NSString *)timeString:(NSString *)time
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  // 格式要与ldate的一样，否则得到的是null值。
    NSDate *dateOrginal=[dateFormat dateFromString:time];

    
    [dateFormat setDateFormat:@"HH:mm"];
    NSString *timeString = [dateFormat stringFromDate:dateOrginal];
    return timeString;
}

/**
 * 日期字符串格式化 输入2016-1-25 11:55:49 返回  年-月-日
 **/
+ (NSString *)dateString:(NSString *)time
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  // 格式要与ldate的一样，否则得到的是null值。
    NSDate *dateOrginal=[dateFormat dateFromString:time];
    
    
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *timeString = [dateFormat stringFromDate:dateOrginal];
    return timeString;

}


/**
 *生日字符串格式化
 **/
+ (NSString *)birthdayString:(long long)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy年MM月dd日"];
    NSString *timeString = [dateFormat stringFromDate:date];
    if (!timeString || time <= 0) {
        timeString = @"未知";
    }
    return timeString;
}

@end
