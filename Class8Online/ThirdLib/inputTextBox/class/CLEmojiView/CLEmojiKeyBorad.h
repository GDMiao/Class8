//
//  CLEmojiKeyBorad.h
//  EmojiView
//
//  Created by chuliangliang on 15/5/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import "CLEmojiView.h"

@protocol CLEmojiKeyBoradDelegate <NSObject>
@optional
- (void)didTouchimgName:(NSString *)nString imgIndexPath:(NSString *)indexpathString;

@end
@interface CLEmojiKeyBorad : UIView
@property (assign, nonatomic) id <CLEmojiKeyBoradDelegate>delegate;
- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
@end
