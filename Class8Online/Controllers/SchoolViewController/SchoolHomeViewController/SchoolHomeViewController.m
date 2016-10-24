//
//  SchoolHomeViewController.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/14.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "SchoolHomeViewController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "CLLRefreshHeadController.h"
#import "SchoolNoticesViewController.h"
#import "SchNoticeDetailViewController.h"
#import "CourseDetailViewController.h"
#import "UserCenterViewController.h"
#import "CourseModel.h"
#import "User.h"
#import "BannerScrollView.h"
#import "PianoCourseCell.h"
#import "PianoTeacherCell.h"

const CGFloat profileTableViewSectionViewHeight = 42.0f;   //虚拟单元格组视高度
const int totalRequestCount = 2;                           //初始化数据需要的全部请求个数
int totalRequesNum = 0;
@interface SchoolHomeViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,CLLRefreshHeadControllerDelegate,BannerScrollLocalDelegate,BannerScrollNetDelegate>
{
    UIView *tabeleViewSectionView;
    float headerHeight;   // 头视图高度
    float sectionTopY;    //组视图顶部
    float navHeight;      // 导航高度
    BOOL hasShowNav;      // 导航是否有颜色
    
    BOOL isAllocData;               //是否初始化加载数据
    int didLoadRequestCount;        //已经成功返回数据的请求个数
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CLLRefreshHeadController *refreshControll;
@property (strong, nonatomic) NSArray *netBanners;
@property (strong, nonatomic) NSArray *localBanners;

@property (strong, nonatomic) NSMutableArray *tableData;

@property (strong, nonatomic) CourseList *courselist;
@property (strong, nonatomic) UserList *userlist;
@property (assign, nonatomic) long long uid;
@property (assign, nonatomic) long long schoolID;

@end


@implementation SchoolHomeViewController

- (NSArray *)localBanners
{
    if (!_localBanners) {
        _localBanners = @[@"banner1",@"banner2",@"banner3",@"banner4"];
    }
    return _localBanners;
}
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
- (CLLRefreshViewLayerType)refreshViewLayerType
{
    return CLLRefreshViewLayerTypeOnSuperView;
}

- (BOOL)hasRefreshHeaderView
{
//    return self.courselist.hasMore;
    if (self.courselist.hasMore) {
        return YES;
    }
    if(self.userlist.hasMore){
        return YES;
    }
    return YES;
}

- (BOOL)hasRefreshFooterView {
 
    return NO;
}
/**
 *开始下拉刷新
 **/
- (void)beginPullDownRefreshing {
/**
 * 这里不使用下拉刷新头 此方法不实现
 **/

     [self _inittableData];
}

/***
 *开始上拉加载更多
 **/
- (void)beginPullUpLoading
{
    //
//    [self _inittableData];
}

- (void)dealloc
{
    self.tableView = nil;
    self.refreshControll = nil;

    self.netBanners = nil;
    self.localBanners = nil;
}



- (void)resetNavView
{
    self.navContentView.frame = CGRectMake(0, 0, self.allContentView.width, IS_IOS7?64:44);
    UIImage *navImage = [UIImage imageNamed:@"nav顶"];
    navImage = [navImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.navBjImg.image = navImage;
    self.navBjImg.frame = self.navContentView.bounds;
    
    self.navBjImg.alpha = 0.0;
    self.navTitleL.frame = CGRectMake(0, IS_IOS7?20:0, self.allContentView.width, self.navContentView.height - (IS_IOS7?20:0));
    self.navTitleL.alpha = 0.0;
    navHeight = self.navContentView.height;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initRefrshController];

//    [self.refreshControll startPullDownRefreshing];
    [self _inittableData];
    [self createLocalScrollView];
    self.tableData = [NSMutableArray array];
    [self resetNavView];
    self.navTitleL.text = @"课吧";
    self.allContentView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    self.tableView.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.height - 49);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    

 

}



