//
//  UserChatView.m
//  Class8Online
//
//  Created by chuliangliang on 15/8/5.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "UserChatView.h"
#import "InsertDBManagerQueue.h"
#import "ChatManager.h"
#import "ChatCell.h"

#define USERCHAT_TOOLS_HEIGHT 38
#define CloseBtnSize CGSizeMake(20, 20)
const int onePageloadMsgLen = 10;
@interface UserChatView ()<UITableViewDataSource, UITableViewDelegate,InputTextBoxViewDelegate>
{
    BOOL isScrollToBottom;
    BOOL isLoadingMore;
    UIActivityIndicatorView *loadActView;
    long long didLoadFirstMsgid;
    BOOL gifAnimate;
    CGFloat initView_Width;
}
@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) UIImageView *toolsView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak)   id<UserChatViewDelegate> delegate;

@end

@implementation UserChatView

- (void)dealloc {
    self.tableView = nil;
    self.inPutTextView = nil;
    if (loadActView) {
        loadActView = nil;
    }
    self.chatManager = nil;
    self.delegate = nil;
    self.toolsView = nil;
}
- (id)initWithFrame:(CGRect)frame atDelegate:(id)delegate
{
    self= [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self _initSubViews];
    }
    return self;
}
/**
 * 初始化控件
 **/
- (void)_initSubViews {
    
    initView_Width = self.width;
    didLoadFirstMsgid = 0;
    
    self.clipsToBounds = NO;
    
    self.toolsView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, USERCHAT_TOOLS_HEIGHT)];
    UIImage *toosImg = [UIImage imageNamed:@"讨论底"];
    toosImg = [toosImg resizableImageWithCapInsets:UIEdgeInsetsMake(4, 1, 4, 1)];
    self.toolsView.image = toosImg;
    self.toolsView.userInteractionEnabled = YES;
    [self addSubview:self.toolsView];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(self.toolsView.width - CloseBtnSize.width-13, (self.toolsView.height - CloseBtnSize.height) * 0.5, CloseBtnSize.width, CloseBtnSize.height);
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolsView addSubview:closeBtn];
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, closeBtn.left - 13-5, self.toolsView.height)];
    self.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.titleLabel.textColor = MakeColor(0x28, 0x28, 0x28);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.toolsView addSubview:self.titleLabel];

    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,USERCHAT_TOOLS_HEIGHT, self.bounds.size.width, self.bounds.size.height-UCHAT_InputTextBoxHeight - USERCHAT_TOOLS_HEIGHT) style:UITableViewStylePlain];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    self.inPutTextView = [[InputTextBoxView alloc] initWithDelegate:self showAtView:self];
    self.inPutTextView.isAutoChangeFrame = YES;
    [self addSubview:self.inPutTextView];
    
    self.chatManager = [[ChatManager alloc] init];
    
    self.canSendMsg = YES;
    self.canSendMsg_person = YES;
}

- (void)updateTitltText:(NSString *)string
{
    self.titleLabel.text = string;
}

- (void)closeAction {
    if ([self.delegate respondsToSelector:@selector(userChatViewWillDisMiss)]) {
        [self.delegate userChatViewWillDisMiss];
    }
    if (self.inPutTextView.isEditing) {
        [self.inPutTextView hiddenAll];
    }
}
/**
 * 初始化加载历史数据的菊花
 **/
- (void)_initLoadActView
{
    if (!loadActView) {
        loadActView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadActView.hidesWhenStopped = YES;
        [loadActView stopAnimating];
    }
}

/**
 * 加载更多历史消息
 **/
- (void)loadMore {
    CSLog(@"加载更多历史消息");
    isLoadingMore = YES;
    [self _initLoadActView];
    self.tableView.tableHeaderView = loadActView;
    [loadActView startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadChatDataFromDataBase];
    });
    
}

/**
 * 加载更多历史消息完成
 **/
- (void)finishLoadMore {
    isLoadingMore = NO;
    if (loadActView) {
        [loadActView stopAnimating];
        [loadActView removeFromSuperview];
        loadActView = nil;
        self.tableView.tableHeaderView = nil;
    }
}

/**
 * 从本地数据库中加载历史10条消息 及 初始进入加载最近 10条
 * 初次进入 msgid 传0 即可
 *
 ***/
- (void)loadChatDataFromDataBase
{
    NSArray *arr = [ChatDBObject getUserChatMsgListStarid:didLoadFirstMsgid listCount:onePageloadMsgLen courseId:self.classID myUserid:self.myUid otherUserID:self.otherUid];
    if (arr.count == 0) {
        CSLog(@"没有历史数据");
        if (isLoadingMore) {
            [self finishLoadMore];
            isLoadingMore = YES;
        }
        return;
    }
    
    if (didLoadFirstMsgid == 0) {
        [self.tableViewData addObjectsFromArray:arr];
        [self.tableView reloadData];
        [self tableViewScrollViewToBottom:0.01 animat:NO];
        isScrollToBottom = YES;
        
    }else {
        NSRange range = NSMakeRange (0, [arr count ]);
        NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange:range];
        [self.tableViewData insertObjects:arr atIndexes:set];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, arr.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self finishLoadMore];
    }
    ChatDBObject *c = [arr firstObject];
    didLoadFirstMsgid = c.msgId;
}

- (void)setOtherUid:(long long)otherUid {
    if (_otherUid != otherUid) {
        _otherUid = otherUid;
        [self.tableViewData removeAllObjects];
        self.tableViewData = nil;
        [self.tableView reloadData];
        [self initChatDataWithDatabase];
    }
}

/**
 *初始化数据
 **/
