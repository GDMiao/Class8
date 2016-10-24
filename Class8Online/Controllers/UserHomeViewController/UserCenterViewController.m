//
//  UserCenterViewController.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/14.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "UserCenterViewController.h"
#import "UIImageView+WebCache.h"
#import "HMSegmentedControl.h"
#import "UserCenterCell.h"
#import "CourseModel.h"
#import "CLLRefreshHeadController.h"
#import "CourseDetailViewController.h"
typedef enum{
   
    CellStyle_user_Create = 0,     //用户创建
    CellStyle_user_Order,          //用户订购
    CellStyle_tea_home             //Teahome
    
}CellStyle;
const CGFloat profileTableViewSectionViewHeight = 42.0f;    //虚拟单元格组视高度
const int totalRequestCount = 2;                            //初始化数据需要的全部请求个数
const int onePageCount = 5;                                 //每页数据个数
@interface UserCenterViewController ()<UITableViewDataSource,UITableViewDelegate,CLLRefreshHeadControllerDelegate,UserCenterCellDelegate>
{
    UIView *tabeleViewSectionView;
    
    float headerHeight;             //头视图的高度
    float sectionTopY;              //组视图顶部
    float navHeight;                //导航高度
    BOOL hasShowNav;                //导航是否有颜色 默认NO
    
    BOOL isAllocData;               //是否初始化加载数据
    int didLoadRequestCount;        //已经成功返回数据的请求个数
}
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) long long uid;
@property (assign, nonatomic) CellStyle cstyle;
@property (strong, nonatomic) CourseList *leftListModel,*rightListModel,*currentListModel;
@property (nonatomic, strong) CLLRefreshHeadController *refreshControll;
@property (strong, nonatomic) HMSegmentedControl *segmentedControl;
@property (assign, nonatomic) BOOL isTeacher;
@end

@implementation UserCenterViewController

- (id)initMyOrderResult:(User *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.uid = user.uid;
        self.user = user;
        self.cstyle = CellStyle_user_Order;
        
        
    }
    return self;
}

- (id)initWithUser:(User *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.uid = user.uid;
        self.user = user;
//        if (self.user.authority == UserAuthorityType_TEACHER) {
//            self.isTeacher = YES;
//            self.cstyle = CellStyle_tea_Home;
            self.cstyle = CellStyle_user_Create;
//        }
//            else {
//            self.cstyle = CellStyle_stu_Studing;
//            self.isTeacher = NO;
//        }
    }
    return self;
}
- (id)initWithUiD:(long long)uid isTeacher:(BOOL)isTea
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.user = nil;
        self.uid = uid;
        self.isTeacher = isTea;
    }
    return self;
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

- (BOOL)hasRefreshHeaderView
{
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
    [self loadCourseData];
}

/**
 *是显示加载更多 默认 NO
 **/
- (BOOL)hasRefreshFooterView {
//    if (self.cstyle == CellStyle_tea_home) {
//        CSLog(@"%@",self.leftListModel.hasMore);
//        return self.currentListModel.hasMore;
//        
//    }else {
//        return self.currentListModel.hasMore;
//    }
//    return NO;
    return self.currentListModel.hasMore;
    
}

- (void)dealloc
{
    self.headerView = nil;
    self.headerDefaultImg = nil;
    self.userAvatar = nil;
    self.userSexImg = nil;
    self.realNameLabel = nil;
    self.nickLabel = nil;
    self.teaRzIcon = nil;
    self.organizationLabel = nil;
    self.chatButton = nil;
    self.teaHearderView = nil;
    self.tableView = nil;
    self.courseCountLabel = nil;
    self.line1 = nil;

    self.pfCountLabel = nil;
    self.navContentView = nil;
    self.leftBtn = nil;
    self.navBjImg = nil;
    self.navTitleLabel = nil;
    
    self.user = nil;
    self.segmentedControl = nil;
    tabeleViewSectionView = nil;
    
    self.leftListModel = nil;
    self.rightListModel = nil;
    self.currentListModel = nil;
    self.refreshControll = nil;

}

