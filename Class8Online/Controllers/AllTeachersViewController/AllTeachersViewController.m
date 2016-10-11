//
//  AllTeachersViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/6.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//


#import "AllTeachersViewController.h"
#import "CLLRefreshHeadController.h"
#import "UserCenterViewController.h"
#import "User.h"
#import "AllTeachersCell.h"
#import "PianoTeacherCell.h"
const int totalRequestCount = 1;                           //初始化数据需要的全部请求个数
const int onePageCount = 5;
@interface AllTeachersViewController ()<CLLRefreshHeadControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>
{
    
    BOOL isAllocData;               //是否初始化加载数据
    int didLoadRequestCount;        //已经成功返回数据的请求个数
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UserList *userlist,*tempdatalist,*currentList;
@property (strong, nonatomic) NSMutableArray *pCourseArray;
@property (strong, nonatomic) NSMutableArray *searchData;
@property (strong, nonatomic) CLLRefreshHeadController *refreshControll;
@end

@implementation AllTeachersViewController
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
        [self _initDatawithText:@""];
    }else{
        CSLog(@"搜索相关课程:%@",self.searchTextField.text);
        NSString *searchStr = [self.searchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        CSLog(@"utf8___:%@",searchStr);
        
        [self _initDatawithText:searchStr];
    }
}

- (void)dealloc
{
    self.tableView = nil;
    self.userlist = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleView setTitleText:@"全部教师" withTitleStyle:CTitleStyle_LeftAndRight];
    [self.titleView setRightButonText:@"搜索"];
    isAllocData = YES;
    didLoadRequestCount = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = self.allContentView.bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    
    [self _initRefrshController];
//    [self addSearchHeaderView];
    [self _initDatawithText:@""];
    // Do any additional setup after loading the view from its nib.
}

- (void)leftClicked:(TitleView *)view
{
    self.tableView.tableHeaderView = nil;
    self.searchTextField.text = @"";
    isAllocData = YES;
    didLoadRequestCount = 0;
    // 默认传入 空 @"" 字符串
    [http_ getPianogetTeachersByConditionwithTeacherName:@"" page:1 rows:onePageCount jsonResPonseDelegate:self];
}

- (void)rightClicked:(TitleView *)view
{

    [self addSearchHeaderView];
    self.tableView.contentOffset = CGPointMake(0, 0);

}

- (void) _initDatawithText:(NSString *)text{
    [self resetHttp];

    int page = MAX(1,(int)self.userlist.list.count/onePageCount + 1);
    int rows = onePageCount;
    
    if (![self.searchTextField.text isEqualToString:@""]) {
        int page = MAX(1,(int)self.tempdatalist.list.count/onePageCount + 1);
        int rows = onePageCount;
//        didLoadRequestCount = 0;

        [http_ getPianogetTeachersByConditionwithTeacherName:text page:page rows:rows jsonResPonseDelegate:self];
        return;
    }
    [http_ getPianogetTeachersByConditionwithTeacherName:text page:page rows:rows jsonResPonseDelegate:self];
    
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
/**
 * 刷新单元格
 **/
- (void)reloadTableViewData
{
    if (self.userlist && self.userlist.list.count > 0) {
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
    [self _initDatawithText:searchStr];
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
    if ([urlString rangeOfString:@"getTeachersByCondition"].location != NSNotFound) {
        UserList *tempList = [[UserList alloc]initWithSchoolAllTeachersUserList:[request responseJSON]];
        if (tempList.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount++;
                if (tempList.list.count > 0) {
                    if ([self.searchTextField.text isEqualToString:@""]) {
                        self.userlist = tempList;
                        self.currentList = self.userlist;
                    }else{
                        self.tempdatalist = tempList;
                        self.currentList = self.tempdatalist;
                    }
                    
                }
            }
            else{
                if (!self.userlist) {
                    self.userlist = tempList;
                    self.currentList = self.userlist;
                }else {
                    [self.refreshControll endPullUpLoading];
                    if ([self.searchTextField.text isEqualToString:@""]){
                        [self.userlist addUserList:tempList];
                        self.currentList.list = [NSMutableArray arrayWithArray:self.userlist.list];
                    }else{
                        [self.tempdatalist addUserList:tempList];
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




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentList.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *allIdntfier = @"alltea";
    AllTeachersCell *teaCell = [tableView dequeueReusableCellWithIdentifier:allIdntfier];
    if (!teaCell) {
        UINib *nib = [UINib nibWithNibName:@"AllTeachersCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:allIdntfier];
        teaCell = [tableView dequeueReusableCellWithIdentifier:allIdntfier];
    }
    
    [teaCell setALLTeaCellContent:self.currentList.list[indexPath.row]];
    return teaCell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    height = [[AllTeachersCell sharAllTeaCell] setALLTeaCellContent:self.currentList.list[indexPath.row]];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSLog(@"点击了老师%ld",(long)indexPath.row);
    User *usermodel = [self.currentList.list objectAtIndex:indexPath.row];
    UserCenterViewController *userVC = [[UserCenterViewController alloc]initWithUiD:usermodel.teaUid isTeacher:YES];
    [self.tabbarVC.navigationController pushViewController:userVC animated:YES];
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
