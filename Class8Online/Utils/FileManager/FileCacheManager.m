//
//  FileCacheManager.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "FileCacheManager.h"
#import "SDImageCache.h"
#import "CoreDataManager.h"
#import "CacheFile.h"
#import "ASIDownloadCache.h"


static FileCacheManager *fileManager = nil;
@implementation FileCacheManager

+ (FileCacheManager *)DefaultFileCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileManager = [[FileCacheManager alloc] init];
    });
    return fileManager;
}
//=========================================
// 检查/创建文件路径 (不含 文件名和后缀名) 不存在则创建
//=========================================
- (void)checkFilePath:(NSString *)path {
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}



/**
 * 记录/更新缓存文件最近打开时间
 **/
- (void)updateFile:(NSString *)fileName fileType:(FileType)type
{
    CacheFile *cfile = [DATABASEMANAGER createCacheFile:fileName];
    cfile.lastOpenTime = [NSDate date];
    cfile.fileType = [NSNumber numberWithInt:type];
    [DATABASEMANAGER save];
}

/**
 * 获取缓存不同类型文件缓存路径(不包括文件名和后缀名)
 **/
- (NSString *)getFileRootPathWithFileType:(FileType)type
{
    NSString *subPath = @"";
    switch (type) {
        case FileType_PPT:
        {
        subPath = @"ppt";
        }
            break;
        case FileType_Audio:
        {
            subPath = @"media";
        }
            break;
        case FileType_video:
        {
            subPath = @"media";
        }
            break;
        case FileType_Img:
        {
        subPath = @"image";
        }
            break;
        default:
        {
            subPath = @"other";
        }
            break;
    }
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *savedPath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"cache/%@",subPath]];
    [self checkFilePath:savedPath];
    return savedPath;
}

//=================================
// 计算缓存大小
//=================================

/**
 * 获取缓存文件的size KB/MB/GB
 **/
- (void) getCacheFileSizeCallBack:(FileSizeCallBack)callBack;
{
    __block long long fileSize = 0;
    __weak FileCacheManager *wself = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, queue, ^{
            //异步计算 通用文件路径文件大小
            FileCacheManager *sself = wself;
            fileSize += [sself folderSize:[sself getFileRootPathWithFileType:FileType_Default]];
        });
        dispatch_group_async(group, queue, ^{
            //异步计算 PPT文件路径文件大小
            FileCacheManager *sself = wself;
            fileSize += [sself folderSize:[sself getFileRootPathWithFileType:FileType_PPT]];
        });
        dispatch_group_async(group, queue, ^{
            //异步计算 语音文件路径文件大小
            FileCacheManager *sself = wself;
            fileSize += [sself folderSize:[sself getFileRootPathWithFileType:FileType_Audio]];
        });
        dispatch_group_async(group, queue, ^{
            //异步计算 视频文件路径文件大小
            FileCacheManager *sself = wself;
            fileSize += [sself folderSize:[sself getFileRootPathWithFileType:FileType_video]];
        });
        
        dispatch_group_async(group, queue, ^{
            //异步计算 图片文件路径文件大小
            FileCacheManager *sself = wself;
            fileSize += [sself folderSize:[sself getFileRootPathWithFileType:FileType_Img]];
        });
        dispatch_group_async(group, queue, ^{
            //计算SDimageView 缓存大小
          fileSize += [[SDImageCache sharedImageCache] getSize];
        });
        dispatch_group_async(group, queue, ^{
           //计算ASIDownloadCache 缓存
            FileCacheManager *sself = wself;
            ASIDownloadCache *asiCache = [ASIDownloadCache sharedCache];
            fileSize += [sself folderSize:asiCache.storagePath];
        });
        dispatch_group_notify(group, queue, ^{
            //汇总
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新UI
                if (callBack) {
                    FileCacheManager *sself = wself;
                    callBack ([sself fileSizeString:fileSize]);
                }
            });
        });  
        
    });
}

- (NSString *)fileSizeString:(long long) size {
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
    return [[NSString alloc]initWithFormat:@"%0.1f%@" ,fileSize, sizeTypeW];
}

