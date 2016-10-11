//
//  FileCacheManager.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FILECACHEMANAGER [FileCacheManager DefaultFileCache]

typedef enum {
    FileType_Default = 0,   /*默认[通用类型文件]*/
    FileType_PPT,           /*课件 PPT / PDF*/
    FileType_Audio,         /*语音*/
    FileType_video,         /*视频*/
    FileType_Img,           /*图片*/
} FileType;/*缓存文件类型*/

typedef void (^FileSizeCallBack) (NSString *sizeString);

@interface FileCacheManager : NSObject
+ (FileCacheManager *)DefaultFileCache;

/**
 * 记录/更新缓存文件最近打开时间
 **/
- (void)updateFile:(NSString *)fileName fileType:(FileType)type;

/**
 * 获取缓存不同类型文件缓存路径(不包括文件名和后缀名)
 **/
- (NSString *)getFileRootPathWithFileType:(FileType)type;

/**
 * 获取缓存文件的size KB/MB/GB
 **/
- (void) getCacheFileSizeCallBack:(FileSizeCallBack)callBack;

/**
 * 手动清除全部缓存
 **/
- (void)clearCacheFileCallBack:(FileSizeCallBack)callBack;

/**
 * 自动清除过期缓存 (超过30 天未使用过)
 **/
- (void)clearInvalidateCacheFile;

/**
 * 根据文件名(需要加上拓展名)判断文件是否存在
 **/
- (BOOL)fileExisted:(NSString *)fileName fileType:(FileType)fType;

/**
 * 移除指定文件
 **/
- (void)removeFileWithPath:(NSString *)path;
@end
