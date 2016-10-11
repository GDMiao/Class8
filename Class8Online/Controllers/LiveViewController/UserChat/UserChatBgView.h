//
//  UserChatBgView.h
//  Class8Online
//
//  Created by chuliangliang on 15/8/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserChatView.h"

@protocol UserChatViewBgDelegate <NSObject>
@optional;
- (void)userChatBgViewAddNewChat:(long long)uid;

- (void)userChatBgViewWillDisMiss;
@end

@interface UserChatBgView : UIView
@property (assign, nonatomic) long long classID,otherUid;
@property (nonatomic, strong) UserChatView *uChatView;
@property (weak, nonatomic) id<UserChatViewBgDelegate>delegate;
- (id)initWithFrame:(CGRect)frame uChatShowRect:(CGRect)showRect;

- (void)showUserChatView;
- (void)updateTitltText:(NSString *)string;
@end
