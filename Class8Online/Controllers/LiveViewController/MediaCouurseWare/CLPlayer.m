//
//  CLPlayer.m
//  CLPlayer
//
//  Created by chuliangliang on 15/6/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CLPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SCGIFImageView.h"
#define AudioMaxVolume 1.0

@interface CLPlayerLayer : UIView
@property(nonatomic,strong) AVPlayer *player;

@end


@implementation CLPlayerLayer

+(Class)layerClass{
    return [AVPlayerLayer class];
}

-(AVPlayer*)player{
    return [(AVPlayerLayer*)[self layer]player];
}

-(void)setPlayer:(AVPlayer *)thePlayer{
    return [(AVPlayerLayer*)[self layer]setPlayer:thePlayer];
    
}

@end



@interface CLPlayer ()
{
    BOOL videoStopWithNetWork;  //是否是因为网络原因导致视频暂停 如 缓冲部分全部播放完成 默认No
    CGFloat videoCurrentTime;   //视频缓冲中断的时间点
    SCGIFImageView *currentImageView;
    BOOL isAutoReplay;          //是否自动重播
}
@property (strong, nonatomic)AVPlayerItem *playerItem;
@end

@implementation CLPlayer
@synthesize movieName = _movieName;
- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        _movieUrl = url;
        [self _initSubViews];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

/**
 * 初始化
 **/
- (void)_initSubViews {
    _isVideo = NO;
    
    //忽略系统声音开关
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    audioVolume = AudioMaxVolume;
    _hasAudio = YES;
    videoStopWithNetWork = NO;
    
    //视频播放图层
    self.backgroundColor = [UIColor blackColor];
    
    self.clMovieLayer = [[CLPlayerLayer alloc] initWithFrame:self.bounds];
    self.clMovieLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.clMovieLayer];
    
    //菊花
//    self.Moviebuffer = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    self.Moviebuffer.center  = self.center;
//    self.Moviebuffer.hidesWhenStopped = YES;
//    [self.Moviebuffer startAnimating];
//    [self addSubview:self.Moviebuffer];
    
    //封面<当播放音频是显示>
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"audioPlayIcon.gif" ofType:nil];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    currentImageView = [[SCGIFImageView alloc] initWithGIFData:data];
    currentImageView.start = NO;
    currentImageView.hidden = YES;
    currentImageView.frame  = self.bounds;
    [self addSubview:currentImageView];

    

    //缓冲部分全部播放完毕的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEndToFaild:) name:AVPlayerItemPlaybackStalledNotification object:nil];

    //程序挂起时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    //程序返回前台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillBecame:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    if (_movieUrl) {
        [self setContentUrl:_movieUrl];
    }
}

- (void)layoutSubviews {
    currentImageView.frame = self.bounds;
}

/**
 * 复写MOVEURL set 方法
 **/
- (void)setMovieUrl:(NSURL *)movieUrl {
    _movieUrl = movieUrl;
    
    [self setContentUrl:_movieUrl];
}

/**
 * 初始化视频播放器
 **/
- (void)setContentUrl:(NSURL *)moveUrl

