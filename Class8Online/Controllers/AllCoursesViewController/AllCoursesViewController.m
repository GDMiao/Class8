//
//  AllCoursesViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "AllCoursesViewController.h"
#import "ClassModel.h"
#import "CourseModel.h"
#import "PianoCourseCell.h"
#import "AllCoursesCell.h"
#import "LiveViewController.h"
#import "TeaLiveViewController.h"
#import "CourseDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "CLLRefreshHeadController.h"
const int totalRequestCount = 1;                           //初始化数据需要的全部请求个数
const int onePageCount = 6;
@interface AllCoursesViewController ()<CLLRefreshHeadControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>
{
    BOOL isAllocData;               //是否初始化加载数据
    int didLoadRequestCount;        //已经成功返回数据的请求个数
}
@property (strong, nonatomic) ClassModelList *dataList,*tempdatalist,*currentList;
@property (strong, nonatomic) NSMutableArray *pCourseArray;
@property (strong, nonatomic) NSMutableArray *searchData;
@property (strong, nonatomic) CLLRefreshHeadController *refreshControll;
@end

@implementation AllCoursesViewController
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

- (BOOL)hasRefreshFooterView {
  
   return self.currentList.hasMore;
    
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
    if ([self.searchTextField.text isEqualToString:@""]) {
        [self _initTableDataKeyWord:@""];
    }else{
        CSLog(@"搜索相关课程:%@",self.searchTextField.text);
        NSString *searchStr = [self.searchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        CSLog(@"utf8___:%@",searchStr);

        [self _initTableDataKeyWord:searchStr];
    }
}

- (void)dealloc {

    self.tableView = nil;
    self.dataList = nil;
    self.pCourseArray = nil;
    self.searchData = nil;
    self.refreshControll = nil;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleView setTitleText:@"全部课程" withTitleStyle:CTitleStyle_LeftAndRight];
    [self.titleView setRightButonText:@"搜索"];
    isAllocData = YES;
    didLoadRequestCount = 0;
    self.tableView.frame = self.allContentView.bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    [self _initTableDataKeyWord:@""];
  
    [self _initRefrshController];
}

- (void)leftClicked:(TitleView *)view
{
    self.tableView.tableHeaderView = nil;
    self.searchTextField.text = @"";
    isAllocData = YES;
    didLoadRequestCount = 0;
    // 默认传入 空 @"" 字符串
    [http_ getPianogetCoursesByConditionwithKeyWord:@"" minPrice:0.0 maxPrice:10000000 startTime:@"" endTime:@"" page:1 rows:onePageCount jsonResPonseDelegate:self];
}

- (void)rightClicked:(TitleView *)view
{
    
    [self addSearchHeaderView];
    self.tableView.contentOffset = CGPointMake(0, 0);

}

- (void)_initTableDataKeyWord:(NSString *)keyWord
{

    [self resetHttp];
   
    int page = MAX(1,(int)self.dataList.list.count/onePageCount + 1);
    int rows = onePageCount;
    
    if (![self.searchTextField.text isEqualToString:@""]) {
        int page = MAX(1,(int)self.tempdatalist.list.count/onePageCount + 1);
        int rows = onePageCount;
        
        [http_ getPianogetCoursesByConditionwithKeyWord:keyWord minPrice:0 maxPrice:10000000 startTime:@"" endTime:@"" page:page rows:rows jsonResPonseDelegate:self];
        return;
    }
    // 默认传入 空 @"" 字符串
    [http_ getPianogetCoursesByConditionwithKeyWord:keyWord minPrice:0.0 maxPrice:10000000 startTime:@"" endTime:@"" page:page rows:rows jsonResPonseDelegate:self];

}

// 添加搜索view
- (void)addSearchHeaderView
{
    self.searchView.left = 0;
    self.searchView.top = 0;
    self.searchView.width = self.tableView.width;
    self.searchView.height = 50;
    self.searchBgImg.frame = self.searchView.bounds;

    self.searchTextField.left = self.searchView.left + 20;
    self.searchTextField.top = self.searchView.top + 10;
    self.searchTextField.width = self.searchView.width - (self.searchTextField.left + self.searchButton.width + 20 + 5);
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.keyboardType = UIKeyboardTypeDefault;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.delegate = self;
    self.searchButton.right = self.searchView.width -20;
    self.searchButton.top = self.searchTextField.top;

    if (!self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = self.searchView;
    }
    
}

