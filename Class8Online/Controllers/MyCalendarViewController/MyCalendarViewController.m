//
//  MyCalendarViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "MyCalendarViewController.h"
#import "ClassModel.h"
#import "MyCalendarClassCell.h"
#import "LiveViewController.h"
#import "TeaLiveViewController.h"
#import "TimePickerView.h"

@interface MyCalendarViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) ClassModelList *dataList;

@end

@implementation MyCalendarViewController

- (void)dealloc {
    self.calendar = nil;
    self.dataList = nil;
    self.tableView = nil;
    self.timeView = nil;
    self.myPickerView = nil;
    self.timeLable = nil;
    self.iconImg = nil;
    [self.myPickerView removeFromSuperview];
    self.myPickerView = nil;
    self.calendarMenuView = nil;
    self.calendarContentView = nil;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleView setTitleText:@"" withTitleStyle:CTitleStyle_Home];

    self.calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, -10, self.allContentView.width, 10)];
    self.calendarContentView = [[JTCalendarContentView alloc] initWithFrame:CGRectMake(0, 0, self.allContentView.width, 38*6 + 23)];
    [self.allContentView addSubview:self.calendarContentView];
    
    self.calendar = [[JTCalendar alloc] init];
    self.calendar.calendarAppearance.calendar.firstWeekday = 1; // Sunday == 1, Saturday == 7
    self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
    self.calendar.calendarAppearance.ratioContentMenu = 1.;
    self.calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
    self.calendar.calendarAppearance.readFromRightToLeft = NO;
    self.calendar.calendarAppearance.menuMonthViewHeight = 23;
    self.calendar.calendarAppearance.menuMonthTextColor = [UIColor whiteColor];                                                         /*年份*/
    self.calendar.calendarAppearance.dayTextColor = MakeColor(0x28, 0x28, 0x28);                                          /*当月天*/
    self.calendar.calendarAppearance.dayTextFont = [UIFont systemFontOfSize:13.0];
    self.calendar.calendarAppearance.dayTextColorOtherMonth = MakeColor(0x99, 0x99, 0x99);                               /*非当月天*/
    self.calendar.calendarAppearance.dayCircleColorSelected = [UIColor colorWithRed:66/255.0 green:185/255.0 blue:40/255.0 alpha:1.0]; /*天选中背景颜色*/
    self.calendar.calendarAppearance.dayCircleColorToday = MakeColor(0xf2, 0x82, 0xb2);   /*当天在本月中背景颜色*/
    self.calendar.calendarAppearance.dayCircleColorTodayOtherMonth = [UIColor colorWithRed:250/255.0 green:70/255.0 blue:100/255.0 alpha:1.0];/*当天在上月中背景颜色*/
    self.calendar.calendarAppearance.weekDayTextColor = MakeColor(0x99, 0x99, 0x99);                                      /*周颜色*/
    self.calendar.calendarAppearance.weekDayTextFont = [UIFont systemFontOfSize:13.0];// 周字体字号

    self.calendar.calendarAppearance.autoChangeMonth = YES;                                                              /*选择非当月天是否自动进入选中月*/
    self.calendar.calendarAppearance.weekDayFormat = JTCalendarWeekDayFormatSingle;
    self.calendar.calendarAppearance.dayCircleColorSelectedOtherMonth = [UIColor colorWithRed:66/255.0 green:185/255.0 blue:40/255.0 alpha:1.0];/*选择非当月天的背景颜色*/
    self.calendar.calendarAppearance.dayTextColorWeekDay = MakeColor(0x28, 0x28, 0x28);                  /*周末天数文字颜色*/
    
    
    __weak MyCalendarViewController *wself = self;
    self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
        
        MyCalendarViewController *sself = wself;
        [sself updateCurrntDate];
        return @"";
    };
    
    self.calendar.menuMonthsView.hidden = YES;
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    
    [self.calendar setDataSource:self];

    [self.calendar reloadData];
    
    
    self.tableView.frame = CGRectMake(0,self.calendarContentView.bottom , self.allContentView.width, self.allContentView.height - self.calendarContentView.height);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 54, 0);
    
    // titleView上显示时间
    self.timeView.left = 0;
    self.timeView.top = 20;
    self.timeView.height = self.titleView.height - 20;
    self.timeView.width = self.titleView.width;
    [self.titleView addSubview:self.timeView];

    self.timeLable.left = (self.titleView.width - self.timeLable.width -30) *0.5;
    self.timeLable.top = (self.timeView.height - self.timeLable.height ) *0.5;
    self.iconImg.left = self.timeLable.right + 14;
    self.iconImg.top = (self.timeView.height - self.iconImg.height ) *0.5;
    self.pickerButton.left = self.timeLable.left;
    self.pickerButton.top = (self.timeView.height - self.pickerButton.height ) *0.5;
    self.pickerButton.width = self.timeLable.width + self.iconImg.width + 14;

    [self.pickerButton addTarget:self action:@selector(timePickerHidden:) forControlEvents:UIControlEventTouchUpInside];

    
 
}

