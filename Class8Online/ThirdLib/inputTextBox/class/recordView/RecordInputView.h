//
//  RecordInputView.h
//  InPutBoxView
//
//  Created by chuliangliang on 15-1-6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//
//由于时间紧迫 有可能不是非常完美 欢迎大家指正
//
//QQ: 949977202
//Email: chuliangliang300@sina.com

#import <UIKit/UIKit.h>
#import "Recorder.h"

@class RecordInputView;
@protocol RecordInputViewDelegate <NSObject>
- (void)recordInputView:(RecordInputView *)view recordFilePath:(NSString *)filePath fileTime:(int)time;

@end


@interface RecordInputView : UIView
- (id)initWithDelegate:(id/*<RecordInputViewDelegate>*/)aDelegate;
@end