// 取消按钮
- (IBAction)searchButtonAction:(UIButton *)sender {

    self.tableView.tableHeaderView = nil;
    self.searchTextField.text = @"";
}
// 键盘代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    CSLog(@"搜索相关课程:%@",self.searchTextField.text);
    NSString *searchStr = [self.searchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    CSLog(@"utf8___:%@",searchStr);
    isAllocData = YES;
    didLoadRequestCount = 0;
    [self _initTableDataKeyWord:searchStr];
    [textField resignFirstResponder];//关闭键盘
    return YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark-
#pragma mark - HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSString *urlString = [[request url]absoluteString];
    if ([urlString rangeOfString:@"getCoursesByCondition"].location != NSNotFound) {
        ClassModelList *tempList = [[ClassModelList alloc]initWithAllCouresJson:[request responseJSON]];
        if (tempList.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount++;
                if (tempList.list.count > 0) {
                    if ([self.searchTextField.text isEqualToString:@""]) {
                        self.dataList = tempList;
                        self.currentList = self.dataList;
                    }else{
                        self.tempdatalist = tempList;
                        self.currentList = self.tempdatalist;
                    }
                    
                }
            }
            else{
                if (!self.dataList) {
                    self.dataList = tempList;
                    self.currentList = self.dataList;
                }else {
                    [self.refreshControll endPullUpLoading];
                    if ([self.searchTextField.text isEqualToString:@""]){
                        [self.dataList addClassModelList:tempList];
                        self.currentList.list = [NSMutableArray arrayWithArray:self.dataList.list];
                    }else{
                        [self.tempdatalist addClassModelList:tempList];
                        self.currentList.list = [NSMutableArray arrayWithArray:self.tempdatalist.list];
                    }
                   
                    
                }
            }

        }
        else
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
        isAllocData = NO;
//        if (![self.searchTextField.text isEqualToString:@""]) {
//            self.currentList.list = [NSMutableArray arrayWithArray:self.tempdatalist.list];
//        }else{
//            self.currentList.list = [NSMutableArray arrayWithArray:self.dataList.list];
//        }
        [self.tableView reloadData];
        
    }else if (didLoadRequestCount == totalRequestCount) {
        //获取下一页数据之后 刷新UI
        [self hiddenHUD];
        [self.tableView reloadData];
    }

}
- (void)requestFailed:(ASIHTTPRequest *)request {
    didLoadRequestCount = 1;
    if (didLoadRequestCount == totalRequestCount) {
        //请求出错
        [self hiddenHUD];
        [Utils showToast:@"未知错误"];
    }
}



/**
 * 刷新单元格
 **/
- (void)reloadTableViewData
{
    if (self.currentList && self.currentList.list.count > 0) {
        self.tableView.tableFooterView = nil;
    }else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,self.allContentView.width, 20)];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = CSLocalizedString(@"myCalendar_VC_not_course");
        self.tableView.tableFooterView = label;
    }
    [self.tableView reloadData];
}


//==================================================
//UITableViewDelegate
//==================================================
#pragma mark - 
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    return self.currentList.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdn = @"AllCourseCell";
    AllCoursesCell *courseCell = [tableView dequeueReusableCellWithIdentifier:cellIdn];
    if (courseCell == nil) {
        UINib *nib = [UINib nibWithNibName:@"AllCoursesCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdn];
        courseCell = [tableView dequeueReusableCellWithIdentifier:cellIdn];
    }
    [courseCell setCourseCellContent:self.currentList.list[indexPath.row]];
//    [cell setContentData:[self.dataList.list objectAtIndex:indexPath.row]];
    return courseCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
   
    cellHeight = [[AllCoursesCell sharCourseCell]setCourseCellContent:self.currentList.list[indexPath.row]];
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (![UserAccount shareInstance].loginUser) {
//        CSLog(@"您未登录");
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您未登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
//        [alertView show];
//        return;
//        
//    }
    ClassModel *model  = [self.currentList.list objectAtIndex:indexPath.row];
    
//    LiveViewController *liveRoomVC = [[LiveViewController alloc] initWithRoomName:model.name coureid:model.cid classid:model.classid];
//    [self.navigationController pushViewController:liveRoomVC animated:YES];
    
//    CSLog(@"点击了课程");
//    CourseModel *coursemodel = [self.tableData objectAtIndex:indexPath.row];
    CourseDetailViewController *courseDVC = [[CourseDetailViewController alloc]initWithCourseid:model.cid];
    [self.tabbarVC.navigationController pushViewController:courseDVC animated:YES];

   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        CSLog(@"登录");
        [self showLoginVC];
    }
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