//获取路径下所有文件大小
-(long long )folderSize:(NSString *)folderPath{
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    long long fileSize = 0;
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:
                                        [folderPath stringByAppendingPathComponent:fileName] error:NULL];
        fileSize += [fileDictionary fileSize];
    }
    return fileSize;
}

//======================================
// 手动清除全部缓存
//======================================
/**
 * 手动清除全部缓存
 **/
- (void)clearCacheFileCallBack:(FileSizeCallBack)callBack
{
    __weak FileCacheManager *wself = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, queue, ^{
            //异步 删除通用文件夹
            FileCacheManager *sself = wself;
            [sself clearFileWihPath:[sself getFileRootPathWithFileType:FileType_Default]];
        });
        dispatch_group_async(group, queue, ^{
            //异步 删除PP文件夹
            FileCacheManager *sself = wself;
            [sself clearFileWihPath:[sself getFileRootPathWithFileType:FileType_PPT]];
        });
        dispatch_group_async(group, queue, ^{
            //异步 删除视频文件夹
            FileCacheManager *sself = wself;
            [sself clearFileWihPath:[sself getFileRootPathWithFileType:FileType_video]];
        });
        
        dispatch_group_async(group, queue, ^{
            //异步 删除语音文件夹
            FileCacheManager *sself = wself;
            [sself clearFileWihPath:[sself getFileRootPathWithFileType:FileType_Audio]];
        });

        dispatch_group_async(group, queue, ^{
            //异步 删除图片文件夹
            FileCacheManager *sself = wself;
            [sself clearFileWihPath:[sself getFileRootPathWithFileType:FileType_Img]];
        });
        dispatch_group_async(group, queue, ^{
            //异步 删除SDimageView 缓存大小
            [[SDImageCache sharedImageCache]clearMemory];
            [[SDImageCache sharedImageCache]clearDisk];
            [[SDImageCache sharedImageCache]cleanDisk];

        });
        dispatch_group_async(group, queue, ^{
            //异步 删除ASIDownloadCache 缓存
            [[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        });

        dispatch_group_notify(group, queue, ^{
            //汇总
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新UI
                if (callBack) {
                    callBack (@"0.0kb");
                }
            });
        });
    });
}


/**
 * 删除缓存文件夹/文件
 **/
- (BOOL)clearFileWihPath:(NSString *)path {
    
    
   return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

/**
 * 自动清除过期缓存 (超过30 天未使用过)
 **/
- (void)clearInvalidateCacheFile
{
    NSArray *fileArr = [DATABASEMANAGER getInvalidateCacheFile];
    for (CacheFile *f in fileArr) {
        NSString *filePath = [[self getFileRootPathWithFileType:[f.fileType integerValue]] stringByAppendingPathComponent:f.fileName];
        BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (!existed) {
            [DATABASEMANAGER deleteobject:f];
            [DATABASEMANAGER save];
        }
        if (existed && [self clearFileWihPath:filePath]) {
            [DATABASEMANAGER deleteobject:f];
            [DATABASEMANAGER save];
        }
    }
}


/**
 * 根据文件名(需要加上拓展名)判断文件是否存在
 **/
- (BOOL)fileExisted:(NSString *)fileName fileType:(FileType)fType
{
    BOOL isExisted = NO;
    NSString *filePath = [[FILECACHEMANAGER getFileRootPathWithFileType:fType] stringByAppendingPathComponent:fileName];
    isExisted = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExisted) {
        /**
         * 如果文件大小为0 说明文件是空文件或者下载失败的文件 
         * 是: 删除文件并且返回 NO
         * 否: 不处理
         **/
        NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
        long long fileSize = [fileDic fileSize];

        if (fileSize <= 0) {
            isExisted = NO;
            [self removeFileWithPath:filePath];
        }
    }
    return isExisted;
}

/**
 * 移除指定文件
 **/
- (void)removeFileWithPath:(NSString *)path
{
    NSString *filePath = path;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (existed) {
        [self clearFileWihPath:filePath];
    }
}

@end
