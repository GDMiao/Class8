//
//  CLEmojiInpuView.h
//  EmojiView
//
//  Created by chuliangliang on 15/5/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLEmojiInpuView;
@protocol CLEmojiInpuViewDelegate <NSObject>

@optional
- (void)cLEmojiInpuView:(CLEmojiInpuView *)view didTouchimgName:(NSString *)nString imgIndexPath:(NSString *)indexpathString;

@end
@interface CLEmojiInpuView : UIView
- (id)initWithFrame:(CGRect)frame imgConfigName:(NSString*)pName delegate:(id)aDelegate;
@property (weak,nonatomic) id<CLEmojiInpuViewDelegate> delegate;

@end
