//
//  ChatCell.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "ChatCell.h"
#import "CoreTextUtil.h"
#import "UIImageView+WebCache.h"
//
//#import "NSAttributedString+Attributes.h"
//#import "MarkupParser.h"
//#import "CustomMethod.h"

static ChatCell *sharedInstance = nil;
@implementation ChatCell

- (void)dealloc {
    self.sysTemMsgLabel = nil;
    if (_chat) {
        _chat = nil;
    }
    
    self.userAvatar = nil;
    self.userAvatarMaskView = nil;
    self.userNickLabel = nil;
    self.contenTextView = nil;
    self.chatBjView = nil;
}
- (void)awakeFromNib {
    [self _initView];
}

-(id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil];
    self = [nib lastObject];
    if (self) {
    }
    return self;
}
- (void)_initView {
    
    
    self.userAvatarMaskView.image = [UIImage imageNamed:@"学生大头像遮罩"];
    self.contenTextView.placeholderImage = [UIImage imageNamed:@"默认图片"];
}

+ (ChatCell *)shareChatCell
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
    
}
- (CGFloat)cellHeight:(ChatDBObject *)value
{
    [self setChatText:value];
    return cellAllHeight;
}

//创建NSAttributedString  NSString 转 NSAttributedString <弃用>
//- (NSAttributedString *)contentAttrigutedStringWithString:(NSString *)content textColor:(NSString *)tColor{
//    
//    //匹配GIF表情
//    NSString * tmpString = [CoreTextUtil addGIFEmoji:content gifSize:CGSizeMake(25, 25)];
//
//    //匹配网络图片
//    NSString *textHtml = [CoreTextUtil addImage:tmpString imageMaxWidth:0];
//
//    //设置换行类型
//    textHtml = [CoreTextUtil setTextLineBreak:textHtml warpText:@"break-word"];
//    textHtml = [CoreTextUtil addContent:textHtml color:tColor fontSize:12];
//    return [CoreTextUtil createAttribitedString:textHtml font:12];;
//}

//创建NSAttributedString  HTML String 转 NSAttributedString for 2016/02/23
- (NSAttributedString *)contentAttrigutedStringWithHTMLString:(NSString *)content textColor:(NSString *)tColor{
    content = [CoreTextUtil setTextLineBreak:content warpText:@"break-word"];
    content = [CoreTextUtil addContent:content color:tColor fontSize:15];
    return [CoreTextUtil createAttribitedString:content font:15];;
}

- (void)setChatText:(ChatDBObject *)chat
{
    
    self.chat = chat;
    //    CSLog(@"消息:%@ 时间:%@",self.chat.text,self.chat.time);
    if (self.chat.isSystemMsg) {
        //系统消息
        [self setSystemMsg:self.chat];
        
        self.userAvatar.hidden = YES;
        self.userAvatarMaskView.hidden = YES;
        self.chatBjView.hidden = YES;
        self.userNickLabel.hidden = YES;
        self.contenTextView.hidden = YES;
    }else {
        self.sysTemMsgLabel.hidden = YES;
        //非系统消息
        if (self.chat.sendUid == [UserAccount shareInstance].uid) {
            //自己
            [self setMyChat:self.chat];
        }else {
            //别人
            [self setOtherUserChat:self.chat];
        }
    }
    
    if (self.chat.isSystemMsg) {
        cellAllHeight = self.sysTemMsgLabel.bottom + 5;
    }else {
        cellAllHeight = self.chatBjView.bottom;
    }
}


//展示系统消息
- (void)setSystemMsg:(ChatDBObject *)aChat
{
    self.sysTemMsgLabel.hidden = NO;
    self.sysTemMsgLabel.width = self.contentWidth;
    self.sysTemMsgLabel.text = [NSString stringWithFormat:@"%@:%@",CSLocalizedString(@"live_VC_room_chat_system"),aChat.contentText];
    [self.sysTemMsgLabel sizeToFit];
    self.sysTemMsgLabel.frame = CGRectMake(13, 5, self.contentWidth, self.sysTemMsgLabel.height);
}


