//
//  CourseDescriptionView.m
//  Class8Online
//
//  Created by chuliangliang on 16/3/21.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CourseDescriptionView.h"
#import "CourseDetailModel.h"
#import "UIImageView+WebCache.h"
#import "UserCenterViewController.h"
#import "SubmitOrderViewController.h"
#import "LiveViewController.h"
#import "LoginViewController.h"
#import "BasicNavigationController.h"
#import "JSONModel.h"
const int TotalRequestCount = 1;
@interface CourseDescriptionView ()
{
    int didLoadRequestCount;
}
@property (strong, nonatomic) BasicNavigationController *tabbarNavVC;
@end

@implementation CourseDescriptionView

- (void)dealloc
{
    self.scrollView = nil;
    self.infoView = nil;
    self.infoBgImg = nil;
    self.coursePrice = nil;
    self.teachingTea = nil;
    self.organization = nil;
    self.score = nil;
    self.lessonstime = nil;
    self.jqBgImg = nil;
    self.jqLabel = nil;
    self.mzLabel = nil;
    self.xzLabel = nil;
    self.zzLable = nil;
    self.pfLabel = nil;
    self.timeLabel = nil;
    self.infoBottomLine = nil;
    self.courseMb = nil;
    self.mbTextView = nil;
    self.desbottomLine = nil;
    self.course = nil;
    
    self.infobutton = nil;
    
    self.viewController = nil;
    
}

- (IBAction)avatarAction:(UIButton *)sender {
    CSLog(@"老师头像点击");
    UserCenterViewController *userCenter = [[UserCenterViewController alloc] initWithUiD:self.course.teaUid isTeacher:YES];
    [self.viewController.navigationController pushViewController:userCenter animated:YES];
}

- (void)updateContent:(CourseDetailModel *)courseModel
{
    self.course = courseModel;

    self.scrollView.frame = self.bounds;
    self.scrollView.bounces = NO;
    
//    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    CGFloat scrollH = [self updataCourseInfo];
    self.scrollView.contentSize = CGSizeMake(self.width, scrollH);
}


- (CGFloat)updataCourseInfo
{
    CGFloat height;
    
    self.infoView.frame = self.bounds;
    
    self.coursePrice.left = 20;
    self.coursePrice.left = 20;
    
    self.jqBgImg.left = self.coursePrice.right + 10;
    self.jqBgImg.top = self.infoBgImg.top + 20;
    
    self.jqLabel.text = [NSString stringWithFormat:@" %0.2f元",self.course.coursePrice];
    [self.jqLabel sizeToFit];
    self.jqLabel.left = self.jqBgImg.left + (self.jqBgImg.width - self.jqLabel.width) /2;
    self.jqLabel.top = self.jqBgImg.top + (self.jqBgImg.height - self.jqLabel.height) /2;;
//    self.jqLabel.width = self.jqBgImg.width;
    
    self.teachingTea.left = self.coursePrice.left;
    self.teachingTea.top = self.coursePrice.bottom + 10;
    
    self.mzLabel.text = self.course.teaName;
    [self.mzLabel sizeToFit];
    self.mzLabel.left = self.teachingTea.right + 5;
    self.mzLabel.top = self.teachingTea.top;
    
    self.organization.left = self.teachingTea.left;
    self.organization.top = self.teachingTea.bottom + 10;
    self.zzLable.text = self.course.schoolName;  // 组织名字
    [self.zzLable sizeToFit];
    self.zzLable.left = self.organization.right + 5;
    self.zzLable.top = self.organization.top;
    
    self.score.left = self.organization.left;
    self.score.top = self.organization.bottom + 10;
    //
    CGFloat teaScore = self.course.avgScore; //教师评分 暂时写死 <服务器未记录此属性>
    self.t_starsView.frame = CGRectMake(self.score.right + 5, self.score.top +5, 72, 12);
    [self.t_starsView updateContent:teaScore];
    self.pfLabel.text = [NSString stringWithFormat:@"%0.1f分",teaScore];
    [self.pfLabel sizeToFit];
    self.pfLabel.left = self.t_starsView.right+10;
    self.pfLabel.top = self.t_starsView.top + (self.t_starsView.height - self.pfLabel.height) * 0.5;
    
    self.lessonstime.left = self.score .left;
    self.lessonstime.top = self.score.bottom + 10;
    
    self.timeLabel.text = self.course.courseBeginTime;
    [self.timeLabel sizeToFit];
    self.timeLabel.left = self.lessonstime.right + 5;
    self.timeLabel.top = self.lessonstime.top;
    
    self.infoBottomLine.left = 0;
    self.infoBottomLine.top = self.lessonstime.bottom + 15;
    

    self.courseMb.left = 20;
    self.courseMb.top = self.infoBottomLine.bottom + 17;


    self.infobutton.left = 10;
    self.infobutton.bottom =  self.infoView.bottom - 10;
    self.infobutton.width = self.width - 2*self.infobutton.left;
    if (self.course.classHadFinished ==0) {
        if (self.course.signupStatus == 0) {
            [self.infobutton setTitle:@"立即报名" forState:UIControlStateNormal];
            self.infobutton.tag = 1001;
        }else if (self.course.signupStatus == 1 ){
            [self.infobutton setTitle:@"进入课堂" forState:UIControlStateNormal];
            self.infobutton.tag = 1002;
        }
    }else if (self.course.classHadFinished == 1){
        [self.infobutton setTitle:@"课程结束" forState:UIControlStateNormal];
    }
    
    self.infobutton.titleLabel.font = [UIFont systemFontOfSize:17];
    self.infobutton.backgroundColor = MakeColor(0x23, 0x95, 0x199);
    self.infobutton.layer.cornerRadius = 5.f;
    [self.infobutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.infobutton addTarget:self action:@selector(AddOrder:) forControlEvents:UIControlEventTouchUpInside];
    
    self.desbottomLine.bottom = self.infobutton.top -10;
    self.desbottomLine.left = 0;
    
    self.mbTextView.text = self.course.courseDescription;
    self.mbTextView.left = self.courseMb.left;
    self.mbTextView.top = self.courseMb.bottom + 10;

    self.mbTextView.width = self.width - 2*self.mbTextView.left;
    self.mbTextView.height = self.desbottomLine.bottom - self.courseMb.bottom - 20;
    self.mbTextView.editable = NO;
    
    height = self.infoView.height ;
    return height;
}