{
    if (self.clMovieLayer) {
        [self.clMovieLayer.player pause];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.clMovieLayer.player.currentItem];
        //释放掉对playItem的观察
        [self.clMovieLayer.player.currentItem removeObserver:self
                                                  forKeyPath:@"status"
                                                     context:nil];
        [self.clMovieLayer.player.currentItem removeObserver:self
                                                  forKeyPath:@"loadedTimeRanges"
                                                     context:nil];
        self.clMovieLayer.player = nil;
    }
    
    //使用playerItem获取视频的信息，当前播放时间，总时间等
    self.playerItem = [AVPlayerItem playerItemWithURL:self.movieUrl]; //URLWithString /fileURLWithPath
    //player是视频播放的控制器，可以用来快进播放，暂停等
    AVPlayer *player = [AVPlayer playerWithPlayerItem:self.playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.clMovieLayer.player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.clMovieLayer setPlayer:player];
    if (!IOS7) {
        self.clMovieLayer.player.allowsAirPlayVideo = YES;
    }else {
        self.clMovieLayer.player.allowsExternalPlayback = YES;
    }
    _isPlaying = NO;
    if (!IOS7)
    {
        //计算视频总时间
        CMTime totalTime = self.playerItem.duration;
        //因为slider的值是小数，要转成float，当前时间和总时间相除才能得到小数,因为5/10=0
        totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
        NSDate *d = [NSDate dateWithTimeIntervalSince1970:totalMovieDuration];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if (totalMovieDuration/3600 >= 1) {
            [formatter setDateFormat:@"HH:mm:ss"];
        }
        else
        {
            [formatter setDateFormat:@"mm:ss"];
        }
        NSString *showtimeNew = [formatter stringFromDate:d];
        CPLog(@"CLPlayer==> totalMovieDuration:%@",showtimeNew);
        
        
    }
    
    //检测视频加载状态，加载完成隐藏风火轮
    [self.clMovieLayer.player.currentItem addObserver:self forKeyPath:@"status"
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
    [self.clMovieLayer.player.currentItem  addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //添加视频播放完成的notifation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.clMovieLayer.player.currentItem];

    NSArray *tmpAssetArr = [self.playerItem.asset tracksWithMediaType:AVMediaTypeVideo];
    if (tmpAssetArr.count <= 0) {
        //音频
        CPLog(@"CLPlayer==> 当前播放音频文件");
        currentImageView.hidden = NO;
        _isVideo = NO;
    }else {
        //视频
        CPLog(@"CLPlayer==> 当前播放视频文件");
        currentImageView.hidden = YES;
        _isVideo = YES;
    }
}


/**
 * 观察者 监听视频加载状态
 **/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        CPLog(@"CLPlayer==> 媒体文件缓冲....");
        if (playerItem.status==AVPlayerStatusReadyToPlay) {
            //视频加载完成
            if (IOS7)
            {
                //计算视频总时间
                CMTime totalTime = playerItem.duration;
                totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
                NSDate *d = [NSDate dateWithTimeIntervalSince1970:totalMovieDuration];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                if (totalMovieDuration/3600 >= 1) {
                    [formatter setDateFormat:@"HH:mm:ss"];
                }
                else
                {
                    [formatter setDateFormat:@"mm:ss"];
                }
                NSString *showtimeNew = [formatter stringFromDate:d];
                CPLog(@"CLPlayer==>  媒体文件总时间iOS7 之后: %@",showtimeNew);
            }
        }else if (playerItem.status == AVPlayerStatusFailed || playerItem.status == AVPlayerStatusUnknown) {
            NSInteger errorCode = playerItem.error.code;
            CPLog(@"CLPlayer==>  媒体文件加载错误: code = %ld",(long)errorCode);
            switch (errorCode) {
                case kCFURLErrorBadServerResponse:
                {
                    CPLog(@"CLPlayer==> 媒体文件加载失败: 服务器错误/视频地址错误");
                }
                    break;
                case kCFURLErrorCannotFindHost:
                {
                    CPLog(@"CLPlayer==>  媒体文件加载失败: 服务器未找到");
                }
                    break;
                case kCFURLErrorFileDoesNotExist:
                {
                    CPLog(@"CLPlayer==>  媒体文件加载失败:媒体文件文件不存在");
                }
                    break;
                case kCFURLErrorNetworkConnectionLost:
                {
                    CPLog(@"CLPlayer==>  加载失败:媒体文件地址连接失败");
                }
                    break;
                case kCFURLErrorNotConnectedToInternet:
                case kCFURLErrorCannotConnectToHost:
                {
                    CPLog(@"CLPlayer==> 媒体文件加载失败:网络连接失败");
                }
                    break;
                case kCFURLErrorTimedOut:
                {
                    CPLog(@"CLPlayer==> 媒体文件加载失败:网络连接超时");
                }
                    break;
                default:
                    break;
            }
                isAutoReplay = NO;
        }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        float bufferTime = [self availableDuration];
        float durationTime = CMTimeGetSeconds([[self.clMovieLayer.player currentItem] duration]);
        CPLog(@"CLPlayer==> 媒体文件缓冲进度%f 百分比:%f",bufferTime,bufferTime/durationTime);
        if (videoStopWithNetWork && _isPlaying && fabs(bufferTime - videoCurrentTime) > 0.5) {
            CPLog(@"CLPlayer==> 媒体文件继续播放: 时间:%f",videoCurrentTime);
            videoStopWithNetWork = NO;
//            [self.Moviebuffer stopAnimating];
            [self videoProgressControl:videoCurrentTime];
        }

    }
    
}

/**
 * 加载进度
 **/