- (void)updateCurrntDate {
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [[NSDateFormatter alloc] init];
        NSString *formatString = [NSString stringWithFormat:@"yyyy%@M%@",
                                  CSLocalizedString(@"myCalendar_VC_year"),
                                  CSLocalizedString(@"myCalendar_VC_month")];
        [dateFormatter setDateFormat:formatString];
    }
    NSDate *currentDate = self.calendar.currentDate;
    NSString *monthText = [dateFormatter stringFromDate:currentDate];
//    [self.titleView setTitleText:monthText];

    self.timeLable.text = monthText;
    [self.timeLable sizeToFit];
    self.timeLable.left = (self.titleView.width - self.timeLable.width -30) *0.5;
    self.iconImg.left = self.timeLable.right + 14;
    self.pickerButton.left = self.timeLable.left;
    self.pickerButton.width = self.timeLable.width + self.iconImg.width + 14;

}
- (void)timePickerHidden:(UIButton *)but
{
    self.myPickerView.currentDate = self.calendar.currentDate;
    [self.myPickerView showOrHidden:YES];
}

- (void)timePickerView
{
//    CGRect Frame = CGRectMake(0, self.allContentView.width - 25, self.allContentView.width, self.allContentView.height * 0.3403);

    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    __weak MyCalendarViewController *wself = self;
    self.myPickerView = [[TimePickerView alloc]initWithFrame:win.bounds withPickBlock:^(NSString *string) {
        MyCalendarViewController *sself = wself;
        CSLog(@"pickerDate%@",string);
        sself.timeLable.text = string;
        [sself dateStringToNSDate:string];
        [sself.myPickerView showOrHidden:NO];
    }];
    [win addSubview:self.myPickerView];
    

    
}

- (void)dateStringToNSDate:(NSString *)str
{
    NSString* string = str;
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init] ;
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [inputFormatter setDateFormat:@"yyyy年MM月"];
    NSDate* inputDate = [inputFormatter dateFromString:string];
    self.calendar.currentDate = inputDate;

}


- (void)initTabData {
    CSLog(@"MyCalendarViewController ==> 初始化/更新日历课程信息");
    [self resetHttp];
    NSDate *currentDate = self.calendar.currentDate;
    NSString *dateString = [[self dateFormatter] stringFromDate:currentDate];
//    [http_ myCalendar:[UserAccount shareInstance].uid date:dateString userType:[UserAccount shareInstance].loginUser.authority==UserAuthorityType_STUDENT?UserAuthorityType_STUDENT:UserAuthorityType_TEACHER jsonResponseDelegate:self];
    // 目前默认学生
    [http_ myCalendar:[UserAccount shareInstance].uid date:dateString userType:UserAuthorityType_STUDENT jsonResponseDelegate:self];
    
    [self timePickerView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.dataList) {
        [self initTabData];
        
    }
}


//==================================================
//JTCalendarDataSource
//==================================================
#pragma mark -
#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    
    NSString *dateString = [[self dateFormatter] stringFromDate:date];
    
    
    [self showHUD:nil];
    [self resetHttp];
