//
//  Downloader.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/28.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "Downloader.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"


@interface Downloader ()
@property (strong, nonatomic) ASINetworkQueue *downLoadQueue;
@property (strong, nonatomic) NSMutableDictionary *downloaderFileInfo; // key: 下载的文件名 value: 下载进度
@end

static Downloader *downloader = nil;
@implementation Downloader
+ (Downloader *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[Downloader alloc] init];
    });
    return downloader;
}
- (id)initWithString:(NSString *)Url DownloaderType:(FileType)dType delegate:(id<DownloaderDelegate>)aDelegate
{
    self = [super init];
    if (self) {
        [self _initObj];
        [self addDownloaderFileUrl:Url fileType:dType byUser:YES delegate:nil];
    }
    return self;
}

//========================================
// 初始化
//========================================
- (id)init {
    self = [super init];
    if (self) {
        [self _initObj];
    }
    return self;
}
- (void)_initObj
{
    self.downloaderFileInfo = [[NSMutableDictionary alloc] init];
    
    
    self.downLoadQueue = [[ASINetworkQueue alloc] init];
    [self.downLoadQueue reset];
    [self.downLoadQueue setShowAccurateProgress:YES];
    [self.downLoadQueue setMaxConcurrentOperationCount:1];
    [self.downLoadQueue go];
}

- (void)dealloc {
    self.downloaderFileInfo = nil;
    self.delegate = nil;
    if (self.downLoadQueue) {
        [self cancelAllRequest];
        self.downLoadQueue = nil;
    }
}

/**
 * 取消全部下载任务
 **/
- (void)cancelAllRequest
{
    [self.downLoadQueue cancelAllOperations];
    [self.downLoadQueue.operations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ASIHTTPRequest *httpRest = (ASIHTTPRequest *)obj;
        [httpRest setDelegate:nil];
        httpRest = nil;
    }];

}

/**
 * 最大并发数
 **/
- (void)setDownloadMaxOperationCount:(NSInteger )count
{
    [self.downLoadQueue setMaxConcurrentOperationCount:count];
}
/**
 * 文件是否存在
 **/
- (BOOL)fileExisted:(NSString *)url fileType:(FileType)fType
{
    BOOL isExisted = NO;
    NSString *filePath = [[FILECACHEMANAGER getFileRootPathWithFileType:fType] stringByAppendingPathComponent:[url lastPathComponent]];
    isExisted = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return isExisted;
}


//=============================================
//添加下载任务
//=============================================
- (void)addDownloaderFileUrl:(NSString *)URL fileType:(FileType)dType byUser:(BOOL)byuser delegate:(id<DownloaderDelegate>)aDelegate
{
    if (aDelegate) {
        self.delegate = aDelegate;
    }
    //初始化保存路径
    NSString *fileName = URL.lastPathComponent;
    [self.downloaderFileInfo setObject:[NSNumber numberWithFloat:0.0] forKey:fileName];
    NSString *savePath = [[FILECACHEMANAGER getFileRootPathWithFileType:dType] stringByAppendingPathComponent:fileName];
    
    //初始化文件临时文件路径
    NSString *tmpSavePath = [[FILECACHEMANAGER getFileRootPathWithFileType:FileType_Default] stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp%@",fileName]];

//    //初始化保存ZIP文件路径
//	NSString *savePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"book_%d.zip",[sender tag]]];

    
    //初始下载连接
    NSURL *url = [NSURL URLWithString:URL];
    CSLog(@"课件下载 http__URL： %@",url);
    //设置下载连接
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    
    //设置ASIHTTPRequest代理
    request.delegate = self;

    //设置文件保存路径
    [request setDownloadDestinationPath:savePath];
    
    //设置临时文件路径
    [request setTemporaryFileDownloadPath:tmpSavePath];
    
    //设置进度条的代理,
    [request setDownloadProgressDelegate:self];
    
    //设置是是否支持断点下载
	[request setAllowResumeForFileDownloads:YES];
    
    //设置基本信息
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:dType],DOWNLOADERFILETYPE,[NSNumber numberWithInt:100],DOWNLOADERTAG,fileName,DOWNLOADERFILENAME,[NSNumber numberWithBool:byuser],DOWNLOADBYUSER,nil]];
    
    CSLog(@"Downloader(debug): UserInfo=%@",request.userInfo);
    
    //添加到ASINetworkQueue队列去下载
    [self.downLoadQueue addOperation:request];

}