- (void)resetNavView
{
    self.navContentView.frame = CGRectMake(0, 0, self.allContentView.width, IS_IOS7?64:44);
    
    UIImage *navImg = [UIImage imageNamed:@"nav顶"];
    navImg = [navImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.navBjImg.image = navImg;
    self.navBjImg.frame = self.navContentView.bounds;

    self.leftBtn.frame = CGRectMake(0,IS_IOS7?20 + ((self.navContentView.height - 20) - 44) * 0.5:(self.navContentView.hidden- 44) * 0.5, 44, 44);
    self.navBjImg.alpha = 0.0;
    [self.leftBtn setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
    navHeight = self.navContentView.height;
    self.navTitleLabel.frame = CGRectMake(self.leftBtn.right+5, (IS_IOS7?20:0), SCREENWIDTH-self.leftBtn.right*2-10, self.navContentView.height-(IS_IOS7?20:0));
    self.navTitleLabel.alpha = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allContentView.backgroundColor = [UIColor whiteColor];
//    self.cstyle = CellStyle_user_Create;
    [self _initData];
    [self resetNavView];
    self.tableView.frame = self.allContentView.bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    self.tableView.hidden = YES;
    [self _initRefrshController];

}
- (void)_initData
{
    isAllocData = YES;
    [self showHUD:nil];
    [self resetHttp];
    
    if ([Utils objectIsNull:self.user]) {
        didLoadRequestCount = 0;
        if(_isTeacher){
            
        }
        //用户信息
        int userType = self.isTeacher?40:30;
        [http_ getUserInfo:self.uid userType:userType jsonResponseDelegate:self];
//        [self loadCourseData];
    }else {
        self.navTitleLabel.text = self.user.realname;
        didLoadRequestCount = 1;
        [self loadCourseData];
    }
//    [self showHUD:nil];
}

/**
 *加载更多课程数据
 * page 页码，分页是第几页，从1开始。没有0页
 **/
- (void)loadCourseData
{
    [self resetHttp];
    switch (self.cstyle) {
        case CellStyle_tea_home:
        {
            //教师首页

            int page = MAX(1,(int)self.leftListModel.list.count/onePageCount + 1);
            int rows = onePageCount;
            [http_ getTeaLastCourse:self.uid pageNum:page rows:rows jsonResponseDelegate:self];
            
        }
            break;
            
        case CellStyle_user_Order:
        {
            //  我的订购
           
            int page = MAX(1,(int)self.leftListModel.list.count/onePageCount + 1);
            int rows = onePageCount;
            [http_ getPianoMyOrderedCoursesWith:self.uid Status:0 page:page rows:rows jsonResPonseDelegate:self];
        }
            break;
        case CellStyle_user_Create:
        {
            // 我的创建
            
            int page = MAX(1,(int)self.rightListModel.list.count/onePageCount + 1);
            int rows = onePageCount;
            [http_ getPianoMyCreatedCoursesWith:[UserAccount shareInstance].uid Status:0 page:page rows:rows jsonResPonseDelegate:self];
        }
            break;
        default:
            break;
    }
}

#pragma mark- 
#pragma mark- HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"mlistpersonaldata"].location != NSNotFound) {
        //获取用户信息
        User *tmpUser = [[User alloc] initLoginUserInfoWithJSON:[request responseJSON]];
        if (tmpUser.code_ == 0) {
            didLoadRequestCount ++;
            self.user = tmpUser;
            self.navTitleLabel.text = self.user.realname;
            if (self.isTeacher) {
                self.cstyle = CellStyle_tea_home;
            }
            else {
                self.cstyle = CellStyle_user_Order;
            }
            [self loadCourseData];
        }else {
            if (isAllocData) {
                [self hiddenHUD];
            }
            [Utils showAlert:[NSString stringWithFormat:@"服务器返回：%d",tmpUser.code_]];
//            [Utils showToast:@"未知错误"];
        }
    }else if ([urlString rangeOfString:@"getMyOrderedCourses"].location != NSNotFound) {
        //返回已订购课程
        CourseList *tmpCourselist= [[CourseList alloc] initWithSchoolHomeCourseJSON:[request responseJSON]];
        if (tmpCourselist.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount ++;
                if (tmpCourselist.list.count > 0) {
                    self.leftListModel = tmpCourselist;
                    self.currentListModel = self.leftListModel;
                }
                
            }else{
                if (!self.leftListModel){
                    self.leftListModel = tmpCourselist;
                    self.currentListModel = self.leftListModel;
                }else {
                    [self.refreshControll endPullUpLoading];
                    [self.leftListModel addCourseList:tmpCourselist];
                    self.currentListModel.list = [NSMutableArray arrayWithArray:self.leftListModel.list];
                }

            }
        }else {
            if (isAllocData) {
                [self hiddenHUD];
            }
            [Utils showAlert:[NSString stringWithFormat:@"服务器返回：%d",tmpCourselist.code_]];
//            [Utils showToast:@"未知错误"];
        }
    }else if ([urlString rangeOfString:@"getMyCreatedCourses"].location != NSNotFound){
        //返回已创建课程
        CourseList *tmpCourselist= [[CourseList alloc] initWithSchoolHomeCourseJSON:[request responseJSON]];
        if (tmpCourselist.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount ++;
                if (tmpCourselist.list.count > 0) {
                    self.rightListModel = tmpCourselist;
                    self.currentListModel = self.rightListModel;
                }
                
            }else{
                if (!self.rightListModel){
                    self.rightListModel = tmpCourselist;
                    self.currentListModel = self.rightListModel;
                }else {
                    [self.refreshControll endPullUpLoading];
                    [self.rightListModel addCourseList:tmpCourselist];
                    self.currentListModel.list = [NSMutableArray arrayWithArray:self.rightListModel.list];
                }
                
            }
        }else {
            if (isAllocData) {
                [self hiddenHUD];
            }
            [Utils showToast:@"未知错误"];
        }
    }
    else if ([urlString rangeOfString:@"getLastestCourses"].location != NSNotFound) {
        //返回教师的 最新课程+热门课程
        CourseList *tmpCourselist= [[CourseList alloc] initWithTeacherHomeCourseJSON:[request responseJSON]];
        if (tmpCourselist.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount ++;
                if (tmpCourselist.list.count > 0) {
                    self.leftListModel = tmpCourselist;
                    self.currentListModel = self.leftListModel;
                }
                
            }else{
                if (!self.leftListModel){
                    self.leftListModel = tmpCourselist;
                    self.currentListModel = self.leftListModel;
                }else {
                    [self.refreshControll endPullUpLoading];
                    [self.leftListModel addCourseList:tmpCourselist];
                    self.currentListModel.list = [NSMutableArray arrayWithArray:self.leftListModel.list];
                }
                
            }
        }else {
            if (isAllocData) {
                [self hiddenHUD];
            }
            [Utils showToast:@"未知错误"];
        }
    }
    
    if (isAllocData && didLoadRequestCount == totalRequestCount) {
        //初始化数据成功 刷新UI
        self.tableView.hidden = NO;
        [self hiddenHUD];
        isAllocData = NO;
//        [self getCellNumberFromeData];
        [self refreshHearderView];
        [self.tableView reloadData];
    }else if (didLoadRequestCount == totalRequestCount) {
        //获取下一页数据之后 刷新UI
        [self.tableView reloadData];
    }else if (isAllocData){
        
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


- (void)refreshHearderView
{
    UIImage *defaultImg = nil;

    if (self.isTeacher) {
        defaultImg = [UIImage imageNamed:@"lsbj"];
    }else {
        defaultImg = [UIImage imageNamed:@"wbj"];
    }
    
    
    self.headerDefaultImg.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.width/2.0915); //2.0915 为本地素材宽高比
    self.headerView.frame = self.headerDefaultImg.bounds;
    
    self.headerDefaultImg.image = defaultImg;
    
    self.userAvatar.layer.cornerRadius = self.userAvatar.width*0.5;
    self.userAvatar.layer.masksToBounds = YES;
    NSString *avatartUrl = self.user.avatar;
    if ([avatartUrl rangeOfString:@"http://"].location == NSNotFound) {
        avatartUrl = [NSString stringWithFormat:@"%@%@",UserAvatarBasicUrl,avatartUrl];
    }
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:avatartUrl] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    self.userAvatar.top = 40;
    self.userAvatar.left = 28;

    
    //真实名字
    self.realNameLabel.text = self.user.realname;
    [self.realNameLabel sizeToFit];
    self.realNameLabel.top = self.userAvatar.top + 8;
    self.realNameLabel.left = self.userAvatar.right + 15;
    
    //昵称
    self.nickLabel.text = [NSString stringWithFormat:@"(%@)",self.user.nickName];
    [self.nickLabel sizeToFit];
    self.nickLabel.left = self.realNameLabel.right + 10;
    self.nickLabel.top = self.realNameLabel.top;
    
    //教师认证icon
