//
//  SchoolNoticesViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/19.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "SchoolNoticesViewController.h"
#import "PublicNoticeCell.h"
#import "SchoolNoticeModel.h"
#import "CLLRefreshHeadController.h"
#import "SchNoticeDetailViewController.h"

const int onePageCount = 5;

const int totalRequestCount = 1;                           //初始化数据需要的全部请求个数
@interface SchoolNoticesViewController ()<CLLRefreshHeadControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    BOOL isAllocData;               // 是否初始化加载数据
    int didLoadRequestCount;        //已经成功返回数据的请求个数
    
}
@property (strong, nonatomic) CLLRefreshHeadController *refreshControll;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SchoolNoticeList *noticeList;
@property (strong, nonatomic) NSMutableArray *noticeData;
@property (strong, nonatomic) UIView *showView;

@end

@implementation SchoolNoticesViewController

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
    return self.noticeList.hasMore;
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
    [self _initNoticeData];
    
}

- (void)dealloc
{
    self.noticeData = nil;
    self.refreshControll = nil;
    self.noticeList = nil;
    self.showView = nil;
    self.tableView = nil;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noticeData = [[NSMutableArray alloc]init];
    [self.titleView setTitleText:@"学校公告" withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.frame = CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 64);
    self.tableView.frame = self.allContentView.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self _initNoticeData];
    
    [self _initRefrshController];
    
    UIView *messageV = [[UIView alloc]initWithFrame:CGRectMake(0, self.allContentView.height - 35, self.allContentView.width, 35)];
    messageV.backgroundColor = MakeColor(0xf7, 0xf7, 0xf9);
    [self.allContentView addSubview:messageV];
    
    UILabel *messageL = [[UILabel alloc]initWithFrame:messageV.bounds];
    messageL.textAlignment = NSTextAlignmentCenter;
    messageL.text = @"到底了,木有更多了!";
    [messageL setFont:[UIFont systemFontOfSize:14]];
    messageL.textColor = MakeColor(0xd8, 0xd8, 0xda);
    [messageV addSubview:messageL];
    
    self.showView = messageV;
    self.showView.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)leftClicked:(TitleView *)view
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_initNoticeData
{
    isAllocData = YES;
    didLoadRequestCount = 0;
    [self resetHttp];
    int page = MAX(1,(int)self.noticeList.list.count/onePageCount + 1);
    int rows = onePageCount;
    
    [http_ getSchoolPublicInfo:self.schoolId pageNum:page rows:rows jsonResPonseDelegate:self];
    
    [self showHUD:nil];
    
   
    
}

- (void)showNotDataNotice:(BOOL)isShow
{
    
    
    if (isShow) {
        self.showView.hidden = NO;
        
    }
    __weak SchoolNoticesViewController *sself = self;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        SchoolNoticesViewController *wwelf = sself;
        wwelf.showView.hidden = YES;

    });

}

- (void)refreshTableView {
    if (self.noticeList.list.count <= 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,self.allContentView.width, 20)];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"暂无公告";
        self.tableView.tableFooterView = label;
    }else {
        self.showView.hidden = self.noticeList.hasMore;

        self.tableView.tableFooterView = nil;
    }
    [self.tableView reloadData];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *urlString = [[request url]absoluteString];
    if ([urlString rangeOfString:@"school/messages"].location != NSNotFound) {
        SchoolNoticeList *tempNotice = [[SchoolNoticeList alloc] initWithJSON:[request responseJSON]];
        if (tempNotice.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount ++;
                if (tempNotice.list.count > 0) {
                    self.noticeList = tempNotice;
                }else
                {
                    [self.refreshControll endPullUpLoading];
                    [self.noticeList addNoticeList:tempNotice];
                }
            }
            
        }else
        {
            if (isAllocData) {
                isAllocData = NO;
                [self hiddenHUD];
            }
            [Utils showToast:@"未知错误"];
        }
    }
    
    if(isAllocData && didLoadRequestCount == totalRequestCount){
        // 初始化刷新数据成功
        self.tableView.hidden = NO;
        [self hiddenHUD];
        [self refreshTableView];
    }
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

- (NSInteger)getShowTableViewDataCount:(NSInteger)section
{
    if (self.noticeList.list > 0) {
        self.noticeData = self.noticeList.list;
        return self.noticeData.count;
    }else {
        return 0;
    }
}



#pragma mark ---
#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self getShowTableViewDataCount:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *noticeidn = @"notice";
   
    PublicNoticeCell *publicCell = [tableView dequeueReusableCellWithIdentifier:noticeidn];
    if (! publicCell) {
        UINib *nib = [UINib nibWithNibName:@"PublicNoticeCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:noticeidn];
        publicCell = [tableView dequeueReusableCellWithIdentifier:noticeidn];
 
    }
    
    [publicCell setCellNoticeContent:[self.noticeData objectAtIndex:indexPath.row]];
    
    return publicCell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PublicNoticeCell *publicCell = [PublicNoticeCell shareNoiceCell];
    return [publicCell setCellNoticeContent:[self.noticeData objectAtIndex:indexPath.row]];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSLog(@"点击%ld",indexPath.row);
    SchNoticeDetailViewController *noticeDVC = [[SchNoticeDetailViewController alloc]initWithNibName:nil bundle:nil];
    noticeDVC.noticeModel = self.noticeData[indexPath.row];
    [self.navigationController pushViewController:noticeDVC animated:YES];
 
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