- (void)initChatDataWithDatabase{
    didLoadFirstMsgid = 0;
    self.tableViewData = [[NSMutableArray alloc] init];
    [self loadChatDataFromDataBase];
}

/**
 *将聊天数据插入到数据库中
 **/
- (void)insertChatMsgIntoDataBase:(ChatDBObject *)chat
{
    
    if ([self.delegate respondsToSelector:@selector(userChatViewAddNewChat:)]) {
        long long uid = chat.sendUid!=self.myUid?chat.sendUid:chat.reciveUid;
        [self.delegate userChatViewAddNewChat:uid];
    }
    
    if (chat.reciveUid != self.otherUid && chat.sendUid!=self.otherUid) {
        CSLog(@"当前插入的聊天信息不属于这个页面==>返回不处理");
        return;
    }
    if (isScrollToBottom) {
        [self.tableViewData addObject:chat];
        [self.tableView reloadData];
        if (didLoadFirstMsgid == 0) {
            didLoadFirstMsgid = chat.msgId;
        }
        [self tableViewScrollViewToBottom:0 animat:YES];
        //自动滚动
    }else {
        CGPoint tableOffset = self.tableView.contentOffset;
        if (didLoadFirstMsgid == 0) {
            didLoadFirstMsgid = chat.msgId;
        }
        [self.tableViewData addObject:chat];
        [self.tableView reloadData];
        [self.tableView setContentOffset:tableOffset];
    }
    
}
/**
 *将聊天数据插入到数据库中
 **/
- (void)insertChatMsgIntoDB:(NSDictionary *)dic
{
    CSLog(@"将私聊数据插入到数据库中:\nmsg:%@,\n misgID:%lld\nmsgTime:%lld",[dic objectForKey:CHAT_contentText],[[dic objectForKey:CHAT_msgId] longLongValue],[[dic objectForKey:CHAT_time] longLongValue]);
    __weak UserChatView *wself = self;
    [[InsertDBManagerQueue shareInsertDbObj] addData:dic callBack:^(ChatDBObject *chat) {
        UserChatView *sself = wself;
        [sself insertChatMsgIntoDataBase:chat];
    }];
}

#pragma mark-
#pragma mark- 自动滚动到底部
- (void)tableViewScrollViewToBottom:(float)time  animat:(BOOL)anim{
    UITableView *tableView = self.tableView;
    double delayInSeconds = time;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.tableViewData.count) {
            NSInteger row = MAX(self.tableViewData.count - 1, 0);
            if (self.tableViewData.count != 0 ) {
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row  inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:anim];
            }
        }
    });
}



#pragma mark -
#pragma mark- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.inPutTextView.isEditing) {
        [self.inPutTextView hiddenAll];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!isLoadingMore && scrollView.contentOffset.y < 0) {
        [self loadMore];
        
    }
    
    CGPoint offset = scrollView.contentOffset;  // 当前滚动位移
    CGRect bounds = scrollView.bounds;          // UIScrollView 可视高度
    CGSize size = scrollView.contentSize;         // 滚动区域
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    
    //当单元格滑动的偏移量 大于 (内容高度 - 30)的位置时就认定滑动到底部
    float reload_distance = 30;
    if (y > (h - reload_distance)) {
        isScrollToBottom = YES;
    }else {
        isScrollToBottom = NO;
    }
}




#pragma mark-
#pragma mark- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatDBObject *chat = [self.tableViewData objectAtIndex:indexPath.row];
    ChatCell *cell = [ChatCell shareChatCell];
    cell.contentWidth = initView_Width;
    CGFloat cellHeight = [cell cellHeight:chat];
    return cellHeight;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *chatCellIdn = @"ChatCell";
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:chatCellIdn];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"ChatCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:chatCellIdn];
        cell = [tableView dequeueReusableCellWithIdentifier:chatCellIdn];
    }
    ChatDBObject *chat = [self.tableViewData objectAtIndex:indexPath.row];
    cell.contentWidth = initView_Width;
    cell.gifAnimate = gifAnimate;
    [cell setChatText:chat];
    return cell;
}


#pragma mark -
#pragma mark - InputTextBoxViewDelegate
- (UIView *)InputTextBoxViewWithSmallFaceView:(InputTextBoxView *)inputTextBox
{
    CLEmojiInpuView *emojiView = [[CLEmojiInpuView alloc] initWithFrame:inputTextBox.frame imgConfigName:@"小表情" delegate:inputTextBox];
    return emojiView;
}
- (BOOL)hasSendText:(NSString *)text
{
    if (!self.canSendMsg) {
        [Utils showToast:CSLocalizedString(@"live_VC_room_chat_all_no")];
        return NO;
    }
    if (!self.canSendMsg_person) {
        [Utils showToast:CSLocalizedString(@"live_VC_room_chat_uesr_no")];
        return NO;
    }
    
    if (text.length > 800) {
        [Utils showToast:CSLocalizedString(@"live_VC_room_chat_len")];
        return NO;
    }
    
    return YES;
}

- (void)InputTextBoxViewChangedHeight:(float)height animateTime:(CGFloat)time {
    /**
     * 这里暂时不处理 高度变化
     **/
    
}
//发送文字
- (void)sendContext:(NSString *)text {
    NSString *contentText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (contentText.length <= 0) {
        return;
    }
    [self.chatManager sendUserMsg:text isGif:NO classID:self.classID recUid:self.otherUid];
}
/**
 * 发送表情 imgName : 图片名 idxpath: 图片id : 唯一标示
 **/
- (void)sendGifFace:(NSString *)imgName indxPath:(NSString *)idxpath
{
    [self.chatManager sendUserMsg:[NSString stringWithFormat:@"%@.gif",idxpath] isGif:YES classID:self.classID recUid:self.otherUid];
}

@end