//    self.teaRzIcon.hidden = !self.isTeacher;
    self.teaRzIcon.left = self.realNameLabel.left;
    self.teaRzIcon.top = self.realNameLabel.bottom + 7;
    
    //学校名
    NSString *organizationLabel = [Utils objectIsNotNull:self.user.schoolName]?self.user.schoolName:self.user.company;
    
    self.organizationLabel.text = organizationLabel.length > 0 ? organizationLabel :@"未加入机构";
    [self.organizationLabel sizeToFit];
    self.organizationLabel.top = self.teaRzIcon.bottom + 5;
    self.organizationLabel.left = self.teaRzIcon.left;

    //聊天按钮<非登录用户>
//    self.chatButton.hidden = self.user.uid == [UserAccount shareInstance].loginUser.uid;
    self.chatButton.top = 34;
    self.chatButton.right = self.headerView.width - 14;


    self.teaHearderView.hidden = NO;
    // teaHeaderView
    [self upteaInfo];
    self.headerView.frame = CGRectMake(0, 0, self.headerDefaultImg.width, self.headerDefaultImg.height+profileTableViewSectionViewHeight);
    
    if (!self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView =self.headerView;
    }
    headerHeight = self.headerView.height;                                    //头视图的高度
    sectionTopY = self.headerView.bottom - profileTableViewSectionViewHeight; //组视图顶部

    //添加虚拟单元格组视图
    [self addTableViewCustomSectionWithFrame:CGRectMake(0, sectionTopY, self.allContentView.width, profileTableViewSectionViewHeight)];

}
- (void)upteaInfo
{
    self.teaHearderView.frame = CGRectMake(0, self.userAvatar.bottom + 23, self.headerView.width, 30);
//    self.teaHearderView.backgroundColor = [UIColor orangeColor];
    
    CGFloat oneWidth = (self.teaHearderView.width - self.line1.width ) / 3.0;
    
    self.courseCountLabel.text = [NSString stringWithFormat:@"课程: %d",self.user.courseCount];
    [self.courseCountLabel sizeToFit];
    self.courseCountLabel.left = (oneWidth - self.courseCountLabel.width) * 0.5;
    self.courseCountLabel.top = 0;
    
    
    self.line1.left = oneWidth;
    self.line1.top = 0;
    self.line1.height = self.courseCountLabel.height;
    
    self.pfLabel.left = self.line1.right + 10;
    self.pfLabel.top = self.courseCountLabel.top;
    
    CGFloat teaScore = 5.0; //教师评分 暂时写死 <服务器未记录此属性>
    self.starsview.frame = CGRectMake(self.pfLabel.right + 5, self.pfLabel.top +5, 80, 12);
    [self.starsview updateContent:teaScore];


    self.pfCountLabel.text = [NSString stringWithFormat:@"%0.1f",self.user.pfCount];
    [self.pfCountLabel sizeToFit];
    self.pfCountLabel.left = self.starsview.right + 10;
    self.pfCountLabel.top = self.pfLabel.top;
    self.teaHearderView.height = self.courseCountLabel.height;
}


