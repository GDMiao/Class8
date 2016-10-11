//
//  Class8ServerConfig.h
//  Class8Online
//
//  Created by chuliangliang on 15/8/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//



#ifndef Class8Online_Class8ServerConfig_h
#define Class8Online_Class8ServerConfig_h

#endif

#define TCPServerIP_Release @"221.228.195.60"  //TCP 外网测试 IP <>
//#define TCPServerIP_Release @"61.147.188.61"  //TCP 正式服 IP
#define TCPServerIP_Debug   @"10.2.2.231"       //TCP 测试服 IP

// Piano
#define PianoTCPSeverIP_Release @"61.147.188.61"  // Piano 服务器 IP  Port: 7000



//HTTP<正式服务器>
#define HTTPUPload_Release      @"http://upload.class8.com"     //文件上传接口61.147.188.60:12080
#define HTTPDownload_Release    @"http://61.147.188.60:12080"          //文件下载接口 （原来：http://download.class8.com）
#define HTTPBasicURL_Release    @"http://2c.class8.com"         //数据获取接口
#define Piano_HTTPBasicURL_Release    @"http://piano.class8.com"         //Pinao数据获取接口
//#define HTTPBasicURL_Release    @"http://hn.class8.com"         //数据获取接口<外网正式>


//HTTP<内网测试服务器>
#define HTTPUPload_Debug      @"http://upload.class8.com"     //文件上传接口
#define HTTPDownload_Debug    @"download.p.class8.com"   //文件下载接口   原来：http://download.class8.com /http://61.147.188.60:12080/ download.p.class8.com
#define HTTPBasicURL_Debug    @"http://2c.class8.com"         //数据获取接口
#define Piano_HTTPBasicURL_Debug    @"http://piano.class8.com"         //Pinao 数据获取接口


//#define HTTPServerIP_Release8080 @"123.58.129.154"  //HTTP 正式服 仅适用端口为8080/10080的http请求 此ip与183.131.144.167(联通) 数据同步相同<两者均可>
#define HTTPServerIP_Release8080 @"61.147.188.59"  //HTTP 正式服 仅适用端口为8080/10080的http请求 此ip与183.131.144.167(联通) 数据同步相同<两者均可>
#define HTTPServerIP_Debug8080 @"10.2.2.233"        //HTTP 测试服 仅适用端口为80的http请求

//#define HTTPServerIP_Release12080_14080 @"123.58.130.2" //HTTP 正式服 仅适用端口为14080/12080的http请求 此ip与183.131.144.227(联通) 数据同步相同<两者均可>
#define HTTPServerIP_Release12080_14080 @"61.147.188.58" //HTTP 正式服 仅适用端口为14080/12080的http请求 此ip与183.131.144.227(联通) 数据同步相同<两者均可>

#define HTTPServerIP_Debug12080_14080 @"10.2.2.233"     //HTTP 测试服 仅适用端口为14080/12080的http请求


//#define TCP_PORT           6000   //TCP 端口
#define Piano_TCP_PORT     7000   //Piano  port端口 7000

#ifdef AppleRelease
//正式服务器

//TCP
#define TCP_API_IP TCPServerIP_Release

#define Piano_TCP_API_IP PianoTCPSeverIP_Release


/**
 *在线课堂图片地址  正式服务器
 **/
#define strDownloadChatImageUrl [NSString stringWithFormat:@"%@/edudown/img/chat/",HTTPDownload_Release]

/**
 *在线课堂PDF 文件下载地址 正式服务器
 **/
#define PDFDownloadUrl [NSString stringWithFormat:@"%@/Cursewave/",HTTPDownload_Release]

/**
 * 签到上传/下载
 **/
#define SignPicDown [NSString stringWithFormat:@"%@/PicDown/sign",HTTPDownload_Release]
#define SignPicUpLoad [NSString stringWithFormat:@"%@/eduup/up/signin_img",HTTPUPload_Release]

/**
 * HTTP
 **/
#define API_HOST HTTPBasicURL_Release
#define Piano_API_HOST Piano_HTTPBasicURL_Release
#define BASIC_UPLoad_API [NSString stringWithFormat:@"%@/eduup2c",HTTPUPload_Release]

/**
 *我的课程列表封面图片
 **/
#define MyCourseImg [NSString stringWithFormat:@"%@/PicDown/",HTTPDownload_Release]
//#define MyCourseImg [NSString stringWithFormat:@"http://61.147.188.60:12080/PicDown/"]


/**
 * 用户头像
 **/
#define UserAvatarBasicUrl MyCourseImg


#else

//测试服务器地址

//TCP
#define TCP_API_IP TCPServerIP_Debug


/**
 *在线课堂图片地址  测试服务器
 **/
#define strDownloadChatImageUrl [NSString stringWithFormat:@"http://%@:12080/edudown/img/chat/",HTTPServerIP_Debug12080_14080]

/**
 *在线课堂PDF 文件下载地址 测试服务器
 **/
#define PDFDownloadUrl [NSString stringWithFormat:@"http://%@:12080/Cursewave/",HTTPServerIP_Debug12080_14080]

/**
 * 签到上传/下载 测试服务器
 **/
#define SignPicDown [NSString stringWithFormat:@"http://%@:12080/PicDown/sign",HTTPServerIP_Debug12080_14080]
#define SignPicUpLoad [NSString stringWithFormat:@"http://%@:14080/eduup/up/signin_img",HTTPServerIP_Debug12080_14080]

/**
 * HTTP 测试服务器
 **/
#define API_HOST [NSString stringWithFormat:@"http://%@:80",HTTPServerIP_Debug8080]
#define BASIC_UPLoad_API [NSString stringWithFormat:@"http://%@:14080/eduup2c",HTTPServerIP_Debug12080_14080]

/**
 *我的课程列表封面图片 测试服务器
 **/
#define MyCourseImg [NSString stringWithFormat:@"http://%@:12080/PicDown/",HTTPServerIP_Debug12080_14080]

/**
 * 用户头像
 **/
#define UserAvatarBasicUrl MyCourseImg

#endif
