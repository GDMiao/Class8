//
//  RefreshBasicViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/16.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "RefreshBasicViewController.h"

@interface RefreshBasicViewController ()
{
    UIView *tableViewMaskView;
}
@end

@implementation RefreshBasicViewController

//====================================
// 刷新控件相关 初始化
//====================================
/**
 * 获取刷新控件 没有则创建
 **/
- (CLLRefreshHeadController *)refreshControll {
    if (!_refreshControll) {
        _refreshControll = [[CLLRefreshHeadController alloc] initWithScrollView:self.tableView viewDelegate:self];
    }
    return _refreshControll;
}

//====================================
// 刷新控件 代理回调
//====================================

#pragma mark-
#pragma mark- CLLRefreshHeadContorllerDelegate
- (CLLRefreshViewLayerType)refreshViewLayerType
{
    return CLLRefreshViewLayerTypeOnSuperView;
}

/**
 *开始下拉刷新
 **/
- (void)beginPullDownRefreshing {
    isRefresh = YES;
    [self beginRefreshing];
}



/***
 *开始上拉加载更多
 **/
- (void)beginPullUpLoading
{
    isRefresh = NO;
    [self beginloadMore];
}

/**
 *是显示加载更多 默认 NO
 **/
- (BOOL)hasRefreshFooterView {
    return NO;
}


//=====================================
//TODO: 方法 父类声明子类实现
//=====================================

//下拉刷新
- (void)beginRefreshing
{

}
//上拉更多
- (void)beginloadMore
{
    
}

#pragma mark - 
#pragma mark - HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    [self removeTableViewMaskView];
    if (isRefresh) {
        [self requestFinishedOnRefresh:[request responseJSON]];
    }else {
        [self requestFinishedOnNoRefresh:[request responseJSON]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (isRefresh) {
        [[self refreshControll] endPullDownRefreshing];
    }else {
        [[self refreshControll] endPullUpLoading];
    }
    [self addTableViewMaskView];
}


/**
 *刷新数据
 **/
- (void) requestFinishedOnRefresh :(NSDictionary *)json
{
    [[self refreshControll] endPullDownRefreshing];
    [self addTableViewMaskView];
}

/**
 *加载更多数据
 **/
- (void) requestFinishedOnNoRefresh:(NSDictionary *)json
{
    [[self refreshControll] endPullUpLoading];
    [self addTableViewMaskView];
}


//显示遮罩遮挡下拉控件
- (void)addTableViewMaskView {
    if (self.tableView.contentSize.height <= 0) {
        if (!tableViewMaskView) {
            tableViewMaskView = [[UIView alloc] initWithFrame:self.tableView.frame];
            tableViewMaskView.backgroundColor = self.view.backgroundColor;
            [self.tableView addSubview:tableViewMaskView];
        }
    }
}

//移除遮罩
- (void)removeTableViewMaskView {
    if (tableViewMaskView) {
        [tableViewMaskView removeFromSuperview];
        tableViewMaskView = nil;
    }
}

- (void)dealloc {
    self.tableView = nil;
    self.refreshControll = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.height);
}

/**
 * 手动下拉刷新
 **/
- (void)startRefresh
{
    [[self refreshControll] startPullDownRefreshing];
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
