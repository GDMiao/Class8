//
//  VoicePlayerView.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/11.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, ChatVoiceOwnerType)
{
    ChatVoiceOwnerType_Me,   //语音拥有者 自己
    ChatVoiceOwnerType_Other,//语音拥有者 他人
};

@interface VoicePlayerView : UIView

@property (assign, nonatomic) ChatVoiceOwnerType ownerType;
@property (strong, nonatomic) NSString *filePath;//本地路径
- (void)updateVoicePath:(NSString *)path voiceShowTitle:(NSString *)title;
@end
