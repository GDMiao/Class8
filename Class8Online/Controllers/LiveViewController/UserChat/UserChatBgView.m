//
//  UserChatBgView.m
//  Class8Online
//
//  Created by chuliangliang on 15/8/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "UserChatBgView.h"
@interface UserChatBgView ()<UserChatViewDelegate,UIGestureRecognizerDelegate>
{
    CGRect chatViewShowRect;
    UITapGestureRecognizer *tapGesture;
}

@end
@implementation UserChatBgView

- (id)initWithFrame:(CGRect)frame uChatShowRect:(CGRect)showRect
{
    self = [super initWithFrame:frame];
    if (self) {
        chatViewShowRect = showRect;
        [self _initSubViews];
    }
    return self;
}
- (void)dealloc {
    self.uChatView = nil;
    if (tapGesture) {
        [self removeGestureRecognizer:tapGesture];
        tapGesture = nil;
    }
    self.delegate = nil;
}
- (void)_initSubViews {
    
    self.uChatView = [[UserChatView alloc] initWithFrame:chatViewShowRect atDelegate:self];
    self.uChatView.classID = self.classID;
    self.uChatView.myUid = [UserAccount shareInstance].uid;
    self.uChatView.top = self.height;
    [self addSubview:self.uChatView];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagpGestureAction:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

#pragma mark-
#pragma mark- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self];
    if (tapPoint.y > chatViewShowRect.origin.y) {
        CSLog(@"点击区域在单元格以内则不响应手势");
        return NO;
    }
    CSLog(@"点击区域在单元格以外响应手势");
    return YES;
}

- (void)tagpGestureAction:(UITapGestureRecognizer *)tap {
    
    if (self.uChatView.inPutTextView.isEditing) {
        [self.uChatView.inPutTextView hiddenAll];
    }else {
        [self hiddenUserChatView];
    }
}

#pragma mark -
#pragma mark - UserChatViewDelegate
- (void)userChatViewWillDisMiss
{
    CSLog(@"StudentListView==>关闭私聊页面");
    [self hiddenUserChatView];
}

- (void)userChatViewAddNewChat:(long long)uid
{
    if ([self.delegate respondsToSelector:@selector(userChatBgViewAddNewChat:)]) {
        [self.delegate userChatBgViewAddNewChat:uid];
    }
}


- (void)showUserChatView
{
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.uChatView.bottom = self.height;
    }];
}

- (void)hiddenUserChatView
{
    
    if ([self.delegate respondsToSelector:@selector(userChatBgViewWillDisMiss)]) {
        [self.delegate userChatBgViewWillDisMiss];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.uChatView.top = self.height;
    }completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)setOtherUid:(long long)otherUid {
    _otherUid = otherUid;
    self.uChatView.classID = self.classID;
    self.uChatView.otherUid = otherUid;
}
- (void)updateTitltText:(NSString *)string
{
    [self.uChatView updateTitltText:string];
}
@end
