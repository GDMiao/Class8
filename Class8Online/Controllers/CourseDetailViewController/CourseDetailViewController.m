//
//  CourseDetailViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/5/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "CourseWithLessonsView.h"
#import "CourseWithCommentsView.h"
#import "CourseDescriptionView.h"
#import "LiveViewController.h"
#import "TeaLiveViewController.h"
#import "CourseDetailModel.h"
#import "LessonsModel.h"


#define DefaultSelectedIndex 0
const int courseDeatilTotalRequestCount = 2;
@interface CourseDetailViewController ()<HFBrowserViewSourceDelegate,HFBrowserViewDelegate>
{
    int didLoadRequestCount;
}
@property (strong, nonatomic) CourseDetailModel *courseModel;
@property (strong, nonatomic) LessonsList *lessonsList;
@property (assign, nonatomic) long long courseID;
@end

@implementation CourseDetailViewController
- (id)initWithCourseid:(long long)courseID
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.courseID = courseID;
    }
    return self;
}
- (void)dealloc {
    self.courseModel = nil;
    self.courseInfoView = nil;
    self.courseModel = nil;
    self.lessonsList = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    didLoadRequestCount = 0;
    
    [self.titleView setTitleText:CSLocalizedString(@"courseDetail_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    self.courseInfoView.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.width / (5/3.0) + 37);
    [self.courseInfoView.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
//    [self.courseInfoView.joinClassRoom addTarget:self action:@selector(joinClassRoomAction)];
    self.courseInfoView.segmentedControl.selectedSegmentIndex = DefaultSelectedIndex;

    self.browserView = [[HFBrowserView alloc] initWithFrame:CGRectMake(0, self.courseInfoView.bottom, self.allContentView.width, self.allContentView.height - self.courseInfoView.bottom)];
    self.browserView.hidden = YES;
    self.browserView.bounces = NO;
    self.browserView.scrollEnabled = YES;
    self.browserView.sourceDelegate = self;
    self.browserView.dragDelegate = self;
    self.browserView.clipsToBounds = NO;
    [self.allContentView addSubview:self.browserView];
    [self.browserView setInitialPageIndex:DefaultSelectedIndex];
    
    [self getCourseInfo]; //获取课程信息

}

- (void)getCourseInfo {
    [self showHUD:nil];
    [self resetHttp];
//    [http_ eduPlatform:self.courseID jsonResponseDelegate:self];
    [http_ eduPlatformuserid:[UserAccount shareInstance].uid courseId:self.courseID jsonResponseDelegate:self];
    [http_ getCourseLessons:self.courseID jsonResPonseDelegate:self];
    
    
}

#pragma mark -
#pragma mark - HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    CSLog(@"HttpRequestDelegate : %@",[request responseJSON]);
    NSString *stringUrl = [[request url] absoluteString];
    
    if ([stringUrl rangeOfString:@"detail"].location != NSNotFound) {
        CourseDetailModel *course = [[CourseDetailModel alloc] initCourseDetailJosn:[request responseJSON]];
        //课程详情
        if (course.code_ == 0) {
            didLoadRequestCount ++;
            self.courseModel = course;
        }else {
            [self hiddenHUD];
            [Utils showToast:course.message_];
        }
    }
    else if ([stringUrl rangeOfString:@"course/classs"].location != NSNotFound) {
        LessonsList *tmpLesList = [[LessonsList alloc] initWithJSON:[request responseJSON]];
        if (tmpLesList.code_ == 0) {
            //课节目录
            didLoadRequestCount ++;
            self.lessonsList = tmpLesList;
            
        }else{
            [self hiddenHUD];
            [Utils showToast:tmpLesList.message_];
        }
    }
    if (didLoadRequestCount == courseDeatilTotalRequestCount) {
        [self hiddenHUD];
        [self didLoadData];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hiddenHUD];
    [Utils showToast:CSLocalizedString(@"courseDetail_VC_load_Faild")];
}

- (void)didLoadData {
    CSLog(@"加载完毕");
    self.courseInfoView.hidden = NO;
    self.browserView.hidden = NO;
    [self.courseInfoView updateCourseInfo:self.courseModel];
    [self.browserView reloadData];
}


- (void)joinClassRoomAction {
    CSLog(@"进入课堂");
    if (self.courseModel.canEnterClassID == 0) {
        [Utils showToast:@"该课程已经结束"];
        return;
    }
    else if(self.courseModel.canEnterClassID >0 && self.courseModel.canEnterClassID == self.courseModel.courseID) {
        LiveViewController *liveRoomVC = [[LiveViewController alloc] initWithRoomName:self.courseModel.courseName
                                                                              coureid:self.courseModel.courseID
                                                                              classid:self.courseModel.currentClassID];
        [self.navigationController pushViewController:liveRoomVC animated:YES];
    }
    
    

    
 /*
    if ([UserAccount shareInstance].loginUser.authority == UserAuthorityType_TEACHER && [UserAccount shareInstance].uid == self.courseModel.teacherid) {
        //老师
        TeaLiveViewController *teaVC = [[TeaLiveViewController alloc] initWithCourseName:self.courseModel.name
                                                                                courseID:self.courseID
                                                                                 classID:self.classid];
        
        [self.navigationController pushViewController:teaVC animated:YES];
    }else {
        LiveViewController *liveRoomVC = [[LiveViewController alloc] initWithRoomName:self.courseModel.name
                                                                              coureid:self.courseID
                                                                              classid:self.classid];
        [self.navigationController pushViewController:liveRoomVC animated:YES];
    }
    */

}


- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    CSLog(@"选择: %ld", (long)segmentedControl.selectedSegmentIndex);
    [self.browserView setInitialPageIndex:segmentedControl.selectedSegmentIndex animated:YES];
}


#pragma mark -
#pragma mark HFBrowserView Delegate
-(NSUInteger)numberOfPageInBrowserView:(HFBrowserView *)browser
{
    return 3;
}
-(UIView *)browserView:(HFBrowserView *)browser viewAtIndex:(NSUInteger)index
{
    if (index == 0) {
        CourseDescriptionView *desView = [[NSBundle mainBundle] loadNibNamed:@"CourseDescriptionView" owner:nil options:nil].lastObject;
        desView.viewController = self;
        LessonsModel *lessonsmodel = [self.lessonsList.list firstObject];
        desView.classidid = lessonsmodel.lessonsID;
        desView.frame = browser.bounds;
        [desView updateContent:self.courseModel];
        return desView;
        
    }
    else if (index == 1) {
        CourseWithLessonsView *classListView = [[CourseWithLessonsView alloc] initWithFrame:browser.bounds];
        classListView.teaName = self.courseModel.teaName;
        classListView.avatarURL = self.courseModel.teaAvatar;
        [classListView updateClassInfo:self.lessonsList];
        return classListView;
        
    }
    else {
        CourseWithCommentsView *courseComment = [[CourseWithCommentsView alloc] initWithFrame:browser.bounds];
        courseComment.courseid = self.courseID;
        courseComment.avgScore = self.courseModel.avgScore;
        courseComment.viewController = self;
        return courseComment;
    }
    return nil;
    
}

-(void)browserViewlDidEndDecelerating:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex
{
    [self.courseInfoView.segmentedControl setSelectedSegmentIndex:pageIndex animated:YES];
    [self refreshCurrentView];
}


-(void)browserViewlDidEndScrollingAnimation:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex
{
    //显示第几个视图了
    [self refreshCurrentView];
    
}

- (void)refreshCurrentView {
    UIView *pageView = [self.browserView getCurrentView];
    if ([pageView isKindOfClass:NSClassFromString(@"CourseWithCommentsView")]) {
        CourseWithCommentsView *courseComment = (CourseWithCommentsView *)pageView;
        if (!courseComment.dataList) {
            [courseComment startRefresh];
        }
    }else if ([pageView isKindOfClass:NSClassFromString(@"CourseDescriptionView")]) {
        CourseDescriptionView *desView = (CourseDescriptionView *)pageView;
        if (!desView.course) {
            [desView updateContent:self.courseModel];
        }
    }
}

@end
