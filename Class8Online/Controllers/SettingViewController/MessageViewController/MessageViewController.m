//
//  MessageViewController.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/8/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageTableViewCell.h"
#import "NoticesModel.h"
#import "NoticeDeatilViewController.h"
@interface MessageViewController ()
@property (nonatomic, strong) NoticesList *messageList;
@end

const int messageOnePageCount = 10;
@implementation MessageViewController

- (void)dealloc
{
    self.tableView = nil;
    self.messageList = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:CSLocalizedString(@"msg_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    [self startRefresh];
}


/**
 *开始下拉刷新
 **/
- (void)beginRefreshing;
{
    [self loadNoticeList:0];
}

/**
 *开始上拉加载更多
 **/
- (void)beginloadMore
{
    [self loadNoticeList:self.messageList.list.count];
}


/**
 *是显示加载更多 默认 NO
 **/
- (BOOL)hasRefreshFooterView {
    if (self.messageList) {
        return self.messageList.hasMore;
    }
    return NO;
}



- (void)loadNoticeList:(int)start
{
    [self resetHttp];
    [http_ getNoticeMessage:[UserAccount shareInstance].uid msgStart:start msgLoadCount:messageOnePageCount msgType:NoticesType_Person jsonResponseDelegate:self];
}

- (void)hasReadMessage:(long long)msgID
{
    [self resetHttp];
    [http_ noticeMessageDidRead:msgID userid:[UserAccount shareInstance].uid jsonResponseDelegate:self];
}

#pragma mark -
#pragma mark - HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"mobilemessageAll"].location != NSNotFound) {
        [super requestFinished:request];
    }else {
    
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"mobilemessageAll"].location != NSNotFound) {
        [super requestFinished:request];
    }else {
        
    }
}

/**
 *刷新数据
 **/
- (void) requestFinishedOnRefresh :(NSDictionary *)json
{
    CSLog(@"requestFinishedOnRefresh: %@", json);
    NoticesList *tmpNoticelist = [[NoticesList alloc] initWithJSON:json];
    if (tmpNoticelist.code_ == 0) {
        self.messageList = tmpNoticelist;
        [self.tableView reloadData];
    }else {
        [Utils showToast:CSLocalizedString(@"msg_VC_load_faild")];
    }
    [super requestFinishedOnRefresh:json];
}


/**
 *加载更多数据
 **/
- (void) requestFinishedOnNoRefresh:(NSDictionary *)json
{
    NoticesList *tmpNoticelist = [[NoticesList alloc] initWithJSON:json];
    if (tmpNoticelist.code_ == 0) {
        if (self.messageList) {
            [self.messageList addNotices:tmpNoticelist];
        }else {
            self.messageList = tmpNoticelist;
        }
        [self.tableView reloadData];
    }else {
        [Utils showToast:CSLocalizedString(@"msg_VC_load_faild")];
    }
    [super requestFinishedOnNoRefresh:json];
}





#pragma TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.messageList && self.messageList.list.count) {
        return self.messageList.list.count;
    }
    return 0;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoticesModel *notice = [self.messageList.list objectAtIndex:indexPath.row];
    return [[MessageTableViewCell shareMsgCell] setContentNotice:notice];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    cell.viewController = self;
    NoticesModel *notice = [self.messageList.list objectAtIndex:indexPath.row];
    [cell setContentNotice:notice];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NoticesModel *notice = [self.messageList.list objectAtIndex:indexPath.row];
    if (!notice.readFlag) {
        notice.readFlag = YES;
        [self hasReadMessage:notice.msgId];
        [self.tableView reloadData];
    }
    NoticeDeatilViewController *noticeDetailVC = [[NoticeDeatilViewController alloc] initWithNibName:nil bundle:nil AtNotice:notice];
    [self.navigationController pushViewController:noticeDetailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
