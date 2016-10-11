//
//  RoomWithChatView.h
//  FMDBDome
//
//  Created by chuliangliang on 15/7/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputTextBoxView.h"
#import "ChatDBObject.h"
#define InputTextBoxHeight 50

@protocol RoomWithChatViewDelegate <NSObject>

- (CGRect )roomWithChatViewViewChangedHeight:(CGFloat)height;
@end

@class ChatManager;
@interface RoomWithChatView : UIView
- (id)initWithFrame:(CGRect)frame atDelegate:(id)delegate;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, assign) BOOL canSendMsg,canSendMsg_person;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) long long classID,otherUid,myUid,courseID;
@property (nonatomic, strong) InputTextBoxView *inPutTextView;

/**
 *初始化数据
 **/
- (void)initChatDataWithDatabase;


/**
 *将聊天数据插入到数据库中
 **/
- (void)insertChatMsgIntoDB:(NSDictionary *)dic;

@end
