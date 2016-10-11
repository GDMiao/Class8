//
//  CourseWithCommentsView.m
//  Class8Online
//
//  Created by chuliangliang on 15/5/14.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CourseWithCommentsView.h"
#import "CourseWithCommentsCell.h"
#import "CommentsModel.h"

@interface CourseWithCommentsView () <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@end

const int commentOnrPageCount = 5;
@implementation CourseWithCommentsView

- (void)dealloc
{
    self.viewController = nil;
    self.tableView = nil;
    self.refreshControll = nil;
    self.dataList = nil;
    if (http_) {
        http_ = nil;
    }
}

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
    return CLLRefreshViewLayerTypeOnScrollViews;
}

/**
 *开始下拉刷新
 **/
- (void)beginPullDownRefreshing {
    
    isRefresh = YES;
    [self courseWareList];

}

/***
 *开始上拉加载更多
 **/
- (void)beginPullUpLoading
{
    isRefresh = NO;
    [self courseWareList];
}

/**
 *是显示加载更多 默认 NO
 **/
- (BOOL)hasRefreshFooterView {
    return self.dataList.hasMore;
}

/**
 * 手动下拉刷新
 **/
- (void)startRefresh
{
    [[self refreshControll] startPullDownRefreshing];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews {
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (IS_IOS7) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if (IS_IOS8) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    [self addSubview:self.tableView];
}


- (void)courseWareList
{
    [self resetHttp];
    int page = MAX(1,(int)self.dataList.list.count/commentOnrPageCount + 1);
    [http_ getCourseComment:self.courseid page:page rows:commentOnrPageCount jsonResPonseDelegate:self];
}

- (void)resetHttp {
    if (!http_) {
        http_ = [[HttpRequest alloc] init];
    }
}
/**
 * http请求成功后的回调
 */
- (void)requestFinished:(ASIHTTPRequest *) request
{
    CSLog(@"评论: %@",[request responseJSON]);
    CommentList *tmpList = [[CommentList alloc] initWithJSON:[request responseJSON]];
    if (tmpList.code_ == 0) {
        if (isRefresh) {
            self.dataList = tmpList;
            [[self refreshControll] endPullDownRefreshing];
        }else {
            if (!self.dataList) {
                self.dataList = tmpList;
            }else {
                [self.dataList addList:tmpList];
            }
            [[self refreshControll] endPullUpLoading];
        }
        [self refreshTableView];
    }else {
        [Utils showToast:CSLocalizedString(@"courseDetail_VC_load_Faild")];
    }
}
/**
 * http请求失败后的回调
 */
- (void)requestFailed:(ASIHTTPRequest *) request
{
    [Utils showToast:CSLocalizedString(@"courseDetail_VC_load_Faild")];
    if (isRefresh) {
        [[self refreshControll] endPullDownRefreshing];
    }else {
        [[self refreshControll] endPullUpLoading];
    }
}

//刷新单元格
- (void)refreshTableView {
    if (self.dataList.list.count <= 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,self.width, 20)];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = CSLocalizedString(@"courseDetail_Comment_no_data");
        self.tableView.tableFooterView = label;
    }else {
        self.tableView.tableFooterView = nil;
    }
    [self.tableView reloadData];
}

#pragma mark-
#pragma mark -  UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idtifier = @"cell-CourseWithCommentsCell";
    CourseWithCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"CourseWithCommentsCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:idtifier];
        cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    }
    cell.viewController = self.viewController;
    if (indexPath.row == 0) {
        cell.totalScore = self.avgScore;
    }else{
        cell.totalScore = -1;
    }
    
    [cell setCellContentModel:[self.dataList.list objectAtIndex:indexPath.row]];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CourseWithCommentsCell *cell  = [CourseWithCommentsCell shareCourseWithCommentsCell];
    if (indexPath.row == 0) {
        cell.totalScore = 4.0;
    }else{
        cell.totalScore = -1;
    }
    return [cell setCellContentModel:[self.dataList.list objectAtIndex:indexPath.row]];
}
@end
