//
//  RefreshBasicViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/16.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "CLLRefreshHeadController.h"

@interface RefreshBasicViewController : BasicViewController<CLLRefreshHeadControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    BOOL isRefresh;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)CLLRefreshHeadController *refreshControll;

/**
 *开始下拉刷新
 **/
- (void)beginRefreshing;

/**
 *开始上拉加载更多
 **/
- (void)beginloadMore;

/**
 *是显示加载更多 默认 NO
 **/
- (BOOL)hasRefreshFooterView;

/**
 * 手动下拉刷新
 **/
- (void)startRefresh;

/**
 *加载更多数据
 **/
- (void) requestFinishedOnNoRefresh:(NSDictionary *)json;

/**
 *刷新数据
 **/
- (void) requestFinishedOnRefresh :(NSDictionary *)json;

@end
