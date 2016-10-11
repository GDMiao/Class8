//
//  CLPlayer.h
//  CLPlayer
//
//  Created by chuliangliang on 15/6/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define NLSystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
#define IOS7 NLSystemVersionGreaterOrEqualThan(7.0)

#ifndef __OPTIMIZE__
#define CPLog(...) NSLog(__VA_ARGS__)
#else
#define CPLog(...) {}
#endif

@class CLPlayerLayer;
@interface CLPlayer : UIView
{
    CGFloat     totalMovieDuration; //视频总时长
    CGFloat     currentDuration;    //当前时间
    CGFloat     audioVolume;        //视频音量
}
- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)url;
@property (strong, nonatomic) CLPlayerLayer *clMovieLayer;
@property (strong, nonatomic) NSURL *movieUrl;
@property (strong, nonatomic) NSString *movieName;
@property (strong, nonatomic) UIActivityIndicatorView *Moviebuffer;

@property (assign, nonatomic) BOOL hasAudio; //是否有声音 默认yes
@property (assign,nonatomic,readonly) BOOL isPlaying;
@property (assign,nonatomic,readonly) BOOL isVideo;

- (void)play;
- (void)pause;
- (void)stop;
- (void)playAtTime:(int)time;
- (void)replay; //重播
/**
 *降低声音
 **/
- (void)audioDown;
/**
 * 提高声音
 **/
- (void)audioUp;
@end