//=============================================
// delegate
//=============================================
#pragma mark- 
#pragma mark - ASIHTTPRequestDelegate 

//ASIHTTPRequestDelegate,开始下载之前获取信息的方法,主要获取下载内容的大小，可以显示下载进度多少字节
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSDictionary *userinfo = [request userInfo];
    [self updateFileDownloaderProgress:0 fileName:[userinfo stringForKey:DOWNLOADERFILENAME]];
    
    if ([self.delegate respondsToSelector:@selector(downloaderDidStart:)]) {
        [self.delegate downloaderDidStart:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DownLoadFIleDidStart object:userinfo];
}
//下载中
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
    
    NSDictionary *headerInfo = [request responseHeaders];
    long long totalLength = 0;
    if (headerInfo && [headerInfo isKindOfClass:[NSDictionary class]]) {
        totalLength = [headerInfo longForKey:@"Content-Length"];

    }
    NSDictionary *userinfo = [request userInfo];
    long long didLoadFileLength = [self.downloaderFileInfo longForKey:[userinfo stringForKey:DOWNLOADERFILENAME]];
    bytes =  bytes + didLoadFileLength;
    float pro = (double)bytes / totalLength;
    pro = MAX(0, pro);
    pro = MIN(1, pro);
    [self updateFileDownloaderProgress:bytes fileName:[userinfo stringForKey:DOWNLOADERFILENAME]];
    
    CSLog(@"Downloader(debug): 已下载:%lld 总大小:%lld 文件下载进度: %f",bytes,totalLength,pro);
    if ([self.delegate respondsToSelector:@selector(downloader:progress:)]) {
        [self.delegate downloader:self progress:pro];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DownLoading object:@{DOWNLOADPROGRESS:[NSNumber numberWithFloat:pro],DOWNLOADERFILENAME:[userinfo stringForKey:DOWNLOADERFILENAME]}];
}

//ASIHTTPRequestDelegate,下载完成时,执行的方法
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *headerInfo = [request responseHeaders];
    NSDictionary *userinfo = [request userInfo];
    long long totalLength = 0;
    if (headerInfo && [headerInfo isKindOfClass:[NSDictionary class]]) {
        totalLength = [headerInfo longForKey:@"Content-Length"];
        [self updateFileDownloaderProgress:totalLength fileName:[userinfo stringForKey:DOWNLOADERFILENAME]];
    }

    
    NSString *fileName = [userinfo stringForKey:DOWNLOADERFILENAME];
    int fileType = [userinfo intForKey:DOWNLOADERFILETYPE];
    [self updateFileDownloaderProgress:1.0 fileName:fileName];
    //更新文件管理记录 将用户手动下载的文件 加入到文件管理记录
    BOOL downloadByUser = [userinfo boolForKey:DOWNLOADBYUSER];
    if (downloadByUser) {
        [FILECACHEMANAGER updateFile:fileName fileType:fileType];
    }
    
    if ([self.delegate respondsToSelector:@selector(downloader:didFinishDownloadFile:)]) {
        [self.delegate downloader:self didFinishDownloadFile:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DownLoadFIleDidFinish object:userinfo];
    [self removeFileInfo:fileName];
    
    CSLog(@"Downloader(debug): 文件下载成功: %@",fileName);
}

//下载失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSDictionary *userinfo = [request userInfo];
    NSString *fileName = [userinfo stringForKey:DOWNLOADERFILENAME];
    [self removeFileInfo:fileName];
    CSLog(@"Downloader(debug): 文件下载失败: %@",fileName);
    CSLog(@"Error:%@",request.error);
    if ([self.delegate respondsToSelector:@selector(downloader:didFailWithError:)]) {
        [self.delegate downloader:self didFailWithError:[request error].description];
    }
    
    [FILECACHEMANAGER removeFileWithPath:[[FILECACHEMANAGER getFileRootPathWithFileType:[userinfo intForKey:DOWNLOADERFILETYPE]] stringByAppendingPathComponent:fileName]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DownLoadFileDidFaild object:userinfo];
}

//更新信息
- (void)updateFileDownloaderProgress:(long long)pro fileName:(NSString *)fName {
    if (self.downloaderFileInfo && [self.downloaderFileInfo isKindOfClass:[NSMutableDictionary class]]) {
        [self.downloaderFileInfo setObject:[NSNumber numberWithLongLong:pro] forKey:fName];
    }
}

//移除下载信息
- (void)removeFileInfo:(NSString *)fileName
{
    [self.downloaderFileInfo removeObjectForKey:fileName];
}
@end
