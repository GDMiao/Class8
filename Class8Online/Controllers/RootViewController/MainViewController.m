//
//  MainViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MainViewController.h"
#import "MyCourseListCell.h"
#import "CourseDetailViewController.h"
#import "KeepOnLineUtils.h"
#import "LiveViewController.h"
#import "MyCourseList.h"

//===========================
//MainViewController
//===========================
const int myCourseListCount = 10;
@interface MainViewController ()
{
    BOOL isDidShowHUD;
}
@property (strong, nonatomic) MyCourseList *courseList;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isDidShowHUD = NO;
    [self.titleView setTitleText:CSLocalizedString(@"main_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 54, 0);
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = nil;
    [self startRefresh];
    
    //注册登录成功的通知 <自动登录/手动登录>
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccess) name:KNotificationDidLoginSuccess object:nil];

}

//#pragma mark-
//#pragma mark - Notificaiton
//- (void)LoginSuccess
//{
//    [self startRefresh];
//}

- (void)dealloc {
    self.tableView = nil;
    self.courseList = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *开始下拉刷新
 **/
- (void)beginRefreshing;
{
    CSLog(@"MainViewController ==> 我的课程页更新数据");
    [self loadMycourseList:0];
}

/**
 *开始上拉加载更多
 **/
- (void)beginloadMore
{
    [self loadMycourseList:(int)self.courseList.list.count];
}


/**
 *是显示加载更多 默认 NO
 **/
- (BOOL)hasRefreshFooterView {
    if (self.courseList) {
        return self.courseList.hasMore;
    }
    return NO;
}

/**
 * 获取我的课程列表
 **/
- (void)loadMycourseList:(int)start {
    [self resetHttp];
    [http_ myCourseList:start listRows:myCourseListCount userType:[UserAccount shareInstance].loginUser.authority == UserAuthorityType_STUDENT?UserAuthorityType_STUDENT:UserAuthorityType_TEACHER jsonResponseDelegate:self];
}

/**
 *刷新数据
 **/
- (void) requestFinishedOnRefresh :(NSDictionary *)json
{
    MyCourseList *tmpClurseList = [[MyCourseList alloc] initWithJSON:json];
    if (tmpClurseList.code_ == 0) {
        self.courseList = tmpClurseList;
        [self.tableView reloadData];
    }else {
        [Utils showToast:CSLocalizedString(@"main_VC_loadData_faild")];
    }
    [super requestFinishedOnRefresh:json];
}


/**
 *加载更多数据
 **/
- (void) requestFinishedOnNoRefresh:(NSDictionary *)json
{
    MyCourseList *tmpClurseList = [[MyCourseList alloc] initWithJSON:json];
    if (tmpClurseList.code_ == 0) {
        if (self.courseList) {
            [self.courseList addCourseList:tmpClurseList];
        }else {
            self.courseList = tmpClurseList;
        }
        [self.tableView reloadData];
    }else {
        [Utils showToast:CSLocalizedString(@"main_VC_loadData_faild")];
    }
    [super requestFinishedOnNoRefresh:json];

}


#pragma mark-
#pragma mark - HttpRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [super requestFailed:request];
    [Utils showToast:CSLocalizedString(@"main_VC_loadData_faild")];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateNavBarTitle:(NSString *)title {
    [self.titleView setTitleText:title];
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.courseList && self.courseList.list) {
        return self.courseList.list.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *idtifier = @"cell-myscoursecell";
    MyCourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"MyCourseListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:idtifier];
        cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    }
    cell.viewController = self;
    CourseModel *courseModel = [self.courseList.list objectAtIndex:indexPath.row];
    [cell setCellContent:courseModel];
    /*
    if (tableView.dragging == NO && tableView.decelerating == NO) {
        [cell beginLoadImg];
    }
     */
    return cell;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CourseModel *courseModel = [self.courseList.list objectAtIndex:indexPath.row];
    CGFloat cellHeight = [[MyCourseListCell shareCourseCell] setCellContent:courseModel];
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self showLoginVC]) {
        CourseModel *courseModel = [self.courseList.list objectAtIndex:indexPath.row];
        CourseDetailViewController *courseVC = [[CourseDetailViewController alloc] initWithCourseid:courseModel.courseID];
        [self.navigationController pushViewController:courseVC animated:YES];
    }
}

/*
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self cellBeginLoadImage];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self cellBeginLoadImage];
}

 //停止滑动并且手松开
 //单元格开始加载图片
- (void)cellBeginLoadImage
{
    if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *idx in visiblePaths) {
            MyCourseListCell *cell = [self.tableView cellForRowAtIndexPath:idx];
            if (cell) {
                [cell beginLoadImg];
            }
        }
    }
}
*/
@end
