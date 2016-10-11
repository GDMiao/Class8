//
//  MP3Player.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/7/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MP3Player : NSObject <AVAudioPlayerDelegate>
@property (nonatomic,strong) AVAudioPlayer * audioPlayer;
@property (nonatomic,assign) BOOL isPlayeing;

+ (id)SharePlayer;
- (void)playMusicWithPath:(NSString *)path;
- (void)play;
- (void)pause;
- (void)stop;
- (void)setPlayerCurrentTime:(float)time;
@end
