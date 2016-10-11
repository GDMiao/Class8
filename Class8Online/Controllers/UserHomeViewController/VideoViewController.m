//
//  VideoViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/5/13.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "VideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
//degreeTOradians()定义一个宏。
#define degreeTOradians(x) (M_PI * (x)/180)
#define KScreenWidth [[UIScreen mainScreen]bounds].size.width
#define KScreenHeight [[UIScreen mainScreen]bounds].size.height
@interface VideoViewController ()

@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器
@end

@implementation VideoViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:@"VideoTest" withTitleStyle:CTitleStyle_OnlyBack];
    
    //播放
    [self.moviePlayer play];
    //添加通知
    [self addNotification];
    //获取缩略图
//    [self thumbnaiImageRequest];

    
    // Do any additional setup after loading the view from its nib.
}

- (void)dealloc{
    CSLog(@"销毁播放器");
    //移除所有通知监控
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    
}


#pragma mark -- 私有方法
/**
 *  获得本地文件路径
 *
 *  @return 文件路径
 */
- (NSURL *)getFileUrl{
    NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"" ofType:nil];
    return [NSURL URLWithString:urlStr];
    
}
/**
 *  取得网络文件路径
 *
 *  @return 文件路径
 */
- (NSURL *)getNetworkUrl{
    
    NSString *urlStr = self.mp4_url;
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:urlStr];
    
}

/**
 *  创建媒体播放器
 *
 *  @return <#return value description#>
 */
- (MPMoviePlayerController *)moviePlayer{
    if (!_moviePlayer) {
        NSURL *url = [self getNetworkUrl];
        _moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:url];
        _moviePlayer.view.frame = self.allContentView.bounds;
        _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _moviePlayer.shouldAutoplay = NO;
        _moviePlayer.fullscreen = YES;
        _moviePlayer.repeatMode = MPMovieRepeatModeOne;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        [self.allContentView addSubview:_moviePlayer.view];
    }
    
    return _moviePlayer;
}



/**
 *  获取视频缩略图
 */
- (void)thumbnaiImageRequest{
    //获取13.0s、21.5s的缩略图
    [self.moviePlayer requestThumbnailImagesAtTimes:@[@13.0,@21.5] timeOption:MPMovieTimeOptionNearestKeyFrame];
    
}

#pragma mark - 控制器通知
/**
 *  添加通知监控多媒体控制器状态
 */
- (void)addNotification{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerThumbnailRequestFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(videofullScreen) name:MPMoviePlayerWillEnterFullscreenNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(videosmallScreen) name:MPMoviePlayerWillExitFullscreenNotification object:self.moviePlayer];
    

}

- (void)videofullScreen
{
    NSLog(@"进入全屏");
    UIDevice *device = [UIDevice currentDevice];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        NSLog(@"The orientation is landscape");
    else if(UIDeviceOrientationIsPortrait(deviceOrientation))
        NSLog(@"The orientation is portrait");
    
}
- (void)videosmallScreen
{
    NSLog(@"退出全屏");
}



/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notify 通知对象
 */
- (void)mediaPlayerPlaybackStateChange:(NSNotification *)notify{
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放");
            break;
            
            
        default:
            NSLog(@"播放状态：%ld",(long)self.moviePlayer.playbackState);
            break;
    }
    
    
}
/**
 *  播放完成
 *
 *  @param notify 通知对象
 */
- (void)mediaPlayerPlaybackFinished:(NSNotification *)notify{
    NSLog(@"播放完成");
    
}
/**
 *  缩略图请求完成，此方法每次截图成功后都会调用一次
 *
 *  @param notify 通知对象
 */
- (void)mediaPlayerThumbnailRequestFinished:(NSNotification *)notify{
//    NSLog(@"视频截图成功");
//    UIImage *image = notify.userInfo[MPMoviePlayerThumbnailImageKey];
//    //保存图片到相册（首次调用会请求用户获访问相册权限）
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