- (float)availableDuration
{
    NSArray *loadedTimeRanges = [[self.clMovieLayer.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}

/**
 * 播放完成通知
 **/
-(void)moviePlayDidEnd:(NSNotification*)notification{
    //视频播放完成
    _isPlaying = NO;
    CPLog(@"CLPlayer==> 媒体文件播放完成");
    
    if (isAutoReplay) {
        //播放完成自动重拨
        [self replay];
        _isPlaying = NO;
        CPLog(@"CLPlayer==> 自动重播");
    }

}

/**
 * 视频缓冲部分全部播放完毕停止
 **/
- (void)moviePlayDidEndToFaild:(NSNotification *)notification {
//    [self.Moviebuffer startAnimating];
    videoStopWithNetWork = YES;
    
    //获取当前时间
    CMTime currentTime = self.clMovieLayer.player.currentItem.currentTime;
    //转成秒数
    videoCurrentTime = (CGFloat)currentTime.value/currentTime.timescale;
    CPLog(@"CLPlayer==> 媒体文件moviePlayDidEndToFaild");
}

/**
 * 程序进入后台
 **/
-(void)applicationWillResignActive:(NSNotification *)notification
{
    _isPlaying = NO;
    CPLog(@"CLPlayer==> 进入后台");
}

/**
 * 程序返回前台通知
 **/
- (void)applicationWillBecame:(NSNotification *)notification {
    _isPlaying = YES;
    CPLog(@"CLPlayer==> 回到前台");
}


/**
 * 视频播放进度控制
 **/
- (void) videoProgressControl:(CGFloat)newTime {
    if (newTime >= totalMovieDuration)
    {
        if (_isPlaying == YES)
        {
            [self.clMovieLayer.player play];
        }
        return;
    }
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(newTime, 1);
    [self.clMovieLayer.player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish)
     {
         [self.clMovieLayer.player play];
     }];
    _isPlaying = YES;
}


- (void)dealloc {
    //释放对视频播放完成的监测
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.clMovieLayer.player.currentItem];
    //释放掉对playItem的观察
    [self.clMovieLayer.player.currentItem removeObserver:self
                                              forKeyPath:@"status"
                                                 context:nil];
    [self.clMovieLayer.player.currentItem removeObserver:self
                                              forKeyPath:@"loadedTimeRanges"
                                                 context:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    self.Moviebuffer = nil;
    self.movieName = nil;
    if (_movieUrl) {
        _movieUrl = nil;
    }
    self.clMovieLayer = nil;
    
}

//===============================
//TODO: 方法
//===============================
- (void)play
{
    ClassRoomLog(@"CLPlayer==> play");
    _isPlaying = YES;
    isAutoReplay = YES;
    videoStopWithNetWork = NO;
    if (!self.isVideo) {
        currentImageView.start = YES;
    }
    [self.clMovieLayer.player play];
}
- (void)pause {
    _isPlaying = NO;
    isAutoReplay = NO;
    ClassRoomLog(@"CLPlayer==> pause");
    if (!self.isVideo) {
        currentImageView.start = NO;
    }
    [self.clMovieLayer.player pause];
}

- (void)stop {
    ClassRoomLog(@"CLPlayer==> stop");
    _isPlaying = NO;
    isAutoReplay = NO;
    if (!self.isVideo) {
        currentImageView.start = NO;
    }
    [self.clMovieLayer.player pause];
}


- (void)playAtTime:(int)time {
    

    CMTime ctime = self.clMovieLayer.player.currentTime;
    UInt64 currentTimeSec = ctime.value/ctime.timescale;
    ClassRoomLog(@"CLPlayer==> playAtTime:%d 总时间:%f 当前播放时间:%lld 调整时间:%d",time,totalMovieDuration,currentTimeSec,time);
    int cbTime = time - (int)currentTimeSec;
    if (abs(cbTime) <= 5) {
        ClassRoomLog(@"CLPlayer==> 播放时间调整 时差小于5s 不做操作");
        return;
    }
    if (!self.isVideo) {
        currentImageView.start = YES;
    }
    isAutoReplay = YES;
    [self videoProgressControl:time];
}

//重播
- (void)replay
{
    [self videoProgressControl:0.0];
}

/**
 *降低声音
 **/
- (void)audioDown
{
    audioVolume -= 0.1;
    audioVolume = MAX(audioVolume, 0);
    [self audioControl:audioVolume];
}
/**
 * 提高声音
 **/
- (void)audioUp
{
    audioVolume += 0.1;
    audioVolume = MIN(1.0, audioVolume);
    [self audioControl:audioVolume];
}

/**
 音量控制
 **/
- (void)audioControl:(CGFloat)volume {
    
    CPLog(@"CLPlayer==> 音量控制: %f",audioVolume);
    if (IOS7) {
        //iOS7 之后
        self.clMovieLayer.player.volume = volume;
    }else {
        //iOS7 之前
        NSArray*audioTracks = [self.playerItem.asset tracksWithMediaType:AVMediaTypeAudio];
        NSMutableArray*allAudioParams = [NSMutableArray array];
        for (AVAssetTrack *track in audioTracks) {
            AVMutableAudioMixInputParameters*audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
            [audioInputParams setVolume:volume atTime:kCMTimeZero];
            [audioInputParams setTrackID:[track trackID]];
            [allAudioParams addObject:audioInputParams];
        }
        
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        [audioMix setInputParameters:allAudioParams];
        [self.playerItem setAudioMix:audioMix];
    }
    if (audioVolume > 0) {
        _hasAudio = YES;
    }
}

/**
 * 静音/取消静音
 **/
- (void)setHasAudio:(BOOL)hasAudio {
    _hasAudio = hasAudio;
    if (_hasAudio) {
        CPLog(@"CLPlayer==> 取消静音:%f",audioVolume);
        self.clMovieLayer.player.volume = audioVolume;
    }else {
        //静音是记下当前音量
        audioVolume = self.clMovieLayer.player.volume;
        CPLog(@"CLPlayer==> 静音记下当前音量:%f",audioVolume);
        self.clMovieLayer.player.volume = 0;
    }
}


@end
