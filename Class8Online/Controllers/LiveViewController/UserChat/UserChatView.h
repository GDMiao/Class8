//
//  UserChatView.h
//  Class8Online
//
//  Created by chuliangliang on 15/8/5.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InputTextBoxView.h"
#import "ChatDBObject.h"
#define UCHAT_InputTextBoxHeight 50


@protocol UserChatViewDelegate <NSObject>

- (void)userChatViewWillDisMiss;

- (void)userChatViewAddNewChat:(long long)uid;
@end

@class ChatManager;

@interface UserChatView : UIView

- (id)initWithFrame:(CGRect)frame atDelegate:(id)delegate;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, assign) BOOL canSendMsg,canSendMsg_person;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) long long classID,otherUid,myUid;
@property (nonatomic, strong) InputTextBoxView *inPutTextView;


/**
 *初始化数据
 **/
- (void)initChatDataWithDatabase;

- (void)updateTitltText:(NSString *)string;

/**
 *将聊天数据插入到数据库中
 **/
- (void)insertChatMsgIntoDB:(NSDictionary *)dic;

@end