//别人对话
- (void)setOtherUserChat:(ChatDBObject *)aChat {
    
    self.userAvatar.hidden = NO;
    self.userAvatarMaskView.hidden = NO;
    self.chatBjView.hidden = NO;
    self.userNickLabel.hidden = NO;
    self.contenTextView.hidden = NO;
    
    self.userAvatar.frame = CGRectMake(13, 18, 30, 30);
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%lld/%d/%lld.jpg",SignPicDown,self.chat.courseID,0/*self.chat.classId*/,self.chat.sendUid]] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    self.userAvatarMaskView.frame = self.userAvatar.frame;
    
    self.userNickLabel.frame = CGRectMake(self.userAvatar.right + 5, self.userAvatar.top, 0,0);
    self.userNickLabel.text = aChat.sendUserNick;
    [self.userNickLabel sizeToFit];
    
    self.chatBjView.frame = CGRectMake(self.userNickLabel.left, self.userNickLabel.bottom + 5, 0, 0);
    UIImage *cImage = [UIImage imageNamed:@"对话框"];
    cImage = [cImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 30.0f, 20.0f, 20.0f)];
    self.chatBjView.image = cImage;
    
    
    CGSize chatContentSize = CGSizeZero;
    //文字/表情/图片
    NSString* txt = aChat.contentText;
    self.contenTextView.attributedString = [self contentAttrigutedStringWithHTMLString:txt textColor:@"#282828"];
    self.contenTextView.width = self.contentWidth - (self.chatBjView.left * 2)-25;
    [self.contenTextView sizeToFit];
    self.contenTextView.top = self.chatBjView.top + 10;
    self.contenTextView.left = self.chatBjView.left + 15;
    chatContentSize = self.contenTextView.size;
    self.contenTextView.backgroundColor = [UIColor clearColor];
    
    self.chatBjView.size = CGSizeMake(chatContentSize.width + 25, chatContentSize.height + 20);
}


//自己对话
- (void)setMyChat:(ChatDBObject *)aChat {
    
    self.userAvatar.hidden = NO;
    self.userAvatarMaskView.hidden = NO;
    self.userNickLabel.hidden = NO;
    self.chatBjView.hidden = NO;
    self.contenTextView.hidden = NO;
    
    self.userAvatar.frame = CGRectMake(self.contentWidth - 30 - 13, 18, 30, 30);
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%lld/%d/%lld.jpg",SignPicDown,self.chat.courseID,0/*self.chat.classId*/,self.chat.sendUid]] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    self.userAvatarMaskView.frame = self.userAvatar.frame;
    
    self.userNickLabel.frame = CGRectMake(0, self.userAvatar.top, 0,0);
    //去掉自己昵称显示
    self.userNickLabel.text = aChat.sendUserNick;
    self.userNickLabel.width = 150;
    [self.userNickLabel sizeToFit];
    self.userNickLabel.right = self.userAvatar.left - 5;
    
    self.chatBjView.frame = CGRectMake(0, self.userNickLabel.bottom + 5, 0, 0);
    UIImage *cImage = [UIImage imageNamed:@"我的对话框"];
    cImage = [cImage resizableImageWithCapInsets:UIEdgeInsetsMake(25.0f, 15.0f, 15.0f, 25.0f)];
    self.chatBjView.image = cImage;
    
    
    CGSize chatContentSize = CGSizeZero;
    
    //文字/表情/图片
    NSString* txt = aChat.contentText;
    CGFloat textWidth = self.contentWidth - (self.contentWidth - self.userNickLabel.right) * 2 - 25;
    self.contenTextView.attributedString = [self contentAttrigutedStringWithHTMLString:txt textColor:@"#282828"];
    self.contenTextView.width = textWidth;
    [self.contenTextView sizeToFit];
    self.contenTextView.backgroundColor = [UIColor clearColor];
    chatContentSize = self.contenTextView.size;
    self.chatBjView.size = CGSizeMake(chatContentSize.width + 25, chatContentSize.height + 20);
    self.chatBjView.right = self.userNickLabel.right;
    self.contenTextView.top = self.chatBjView.top + 10;
    self.contenTextView.left = self.chatBjView.left + 10;


    
    
}

@end
