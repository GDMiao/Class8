//
//  HelpFeedbackViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/21.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "HelpFeedbackViewController.h"
#import "HelpFeedbackCell.h"
#import "FeedBackViewController.h"
#import "CLLRefreshHeadController.h"
const int onePageCount = 5;
const int totalRequestCount = 1;                           //初始化数据需要的全部请求个数
@interface HelpFeedbackViewController ()<CLLRefreshHeadControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL isAllocData;               // 是否初始化加载数据
    int didLoadRequestCount;        //已经成功返回数据的请求个数
    
}
@property (strong, nonatomic) CLLRefreshHeadController *refreshControll;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *HelpData;

@end

@implementation HelpFeedbackViewController
//====================================
// 刷新控件相关 初始化
//====================================
/**
 * 获取刷新控件 没有则创建
 **/
- (void )_initRefrshController {
    self.refreshControll = [[CLLRefreshHeadController alloc] initWithScrollView:self.tableView viewDelegate:self];
}
//====================================
// 刷新控件 代理回调
//====================================

#pragma mark-
#pragma mark- CLLRefreshHeadContorllerDelegate

- (BOOL)hasRefreshHeaderView
{
    return NO;
}

- (BOOL)hasRefreshFooterView
{
//    return self.noticeList.hasMore;
    return NO;
}
/**
 *开始下拉刷新
 **/
- (void)beginPullDownRefreshing {
    /**
     * 这里不使用下拉刷新头 此方法不实现
     **/
}

/***
 *开始上拉加载更多
 **/
- (void)beginPullUpLoading
{
    //
    [self _intiHelpData];
    
}
- (void)dealloc
{
    self.tableView = nil;
    self.HelpData = nil;
    self.refreshControll = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.HelpData = [[NSMutableArray alloc]init];
    [self.titleView setTitleText:@"帮助与反馈" withTitleStyle:CTitleStyle_LeftAndRight];
    [self.titleView setRightButonText:@"反馈"];
 
    self.allContentView.frame = CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 64);
    self.tableView.frame = self.allContentView.bounds;
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)_intiHelpData
{
    isAllocData = YES;
    didLoadRequestCount = 0;
    [self resetHttp];
//    int page = MAX(1,(int)self.noticeList.list.count/onePageCount + 1);
    int rows = onePageCount;
//    [http_ getSchoolPublicInfo:self.schoolId pageNum:page rows:rows jsonResPonseDelegate:self];
    
    [self showHUD:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
   
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    didLoadRequestCount = totalRequestCount;
    if (didLoadRequestCount == totalRequestCount) {
        //请求出错
        [self hiddenHUD];
        [Utils showToast:@"未知错误"];
    }
}

- (void)leftClicked:(TitleView *)view
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightClicked:(TitleView *)view
{
    FeedBackViewController *feedVC = [[FeedBackViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:feedVC animated:YES];
}

#pragma mark ----
#pragma mark ---- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.HelpData.count > 0) {
        return self.HelpData.count;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *helpIdn = @"helpcell";
    HelpFeedbackCell *cell = [tableView dequeueReusableCellWithIdentifier:helpIdn];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"HelpFeedbackCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:helpIdn];
        cell = [tableView dequeueReusableCellWithIdentifier:helpIdn];
    }
    NSString *text = @"课吧。";
    [cell setHelpCellContent:text];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = @"课吧。";
    return [[HelpFeedbackCell shareHelpFeedBackCell] setHelpCellContent:text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