//    [http_ myCalendar:[UserAccount shareInstance].uid date:dateString userType:[UserAccount shareInstance].loginUser.authority==UserAuthorityType_STUDENT?UserAuthorityType_STUDENT:UserAuthorityType_TEACHER jsonResponseDelegate:self];
    // 目前默认学生
    [http_ myCalendar:[UserAccount shareInstance].uid date:dateString userType:UserAuthorityType_STUDENT jsonResponseDelegate:self];
    CSLog(@"Date: %@ - ", date);
    
}

- (void)calendarDidLoadPreviousPage
{
    CSLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage
{
    CSLog(@"Next page loaded");
}

/**
 * 拓展上下滑动手势
 **/
- (void)calendarUpAndDownAction:(BOOL)isUp
{
    if (isUp) {
        CSLog(@"向上");
        if (!self.calendar.calendarAppearance.isWeekMode) {
            self.calendar.calendarAppearance.isWeekMode = YES;
            [self transitionExample];
        }
    }else {
        CSLog(@"向下");
        if (self.calendar.calendarAppearance.isWeekMode) {
            self.calendar.calendarAppearance.isWeekMode = NO;
            [self transitionExample];
        }
    }
    
    
}


#pragma mark - Transition examples

- (void)transitionExample
{
    CGFloat newHeight = 38 * 6 + 19;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 38 + 19;
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.calendarContentView.height = newHeight;
                         self.tableView.frame = CGRectMake(0,self.calendarContentView.bottom , self.allContentView.width, self.allContentView.height - self.calendarContentView.height);
                         [self.view layoutIfNeeded];
                     }];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.calendar reloadAppearance];
                         
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                          }];
                     }];
}

#pragma mark - Fake data

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return dateFormatter;
}


#pragma mark-
#pragma mark - HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    [self hiddenHUD];
    NSString *urlstring = [[request url] absoluteString];
    if ([urlstring rangeOfString:@"mobilelistCourseByDay"].location != NSNotFound) {
        ClassModelList*tmpClist = [[ClassModelList alloc] initWithJSON:[request responseJSON]];
        if (tmpClist.code_ == 0) {
            self.dataList = tmpClist;
        }else {
            self.dataList = nil;
            [Utils showToast:CSLocalizedString(@"myCalendar_VC_loadData_faild")];
        }
        [self reloadTableViewData];
    }else {
        [Utils showToast:CSLocalizedString(@"myCalendar_VC_loadData_faild")];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    [self hiddenHUD];
    [Utils showToast:CSLocalizedString(@"myCalendar_VC_loadData_faild")];
    self.dataList = nil;
    [self reloadTableViewData];
}



/**
 * 刷新单元格
 **/
- (void)reloadTableViewData
{
    if (self.dataList && self.dataList.list.count > 0) {
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
    if (self.dataList && self.dataList.list) {
        return self.dataList.list.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdn = @"MyCalendarClassCell";
    MyCalendarClassCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdn];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"MyCalendarClassCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdn];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdn];
    }
    cell.viewController = self;
    [cell setContentData:[self.dataList.list objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height =[[MyCalendarClassCell shareCalendarCell] setContentData:[self.dataList.list objectAtIndex:indexPath.row]];

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self showLoginVC]) {
        return;
    }
    ClassModel *model  = [self.dataList.list objectAtIndex:indexPath.row];
    
    LiveViewController *liveRoomVC = [[LiveViewController alloc] initWithRoomName:model.name coureid:model.cid classid:model.classid];
    [self.tabbarVC.navigationController pushViewController:liveRoomVC animated:YES];

   /* if ([UserAccount shareInstance].loginUser.authority == UserAuthorityType_TEACHER && [UserAccount shareInstance].uid == model.teacherId) {
        //老师
        TeaLiveViewController *teaVC = [[TeaLiveViewController alloc] initWithCourseName:model.name
                                                                                courseID:model.cid
                                                                                 classID:model.classid];
        
        [self.tabbarVC.navigationController pushViewController:teaVC animated:YES];
    }else {
        //学生
        LiveViewController *liveRoomVC = [[LiveViewController alloc] initWithRoomName:model.name coureid:model.cid classid:model.classid];
        [self.tabbarVC.navigationController pushViewController:liveRoomVC animated:YES];
    }
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
