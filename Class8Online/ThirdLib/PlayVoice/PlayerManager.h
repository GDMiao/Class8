//
//  PlayerManager.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/11.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@class PlayerManager;
@protocol PlayerManagerDelegate <NSObject>
-(void)playDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime;//播放文件时长
-(void)startPlayVoice:(PlayerManager *)aPlayVoice;//开始播放
-(void)pausePlayVoice:(PlayerManager *)aPlayVoice;//暂停播放
-(void)stopPlayVoice:(PlayerManager *)aPlayVoice;//停止播放

@optional

@end

@interface PlayerManager : NSObject <playerDelegate>
@property (weak, nonatomic) id <PlayerManagerDelegate> delegate;
@property (strong, nonatomic) NSString *filePath; /*本地文件路径*/
- (void)setVoicePath:(NSString *)filePath callBack:(id)aDelegate;

- (void)playVoice;
- (void)stopVoice;

@end

