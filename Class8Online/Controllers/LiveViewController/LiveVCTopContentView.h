//
//  LiveVCTopContentView.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/22.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFZoomView.h"
#import "WhiteBoradBoxViews.h"
#import "IMGCWView.h"
#import "MediaPreView.h"
#import "CLMoviePlayViewController.h"
#import "CLMovieView.h"

typedef enum {
    LiveCurrentStyle_Nomal = 10, 
    LiveCurrentStyle_Video,
    LiveCurrentStyle_WhiteBorad,
    LiveCurrentStyle_PDF,
    LiveCurrentStyle_IMG,
    LiveCurrentStyle_Audio,
    LiveCurrentStyle_ClassOver,    
}LiveCurrentStyle;

@interface LiveVCTopContentView : UIView
@property (strong, nonatomic) UIScrollView *scrollView;

//@property (strong, nonatomic) CLMoviePlayViewController *video; //视频
@property (strong, nonatomic) CLMovieView *clVideo;             //视频<新>

@property (strong, nonatomic) WhiteBoradBoxViews *whiteBgView;  //白板
@property (strong, nonatomic) PDFZoomView *pdfBgView;           //PDF
@property (strong, nonatomic) IMGCWView *imgView;               //图片
@property (strong, nonatomic) MediaPreView *mediaPlayerView;    //媒体播放器<MP3>
@property (assign, nonatomic) BOOL devicePortrait;
@property (strong ,nonatomic) NSString *mediaSrcUrl;            /*媒体直播地址*/

//=========================================
//TODO: 切换视频路数 播放器为空则创建
//=========================================
- (void)changePlayerWithVideo:(int)videoID srcUrl:(NSString *)url;
//TODO: 初始化视频
- (void)createVideoPlayer:(NSString *)srcUrl playVideoId:(int)vid;

//=========================================
//TODO: 初始播放 默认第一路
//=========================================
- (void)clMovePlyerStatrPlay:(int)videoId;

//=========================================
//TODO: 播放学生视频
//=========================================
- (void)playStuVideo:(NSString *)stuVideoUrl;

//=========================================
//TODO: 播放学生视频
//=========================================
- (void)stopStuVideo;

//=========================================
//TODO: 开始传输本地音视频
//========================================
- (void)startLoginUserVideo:(NSString *)uVideoUrl;
//=========================================
//TODO: 停止传输本地音视频
//========================================
- (void)stopLoginUserVideo;

//=========================================
//TODO: 改变显示模式 PDF/教师视频/图片/音频课件/白板
//=========================================
- (void)changeViewToStyle:(LiveCurrentStyle)style isAnimate:(BOOL)animat;


#pragma mark-
#pragma mark- 添加下载任务课件下载
- (void)addDownLoadFile:(NSString *)urlPath;

#pragma mark-
#pragma mark- 用户进入课堂初始化数据
- (void)allocConten:(UserWelecomeModel *)userWelModel;

#pragma mark-
#pragma mark- 更新课件显示操作
- (void)updateCourseWera:(SwitchClassShowModel *)cwSwitchShowModel;

#pragma mark-
#pragma mark- 更新主窗口显示
- (void)updateMainShow:(SetMainShowModel *)mainShow;

#pragma mark-
#pragma mark- 添加/删除/关闭课件
- (void)addCourseWare:(AddCourseWareModel *)cwModel;

#pragma mark-
#pragma mark- 更新白板操作
- (void)updateWhiteBoardAction:(WhiteBoardActionModel *)wbActionModel;

#pragma mark-
#pragma mark- 创建白板
- (void)createWhiteBoard:(CreateWhiteBoardModel *)createWbModel;


#pragma mark-
#pragma mark- 课程结束
- (void)classOver;
@end