- (void)addTableViewCustomSectionWithFrame:(CGRect)frame
{
    if (!tabeleViewSectionView) {
        tabeleViewSectionView = [[UIView alloc] initWithFrame:frame];
        NSArray *items = nil;
        if (self.isTeacher) {
            items = [[NSArray alloc] initWithObjects:@"ta的创建", nil];
        }else{
            items = [[NSArray alloc] initWithObjects:@"我的订购",@"我的创建", nil];
        }
        UIImage *segBjImg = [UIImage imageNamed:@"讨论底"];
        segBjImg = [segBjImg resizableImageWithCapInsets:UIEdgeInsetsMake(4, 1, 4, 1)];

        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:items];
//        segmentedControl.selectionIndicatorCustomWidth = 66;
        self.segmentedControl.backgroundImage = segBjImg;
        [self.segmentedControl setFrame:CGRectMake(0, 0, tabeleViewSectionView.width, tabeleViewSectionView.height)];
        self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        [self.segmentedControl setTextColor:MakeColor(0x28, 0x28, 0x28)];
        self.segmentedControl.textFont =[UIFont systemFontOfSize:15];
        [self.segmentedControl setSelectionIndicatorColor:MakeColor(0x4e, 0xb8, 0x32)];
        [self.segmentedControl setSelectionIndicatorHeight:3];
        self.segmentedControl.selectedTextColor = MakeColor(0x4e, 0xb8, 0x33);
        if (self.isTeacher) {
            [self.segmentedControl setSelectedSegmentIndex:0]; //默认
        }else{
            if(self.cstyle == CellStyle_user_Order){
                [self.segmentedControl setSelectedSegmentIndex:0]; //默认
            }else{
            [self.segmentedControl setSelectedSegmentIndex:1]; //默认
            }
        }
        
        [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        [tabeleViewSectionView addSubview:self.segmentedControl];
        [self.tableView addSubview:tabeleViewSectionView];
    }
    tabeleViewSectionView.hidden = NO;
    tabeleViewSectionView.frame = frame;
}
         
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    CSLog(@"选择: %ld", (long)segmentedControl.selectedSegmentIndex);
    BOOL didLoadData = NO;
    if (self.isTeacher) {
        //教师
        switch (segmentedControl.selectedSegmentIndex) {
            case 0:
            {
                //教师主页
                CSLog(@"教师主页");
                self.cstyle = CellStyle_tea_home;
                didLoadData = self.leftListModel==nil;
            }
                break;
                
            default:
                break;
        }
    }else{
        //教师
        switch (segmentedControl.selectedSegmentIndex) {
            case 0:
            {
                //教师主页
                CSLog(@"我的订购");
                self.cstyle = CellStyle_user_Order;
                didLoadData = self.leftListModel==nil;
            }
                break;
            case 1:
            {
                //教师课程
                CSLog(@"我的创建");
                self.cstyle = CellStyle_user_Create;
                didLoadData = self.rightListModel==nil;
            }
                break;
                
            default:
                break;
        }
    }
    if (didLoadData) {
        isAllocData = YES;
        didLoadRequestCount = 1;
        [self showHUD:nil];
        [self loadCourseData];
    }else {
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chatAction:(UIButton *)sender {
}

- (IBAction)leftBtnAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hasShowNavContentView:(BOOL)show
{
    if (show) {
        //显示导航背景
        [UIView animateWithDuration:0.25 animations:^{
            self.navBjImg.alpha = 1;
            self.navTitleLabel.alpha = 1;
        }];
        hasShowNav = YES;
//        self.navPraiseButton.enabled = NO;
        [self.leftBtn setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
//        if (IS_IOS7) {
//            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
//            [self setNeedsStatusBarAppearanceUpdate];
//        }
        
    }else {
        //隐藏导航背景
        [UIView animateWithDuration:0.25 animations:^{
            self.navBjImg.alpha = 0;
            self.navTitleLabel.alpha = 0;
        }completion:^(BOOL finished) {
        }];
        hasShowNav = NO;
//        self.navPraiseButton.enabled = YES;
        [self.leftBtn setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
//        if (IS_IOS7) {
//            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//            [self setNeedsStatusBarAppearanceUpdate];
//        }
    }

}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset   = self.tableView.contentOffset.y;
    
    if (yOffset < 0) {
        CGRect f = CGRectMake(0, yOffset, self.allContentView.width, self.headerView.height-profileTableViewSectionViewHeight+ABS(yOffset));
        self.headerDefaultImg.frame = f;
        self.headerDefaultImg.frame = f;
    }
    
    //移动组视图
    if (yOffset > sectionTopY-navHeight) {
        if (yOffset > sectionTopY - navHeight) {
            tabeleViewSectionView.top = yOffset + navHeight;
        }else if (yOffset < sectionTopY - navHeight){
            tabeleViewSectionView.frame = CGRectMake(0, sectionTopY, self.allContentView.width, profileTableViewSectionViewHeight);
        }
//        float newNavTop = yOffset - (headerHeight - profileTableViewSectionViewHeight - navHeight);
//        self.navContentView.top = navTopY -newNavTop;
    }else if (yOffset <= headerHeight){
        tabeleViewSectionView.top = sectionTopY;
//        self.navContentView.top = navTopY;
    }
    
    if (yOffset > self.userAvatar.top) {
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


- (NSUInteger)getCellNumberFromeData
{
    if (self.cstyle == CellStyle_user_Order) {
        self.currentListModel = self.leftListModel;
    }else if(self.cstyle == CellStyle_user_Create){
        self.currentListModel = self.rightListModel;
    }else if(self.cstyle == CellStyle_tea_home){
        self.currentListModel = self.leftListModel;
    }
    if (self.currentListModel && self.currentListModel.list && self.user) {
        if (CellStyle_user_Order == self.cstyle) {
            return MAX(self.currentListModel.list.count, 1);
        }else{
            return self.currentListModel.list.count;
        }
    }
    return 0;
}

#pragma mark-
#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getCellNumberFromeData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idtifier = @"userCenter-cell";
    UserCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"UserCenterCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:idtifier];
        cell = [tableView dequeueReusableCellWithIdentifier:idtifier];
    }
//    cell.cellDelegate = self;
    [self updateCellContent:indexPath withCell:cell];
//    cell setCreatCourseCell:[NSString stringWithFormat:@"我的创建%ld",indexPath.row];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserCenterCell *cell = [UserCenterCell shareCourseCell];
    return [self updateCellContent:indexPath withCell:cell];
}

- (CGFloat)updateCellContent:(NSIndexPath *)idx withCell:(UserCenterCell *)cell
{
    CGFloat cellHeight = 0;
    CourseModel *cmodel = nil;
    NSString *cellStyleTxt = nil;
    User *u = nil;
    if (idx.row == 0 && CellStyle_user_Order == self.cstyle) {
        u = self.user;
    }
    if (self.currentListModel.list.count > 0) {
        cmodel = [self.currentListModel.list objectAtIndex:idx.row];
    }else {
        cmodel = nil;
    }
    if (CellStyle_user_Order == self.cstyle) {
//        if (self.currentListModel.orderCourseCount > 0 && idx.row == 0) {
//            cellStyleTxt = @"我的订购";
//        }else if (self.currentListModel.teaHotCourseCount > 0 && idx.row==self.currentListModel.teaLastCourseCoun)
//        {
//            cellStyleTxt = @"我的创建";
//        }
        cellStyleTxt = @"我的订购";
    }else if (CellStyle_user_Create == self.cstyle){
        cellStyleTxt = @"我的创建";
    }else if (CellStyle_tea_home == self.cstyle){
        cellStyleTxt = @"教师首页";
    }
    cellHeight = [cell setCellContent:cmodel withCellStyleTxt:cellStyleTxt userinfoModel:u];
    return cellHeight;
}

#pragma mark- 
#pragma mark - UserCenterCellDelegate
- (void)userCenterCellMoreCourse
{
    BOOL didLoadData = NO;
    [self.segmentedControl setSelectedSegmentIndex:1 animated:YES];
    if (CellStyle_user_Order == self.cstyle) {
        self.cstyle = CellStyle_user_Create;
        didLoadData = self.rightListModel==nil;
    }
//    else if (CellStyle_stu_Studing == self.cstyle) {
//        self.cstyle = CellStyle_stu_Done;
//        didLoadData = self.rightListModel==nil;
//    }
    
    if (didLoadData) {
        isAllocData = YES;
        didLoadRequestCount = 1;
        [self showHUD:nil];
        [self loadCourseData];
    }else {
        [self.tableView reloadData];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    CourseModel *cmodel = nil;
    if (self.currentListModel.list.count > 0) {
        cmodel = [self.currentListModel.list objectAtIndex:indexPath.row];
    }else {
        cmodel = nil;
        return;
    }
    CourseDetailViewController *courseVC = [[CourseDetailViewController alloc] initWithCourseid:cmodel.courseID];
    [self.navigationController pushViewController:courseVC animated:YES];

}
@end
