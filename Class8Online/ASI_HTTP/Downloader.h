//
//  Downloader.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/28.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileCacheManager.h"

#define DOWNLOADERFILETYPE @"downloaderType"        //下载的文件类型
#define DOWNLOADERTAG @"downloaderTag"              //下载对象的标记
#define DOWNLOADERFILENAME @"downloaderfilename"    //下载的文件名
#define DOWNLOADPROGRESS @"downloadprogress"        //下载进度
#define DOWNLOADBYUSER @"downloadByUser"            //是否由用户手动下载 默认 为 yes <用户手动下载>

#define KNotification_DownLoadFIleDidStart @"didStartLoadFile"      //文件开始下载  返回 userinfo (keys 见上)
#define KNotification_DownLoadFIleDidFinish @"didFinishLoadFile"    //文件下载完的通知 返回 userinfo (keys 见上)
#define KNotification_DownLoadFileDidFaild @"didFailLoadFile"       //文件下载失败通知 返回 userinfo (keys 见上)
#define KNotification_DownLoading @"LoadingFile"  //文件下载中 obj为一个字典 key: DOWNLOADERFILENAME value : 下载的文件名 key: DOWNLOADPROGRESS value: 下载进度
@class Downloader;
@protocol DownloaderDelegate <NSObject>

@optional

/**
 * 开始下载
 **/

- (void)downloaderDidStart:(Downloader *)downloader;

/**
 * 下载完成
 **/
- (void)downloader:(Downloader *)downloader didFinishDownloadFile:(NSString *)path;

/**
 * 下载中
 **/
- (void)downloader:(Downloader *)downloader progress:(float)progress;

/**
 * 下载失败
 **/
- (void)downloader:(Downloader *)downloader didFailWithError:(NSString *)error;

@end


@interface Downloader : NSObject
@property (weak, nonatomic) id <DownloaderDelegate>delegate;
+ (Downloader *)shareInstance;

/**
 * 取消全部下载任务
 **/
- (void)cancelAllRequest;

/**
 *初始化下载对象
 **/
- (id)initWithString:(NSString *)Url DownloaderType:(FileType)dType delegate:(id<DownloaderDelegate>)aDelegate;

/**
 * 最大并发数
 **/
- (void)setDownloadMaxOperationCount:(NSInteger )count;

/**
 * 根据文件URL判断文件是否存在
 **/
- (BOOL)fileExisted:(NSString *)url fileType:(FileType)fType;


//=============================================
//添加下载任务
//=============================================
/**
 * 添加下载任务
 * URL : 文件的网络地址
 * dType: 文件类型 见 FileType
 * byuser : 是否是用户自己需要下载 目前只有 在线课堂自动下载的课件时 此属性为NO  其余均为 yes
 **/
- (void)addDownloaderFileUrl:(NSString *)URL fileType:(FileType)dType byUser:(BOOL)byuser delegate:(id<DownloaderDelegate>)aDelegate;
@end