- (void)AddOrder:(UIButton *)button
{
    
    switch (button.tag) {
        case 1001:
        {
            if (![UserAccount shareInstance].loginUser) {
                CSLog(@"您未登录");
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您未登录" message:@"请您登录账户" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
                [alertView show];
                return;
                
            }
            CSLog(@"报名人数： %d",self.course.studentTotal);
            if(self.course.studentTotal < 4){
                
//                if (self.course.coursePrice == 0) {
//                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"报名" message:@"当前课程为零元，您确定要立即报名吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"报名", nil];
//                    [alertView show];
////                    [self zeroRMBInfo];
//                    return;
//                }else{
                [self zeroRMBInfo];
//                }
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"报名人数已满" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
        }
            break;
        case 1002:{
            if (![UserAccount shareInstance].loginUser) {
                CSLog(@"您未登录");
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您未登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
                [alertView show];
                return;
                
            }
            if (self.course.canEnterClassID == 0) {
                [Utils showToast:@"现在不能进入课堂"];
                return;
            }
            CSLog(@"进入课堂");
            LiveViewController *liveRoomVC = [[LiveViewController alloc] initWithRoomName:self.course.courseName
                                                                                  coureid:self.course.courseID
                                                                                  classid:self.course.currentClassID];
            [self.viewController.navigationController pushViewController:liveRoomVC animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        CSLog(@"登录");
        if (![UserAccount shareInstance].loginUser) {

            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
            loginVC.isPushed = NO;
            BasicNavigationController *navFirstLoginVc = [[BasicNavigationController alloc] initWithRootViewController:loginVC];
            
            AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
            [self.viewController presentViewController:navFirstLoginVc animated:YES completion:NULL];
            
           
        }
//        else if (self.course.coursePrice == 0) {
//            //
//            [self zeroRMBInfo];
//        }
        
    }
   
    
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

- (void)zeroRMBInfo
{
    if (!http_) {
        http_ = [[HttpRequest alloc] init];
    }
    [http_ getPianoImmediatelySignUpWithUid:[UserAccount shareInstance].uid Courseid:self.course.courseID Classid:self.classidid jsonResPonseDelegate:self];
}

#pragma mark -
#pragma mark - HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    CSLog(@"HttpRequestDelegate : %@",[request responseJSON]);
    NSString *stringUrl = [[request url] absoluteString];

    if ([stringUrl rangeOfString:@"signup"].location != NSNotFound) {
        JSONModel *status = [[JSONModel alloc] initWithJSON:[request responseJSON]];
        //课程详情
        if (status.code_ == 1) {
            didLoadRequestCount ++;
            
        }else {
            CSLog(@"提交订单页面");
            __weak typeof(self) weakself = self;
            SubmitOrderViewController *submitVC = [[SubmitOrderViewController alloc]initWithNibName:nil bundle:nil];
            submitVC.courseTime = self.course.courseBeginTime;
            submitVC.courseName = self.course.courseName;
            submitVC.coursePrice = self.course.coursePrice;
            submitVC.classid = self.classidid;
            submitVC.coursid = self.course.courseID;
            submitVC.userid = [UserAccount shareInstance].uid;
            submitVC.payresulBlock = ^(NSString *payreslut){
                CSLog(@"%@",payreslut);
                if (payreslut) {
                    [weakself.infobutton setTitle:@"进入课程" forState:UIControlStateNormal];
                    weakself.infobutton.tag = 1002;
                }
                
            };
            [self.viewController.navigationController pushViewController:submitVC animated:YES];
 
            
        }
    }
    if (didLoadRequestCount == TotalRequestCount) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"报名状态" message:@"当前0元课程报名成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        [self.infobutton setTitle:@"进入课堂" forState:UIControlStateNormal];
        self.infobutton.tag = 1002;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
//    [self hiddenHUD];
    [Utils showToast:CSLocalizedString(@"courseDetail_VC_load_Faild")];
}
@end
