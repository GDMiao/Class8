//
//  ChatCell.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTextView.h"
#import "ChatDBObject.h"


@interface ChatCell : UITableViewCell
{
    CGFloat cellAllHeight;
}
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarMaskView;
@property (weak, nonatomic) IBOutlet UILabel *userNickLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatBjView;
@property (weak, nonatomic) IBOutlet UILabel *sysTemMsgLabel;
@property (weak, nonatomic) IBOutlet CoreTextView *contenTextView;

@property (strong, nonatomic) ChatDBObject *chat;
@property (assign, nonatomic) CGFloat contentWidth;
@property (assign, nonatomic) BOOL gifAnimate;

- (void)setChatText:(ChatDBObject *)chat;

+ (ChatCell *)shareChatCell;
- (CGFloat)cellHeight:(ChatDBObject *)value;

@end