- (void)beginLoadData
{
    self.uid = [UserAccount shareInstance].loginUser.uid;
    [self _inittableData];
    
}

- (void)_inittableData
{
    
    isAllocData = YES;
    didLoadRequestCount = 0;
    [self resetHttp];
    [http_ getPianoNewRecommendTea_jsonResPonseDelegate:self];
    [http_ getPianoRecommendCourse_jsonResPonseDelegate:self];

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // 推荐课程
    NSString *urlString = [[request url]absoluteString];
    if ([urlString rangeOfString:@"getRecommendCourses"].location != NSNotFound) {
        CourseList *tempList = [[CourseList alloc]initWithSchoolHomeCourseJSON:[request responseJSON]];
        if (tempList.code_ == 0) {
//            isAllocData = YES;
            if (isAllocData) {
                didLoadRequestCount ++;
                if (tempList.list.count > 0) {
                    self.courselist = tempList;
                }
                [self.refreshControll endPullDownRefreshing];

            }

        }
    }
    // 推荐老师
    else if ([urlString rangeOfString:@"getNewRecommendTeachers"].location != NSNotFound){
        UserList *tempList = [[UserList alloc]initWithSchoolUserList:[request responseJSON]];
        if (tempList.code_ == 0) {
            
            if (isAllocData) {
                didLoadRequestCount ++;
                if (tempList.list.count > 0) {
                    self.userlist = tempList;
                }
                [self.refreshControll endPullDownRefreshing];

            }

            
            
        }
        
    }
    
    //
    
    if(isAllocData && didLoadRequestCount == totalRequestCount){
        // 初始化刷新数据成功
        [self hiddenHUD];
        isAllocData = NO;
        self.tableData = [NSMutableArray arrayWithArray:self.courselist.list];
        if (self.userlist.list > 0) {
            [self.tableData addObjectsFromArray:self.userlist.list];
        }
        
        [self.refreshControll endPullDownRefreshing];
        [self.tableView reloadData];
        

    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    didLoadRequestCount = 2;
    if (didLoadRequestCount == totalRequestCount) {
        //请求出错
        [self hiddenHUD];
        [Utils showToast:@"未知错误"];
    }
}


/**
 * 创建本地banner
 *
 **/
-(void)createLocalScrollView
{

    
    BannerScrollView *LocalScrollView = [[BannerScrollView alloc]initWithFrame:CGRectMake(0, 0, self.allContentView.width, self.allContentView.width /3 * 1.5) WithLocalImages:self.localBanners];
    
    /** 设置滚动延时*/
    LocalScrollView.AutoScrollDelay = 2;
    
    /** 获取本地图片的index*/
    LocalScrollView.localDelagate = self;
    
    /** 添加到当前View上*/
    if (!self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = LocalScrollView;

    }
}

/** 获取本地图片的index*/
-(void)didSelectedLocalImageAtIndex:(NSInteger)index
{
    NSLog(@"点中本地图片的下标是:%ld",(long)index);
}


#pragma mark ____
#pragma mark ____UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableData.count > 0) {
        return self.tableData.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   UITableViewCell *cell ;
    static NSString *pCourseIdentifier = @"pCourseCell";
    static NSString *PTeaIndentifier = @"pTeaCell";
    if (indexPath.row < self.courselist.list.count) {
        PianoCourseCell *courseCell = [tableView dequeueReusableCellWithIdentifier:pCourseIdentifier];
        if (!courseCell) {
            UINib *nib = [UINib nibWithNibName:@"PianoCourseCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:pCourseIdentifier];
            courseCell = [tableView dequeueReusableCellWithIdentifier:pCourseIdentifier];
        }
        
        if (indexPath.row == 0) {
            [courseCell setCourseCellContent:self.tableData[indexPath.row] sectionHidden:YES];
        }else if(indexPath.row > 0 && indexPath.row < self.courselist.list.count){
            [courseCell setCourseCellContent:self.tableData[indexPath.row] sectionHidden:NO];
        }
        return courseCell;
    }else if(self.userlist.list){
        PianoTeacherCell *teaCell = [tableView dequeueReusableCellWithIdentifier:PTeaIndentifier];
        if (!teaCell) {
            UINib *nib = [UINib nibWithNibName:@"PianoTeacherCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:PTeaIndentifier];
            teaCell = [tableView dequeueReusableCellWithIdentifier:PTeaIndentifier];
        }
//        teaCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == self.self.courselist.list.count) {
            [teaCell setTeaCellContent:self.tableData[indexPath.row] sectionView:YES];
        }else if(indexPath.row > self.self.courselist.list.count){
            [teaCell setTeaCellContent:self.tableData[indexPath.row] sectionView:NO];
        }
//        CSLog(@"%@ %d",self.tableData[indexPath.row],indexPath.row);
        return teaCell;
    }
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 100;
    if (indexPath.row < self.courselist.list.count) {
        if (indexPath.row == 0) {
            cellHeight = [[PianoCourseCell sharCourseCell]setCourseCellContent:self.tableData[indexPath.row] sectionHidden:YES];
        }else{
            cellHeight = [[PianoCourseCell sharCourseCell]setCourseCellContent:self.tableData[indexPath.row] sectionHidden:NO];
        }
    }
    else if(self.userlist.list){
        if (indexPath.row == self.courselist.list.count) {
            cellHeight = [[PianoTeacherCell sharTeacell]setTeaCellContent:self.tableData[indexPath.row] sectionView:YES];
        }else{
            cellHeight = [[PianoTeacherCell sharTeacell]setTeaCellContent:self.tableData[indexPath.row] sectionView:NO];
        }
        
    }

    return cellHeight;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.courselist.list.count) {
        //所有课程
        CSLog(@"点击了课程");
        CourseModel *coursemodel = [self.tableData objectAtIndex:indexPath.row];
        CourseDetailViewController *courseDVC = [[CourseDetailViewController alloc]initWithCourseid:coursemodel.courseID];
        [self.tabbarVC.navigationController pushViewController:courseDVC animated:YES];
    }
    else{
        //所有老师
        CSLog(@"点击了老师");
        User *usermodel = [self.tableData objectAtIndex:indexPath.row];
        UserCenterViewController *userVC = [[UserCenterViewController alloc]initWithUiD:usermodel.uid isTeacher:YES];
        [self.tabbarVC.navigationController pushViewController:userVC animated:YES];
    }
    
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset   = self.tableView.contentOffset.y;
    
    
    if (yOffset > self.navContentView.top) {
        if (!hasShowNav) {
            [self hasShowNavContentView:YES];
        }
    }else {
        //隐藏背景
        if (hasShowNav) {
            [self hasShowNavContentView:NO];
        }
    }
}


- (void)hasShowNavContentView:(BOOL)show
{
    if (show) {
        //显示导航背景
        [UIView animateWithDuration:0.35 animations:^{
            self.navBjImg.alpha = 1;
            self.navTitleL.alpha = 1;
        }];
        hasShowNav = YES;
        //        self.navPraiseButton.enabled = NO;
        //        [self.leftBtn setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
        //        if (IS_IOS7) {
        //            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        //            [self setNeedsStatusBarAppearanceUpdate];
        //        }
        
    }else {
        //隐藏导航背景
        [UIView animateWithDuration:0.35 animations:^{
            self.navBjImg.alpha = 0;
            self.navTitleL.alpha = 0;
        }completion:^(BOOL finished) {
        }];
        hasShowNav = NO;
        //        self.navPraiseButton.enabled = YES;
        //        [self.leftBtn setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
        //        if (IS_IOS7) {
        //            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        //            [self setNeedsStatusBarAppearanceUpdate];
        //        }
    }

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated    
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
