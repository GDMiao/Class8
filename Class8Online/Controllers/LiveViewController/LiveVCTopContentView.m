//
//  LiveVCTopContentView.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/22.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "LiveVCTopContentView.h"
#import "Downloader.h"
#import "DView.h"
#import "FileCacheManager.h"
#import "ClassOverBoxView.h"
#import "ClassWaitBoxView.h"

@interface LiveVCTopContentView ()<UIScrollViewDelegate>
{
    BOOL isDrag;
    int scrollShowPage;
    CGSize self_InitSize;
}
@property (strong, nonatomic) NSString *currentCWFileName;      //当前显示的课件名


@property (assign, nonatomic) LiveCurrentStyle currentStyle;    //当前显示的类型 PDF/音频/图片
@property (assign, nonatomic) int currentPage;                  //当前显示课件的页数

@property (strong, nonatomic) Downloader *downLoader;           //下载工具

@property (strong, nonatomic) ClassOverBoxView *classOverView;  //下课状态View
@property (strong, nonatomic) ClassWaitBoxView *classWaitView;  //等待上课状态View

@end

@implementation LiveVCTopContentView
@synthesize devicePortrait;
- (void)dealloc {
//    if (self.video) {
//        [self.video stop];
//        self.video = nil;
//    }
    CSLog(@"\n**************************\nLiveVCTopContentView ==> 销毁.....");
    if (self.clVideo) {
        [self.clVideo clearnALL];
        self.clVideo = nil;
    }
    if (self.mediaPlayerView) {
        [self.mediaPlayerView stop];
        self.mediaPlayerView = nil;
    }
    self.mediaSrcUrl = nil;
    self.currentCWFileName = nil;
    self.whiteBgView = nil;
    self.pdfBgView = nil;
    self.imgView = nil;

    self.downLoader = nil;
    self.classOverView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews
{
    self_InitSize = self.bounds.size;
    self.backgroundColor = [UIColor blackColor];
    scrollShowPage = 0;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    //    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    [self addSubview:self.scrollView];
    
    //监听PDF文件 下载成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pdfFileDidFinishDownload:) name:KNotification_DownLoadFIleDidFinish object:nil];

    self.currentStyle = LiveCurrentStyle_Nomal;
    self.classWaitView.hidden = NO;
    self.classOverView.hidden = YES;
    self.scrollView.hidden = YES;
    



}

#pragma mark -
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offx = scrollView.contentOffset.x;
    if (offx > self.width * 0.5) {
        scrollShowPage = 1;
    }else {
        scrollShowPage = 0;
    }
}

- (void)layoutSubviews {
    CGFloat scrollOffx = self.width * scrollShowPage;
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.width * 2, self.height);
    
    [self.scrollView setContentOffset:CGPointMake(scrollOffx, 0) animated:NO];
    
//    self.video.view.top = 0;
//    self.video.view.left = self.width;
    self.clVideo.top = 0;
    self.clVideo.left = self.width;
    
    
    self.whiteBgView.top = 0;
    self.whiteBgView.left = 0;
    
    self.pdfBgView.top = 0;
    self.pdfBgView.left = 0;
    
    self.imgView.top = 0;
    self.imgView.left = 0;
    
    
}
//=========================================
//TODO: 初始化视频
//=========================================
- (void)createVideoPlayer:(NSString *)srcUrl playVideoId:(int)vid{

    if (self.clVideo) {
        return;
    }
    self.mediaSrcUrl = srcUrl;
    self.clVideo = [[CLMovieView alloc] initWithFrame:CGRectMake(self.width, 0, self.width, self.height)
                                            aMediaUrl:srcUrl
                                           teaVideoId:vid
                                          askMediaUrl:nil
                                       atCurrentStyle:CLMovieCurrentStyle_OnlyTea];
    
    [self.scrollView addSubview:self.clVideo];
    
    
//    if (self.video) {
//        return;
//    }
//    self.mediaSrcUrl = srcUrl;
//    self.video = [[CLMoviePlayViewController alloc] initWithFrame:CGRectMake(self.width, 0, self.width, self.height)];
//    [self.video updateContentFrame:CGRectMake(self.width, 0, self.width, self.height) isAnimate:NO canAutoLayout:self.video.canAutoLayout];
//    self.video.srcUrl = srcUrl;
//    self.video.currentVideoID = vid;
//    
//    [self.scrollView addSubview:self.video.view];
}
//=========================================
//TODO: 切换视频路数
//=========================================
- (void)changePlayerWithVideo:(int)videoID srcUrl:(NSString *)url
{
    ClassRoomLog(@"LiveVCTopContentView:老师切换视频=> %d",videoID);
    [self createVideoPlayer:url playVideoId:videoID];
    [self.clVideo changeTeaVideo:videoID];

//    self.mediaSrcUrl = url;
//    if (!self.video) {
//        [self createVideoPlayer:url playVideoId:videoID];
//    }else {
//        self.video.srcUrl = url;
//        [self.video changeVideo: videoID];
//    }
}

//=========================================
//TODO: 初始播放 默认第一路
//=========================================
- (void)clMovePlyerStatrPlay:(int)videoId
{

    [self.clVideo startPlayTeaVido:MAX(1, videoId)];
    
//    self.video.view.hidden = NO;
//    self.video.currentVideoID = MAX(1, videoId);
//    self.video.srcUrl = self.mediaSrcUrl;
//    [self.video play];
}

//=========================================
//TODO: 播放学生视频
//=========================================
- (void)playStuVideo:(NSString *)stuVideoUrl
{
    [self.clVideo startPlayAskStu:stuVideoUrl];
    
//    [self.video playStudentVideo:stuVideoUrl];
}

//=========================================
//TODO: 播放学生视频
//=========================================
- (void)stopStuVideo
{
    [self.clVideo stopAskStuVideo];
    
//    [self.video stopStudentVideo];
}

//=========================================
//TODO: 开始传输本地音视频
//========================================
- (void)startLoginUserVideo:(NSString *)uVideoUrl
{
    [self.clVideo startLoginUserVideo:uVideoUrl];
    
//    [self.video startLoginUserVideo:uVideoUrl];
}
//=========================================
//TODO: 停止传输本地音视频
//========================================
- (void)stopLoginUserVideo
{
    [self.clVideo stopLoginUserVideo];
//    [self.video stopLoginUserVideo];
}


//==========================
// TODO: 初始化PDF
//==========================
- (PDFZoomView *)pdfBgView {
    if (!_pdfBgView) {
        _pdfBgView = [[PDFZoomView alloc] initWithFrame:self.bounds];
        _pdfBgView.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:_pdfBgView];
    }
    return _pdfBgView;
}

//========================
//TODO:初始化白板
//========================
- (WhiteBoradBoxViews *)whiteBgView
{
    if (!_whiteBgView) {        
        _whiteBgView = [[WhiteBoradBoxViews alloc] initWithFrame:self.bounds];
        _whiteBgView.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:_whiteBgView];
    }


    return _whiteBgView;
}

//========================
//TODO: 初始化 图片课件展示
//=========================
- (IMGCWView *)imgView {
    if (!_imgView) {
        _imgView = [[IMGCWView alloc] initWithFrame:self.bounds];
        _imgView.backgroundColor = [UIColor blackColor];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:_imgView];
    }
    return _imgView;
}


//=========================
//TODO:初始化媒体播放器
//=========================
- (MediaPreView *)mediaPlayerView {
    if (!_mediaPlayerView) {
        _mediaPlayerView = [[MediaPreView alloc] initWithFrame:self.bounds];
        [self.scrollView addSubview:_mediaPlayerView];
    }
    return _mediaPlayerView;
}

//==========================
//TODO:初始化下课状态图
//==========================
- (ClassOverBoxView *)classOverView {
    if (!_classOverView) {
        _classOverView = [[ClassOverBoxView alloc] initWithFrame:self.bounds];
        _classOverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _classOverView.hidden = YES;
        [self insertSubview:_classOverView atIndex:0];
    }
    return _classOverView;
}

//==========================
//TODO:初始化等待上课状态图
//==========================
- (ClassWaitBoxView *)classWaitView {
    if (!_classWaitView) {
        _classWaitView = [[ClassWaitBoxView alloc] initWithFrame:self.bounds];
        _classWaitView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _classWaitView.hidden = YES;
        [self insertSubview:_classWaitView atIndex:0];
    }
    return _classWaitView;
}


#pragma mark-
#pragma mark- 添加下载任务课件下载
- (void)addDownLoadFile:(NSString *)urlPath
{
    /**
     * 这里不在下载课件 转移到 课件列表展示并下载 update for V(pc) 3.0
     **/
    
    /*
    if ([Utils isAudioCourse:urlPath]) {
        //音频
        ClassRoomLog(@"LiveVCTopContentView:增加课件 ==> 音频 文件:%@",urlPath);
        [self addDownLoadFile:[Utils getAudioCoursePath:urlPath] withDownLoaderFileType:FileType_Audio];
    }else if ([Utils isImgCourse:urlPath]) {
        //图片
        ClassRoomLog(@"LiveVCTopContentView:增加课件 ==> 图片 文件:%@",urlPath);
        [self addDownLoadFile:[Utils getImgCoursePath:urlPath] withDownLoaderFileType:FileType_Img];
    }else {
        //pdf
        ClassRoomLog(@"LiveVCTopContentView:增加课件 ==> PDF 文件:%@",urlPath);
        [self addDownLoadFile:[Utils getPDFDownLoadPath:urlPath] withDownLoaderFileType:FileType_PPT];
    }
     */
}
//- (void)addDownLoadFile:(NSString *)url withDownLoaderFileType:(FileType )type
//{
//    if (!self.downLoader) {
//        self.downLoader = [[Downloader alloc] init];
//        [self.downLoader setDownloadMaxOperationCount:3];
//    }
//    
//    NSString *downLoadUrl = [NSString stringWithFormat:@"%@%@",PDFDownloadUrl,url];
//    ClassRoomLog(@"LiveVCTopContentView:课件下载地址: %@\n 课件类型:%d",url,type);
//    BOOL fileIsExit = [self.downLoader fileExisted:url fileType:type];
//    ClassRoomLog(@"LiveVCTopContentView:课件:%@  %@",url,fileIsExit?@"存在 ==> 不下载":@"不存在 ==>下载");
//    if (!fileIsExit) {
//        //不存在则下载
//        [self.downLoader addDownloaderFileUrl:downLoadUrl fileType:type byUser:NO delegate:nil];
//    }
//}

#pragma mark-
#pragma mark- 课件下载成功通知..
//TODO: 下载完成通知 NSNotification
- (void)pdfFileDidFinishDownload:(NSNotification *)notification
{
    NSDictionary *dic = [notification object];
    int fileType = [dic intForKey:DOWNLOADERFILETYPE];
    ClassRoomLog(@"LiveVCTopContentView:下载课件完成:%@",dic);
    if (FileType_PPT == fileType) {
        //PDF
        NSString *fileName = [dic stringForKey:DOWNLOADERFILENAME];
        ClassRoomLog(@"LiveVCTopContentView:PDF下载完成:%@ 当前显示PDF:%@ 当前页数:%d" ,fileName,self.currentCWFileName,self.currentPage);
        if ([self.currentCWFileName isEqualToString:fileName]) {
            //是则更新文件
            if (LiveCurrentStyle_PDF == self.currentStyle) {
                [self.pdfBgView updatePDFFile:self.currentCWFileName withCurrentPage:self.currentPage];
            }
        }
    }else if (FileType_Img == fileType) {
        //图片
        NSString *fileName = [dic stringForKey:DOWNLOADERFILENAME];
        ClassRoomLog(@"LiveVCTopContentView:图片课件下载完成:%@ 当前显示图片:%@ 当前页数:%d" ,fileName,self.currentCWFileName,self.currentPage);
        if ([self.currentCWFileName isEqualToString:fileName]) {
            //是则更新显示图片
            if (LiveCurrentStyle_IMG == self.currentStyle) {
                [self updateImgCourse:self.currentCWFileName];
            }
        }
        
    }else if (FileType_Audio == fileType || FileType_video == fileType) {
        //音视频频课件
        NSString *fileName = [dic stringForKey:DOWNLOADERFILENAME];
        ClassRoomLog(@"LiveVCTopContentView:音频下载完成:%@ 当前显示PDF:%@ 当前页数:%d" ,fileName,self.currentCWFileName,self.currentPage);
        if ([self.currentCWFileName isEqualToString:fileName]) {
            //是则更新文件
            if (LiveCurrentStyle_Audio == self.currentStyle) {
                [self updateAudioCourse:self.currentCWFileName page:self.currentPage];
            }
        }
        
    }
}

#pragma mark-
#pragma mark -  PDF 操作 (显示/翻页/涂鸦)
//TODO: 更新PDF显示
- (void)upDatePDFView:(NSString *)pdfName showPage:(int)page {
    
    
    self.currentCWFileName = [Utils getPdfFileName:pdfName];
    ClassRoomLog(@"LiveVCTopContentView:更新PDF显示 ==> PDF名字:%@ PAGE: %d \n self.currentPDFFileName:%@",pdfName , page,self.currentCWFileName);
    self.currentPage = page;
    
    BOOL fileIsExit = [FILECACHEMANAGER fileExisted:self.currentCWFileName fileType:FileType_PPT];
    if (fileIsExit) {
        //存在
        [self.pdfBgView updatePDFFile:self.currentCWFileName withCurrentPage:self.currentPage];
    }else {
        //不存在 需要显示菊花
        [self.pdfBgView showLoadingSttus];
    }
}
//================
//TODO: PDF 上绘图
//================
- (void)pdfViewDrawRect:(WhiteBoardActionModel *)wbModel
{
    [self.pdfBgView updatePDFGraffito:wbModel];
}

#pragma mark- PDF 绘图 初始进入绘制正在显示的PDF 绘图
- (void)drawOldPdfWithNowPage:(NSArray *)arr {
    //过滤数据
    uint pdfId = [Utils crc32Value:self.currentCWFileName];
    if (pdfId <= 0) {
        return;
    }
    ClassRoomLog(@"LiveVCTopContentView:初始进入绘制正在显示的PDF 绘图");
    
    NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
    for (int i = arr.count - 1;i >= 0;i--) {
        WhiteBoardActionModel *wbModel = [arr objectAtIndex:i];
        if (wbModel.owerid == pdfId && wbModel.pageId == self.currentPage - 1) {
            if (wbModel.paintype == WhiteBoardEventModelType_Clearn) {
                break;
            }
            [tmpArr insertObject:wbModel atIndex:0];
        }
    }
    for (WhiteBoardActionModel *wbAcModel in tmpArr) {
        [self pdfViewDrawRect:wbAcModel];
    }
}

#pragma mark-
#pragma mark- 图片课件操作
//==============================
//TODO: 更新图片课件
//==============================
- (void)updateImgCourse:(NSString *)imgName {
    ClassRoomLog(@"LiveVCTopContentView:更新图片课件: %@",imgName);
    self.currentCWFileName = imgName;
    [self.imgView updateConten:imgName];
}

#pragma mark-
#pragma mark - 音频课件操作
//==============================
//TODO: 音频课件操作
//==============================
#define AudioControllRePlayPage -1 //play
#define AudioControllPausePage -2 //pause

- (void)updateAudioCourse:(NSString *)audioName page:(int)p{
    self.currentCWFileName = audioName;
    self.currentPage = p;
    BOOL fileExist = [FILECACHEMANAGER fileExisted:self.currentCWFileName fileType:FileType_Audio];
    if (!fileExist) {
        return;
    }
    
    NSString *audioPath = [[FILECACHEMANAGER getFileRootPathWithFileType:FileType_Audio] stringByAppendingPathComponent:audioName];
    if (![audioPath isEqualToString:self.mediaPlayerView.audioPath]) {
        self.mediaPlayerView.audioPath = audioPath;
    }

     ClassRoomLog(@"LiveVCTopContentView:音视频课件操作 ==> page:%d Name:%@",p,audioName);
    switch (p) {
        case AudioControllRePlayPage:
        {
            [self.mediaPlayerView play];
        }
            break;
        case AudioControllPausePage:
        {
            [self.mediaPlayerView pause];
        }
            break;
            
        default:
        {
            [self.mediaPlayerView playAtTime:p];
        }
            break;
    }
}

//TODO: 更新白板数据 <删除笔画/增加笔画/增加文字>
- (void)upDateWbData:(WhiteBoardActionModel *)wbModel
{
    if (![self.whiteBgView updateWhiteBoradData:wbModel]) {
        if (self.currentStyle == LiveCurrentStyle_PDF) {
            [self pdfViewDrawRect:wbModel];
        }else {
            ClassRoomLog(@"LiveVCTopContentView:更新白板数据 ==> 未找到需要绘制的白板id:%d 画笔id:%d",wbModel.pageId,wbModel.paintId);
        }
    }
}


#pragma mark-
#pragma mark- 用户进入课堂初始化数据
- (void)allocConten:(UserWelecomeModel *)userWelModel
{
    switch (userWelModel.current.showType) {
        case CurrentShowModelType_BLANK:
        {
            
        }
            break;
        case CurrentShowModelType_COURSEWARE:
        {
            //课件
            if ([Utils isAudioCourse:userWelModel.current.name]) {
                //音频课件
                ClassRoomLog(@"LiveVCTopContentView:进入课堂主窗口初始状态显示 == > 音频");
                [self updateAudioCourse:[[Utils getAudioCoursePath:userWelModel.current.name] lastPathComponent]page:userWelModel.current.page];
                if ([Utils objectIsNotNull:self.currentCWFileName]) {
                    if (self.currentStyle != LiveCurrentStyle_Audio) {
                        [self changeViewToStyle:LiveCurrentStyle_Audio isAnimate:YES];
                    }
                }else {
                    ClassRoomLog(@"LiveVCTopContentView:进入课堂音频课件名字未读取到 不处理");
                }
                
            }else if ([Utils isImgCourse:userWelModel.current.name]) {
                //图片
                ClassRoomLog(@"LiveVCTopContentView:进入课堂主窗口初始状态显示 == > IMG");
                [self updateImgCourse:[[Utils getImgCoursePath:userWelModel.current.name] lastPathComponent]];
                if ([Utils objectIsNotNull:self.currentCWFileName]) {
                    if (self.currentStyle != LiveCurrentStyle_IMG) {
                        [self changeViewToStyle:LiveCurrentStyle_IMG isAnimate:YES];
                    }
                }else {
                    ClassRoomLog(@"LiveVCTopContentView:进入课堂IMG名字未读取到 不处理");
                }
                
            }else {
                //PDF
                ClassRoomLog(@"LiveVCTopContentView:进入课堂主窗口初始状态显示 == > PDF");
                [self upDatePDFView:userWelModel.current.name showPage:userWelModel.current.page+1];
                if ([Utils objectIsNotNull:self.currentCWFileName]) {
                    if (self.currentStyle != LiveCurrentStyle_PDF) {
                        [self drawOldPdfWithNowPage:userWelModel.whiteBoardActions];
                        [self changeViewToStyle:LiveCurrentStyle_PDF isAnimate:YES];
                    }
                }else {
                    ClassRoomLog(@"LiveVCTopContentView:进入课堂PDF名字未读取到 不处理");
                }
            }
        }
            break;
        case CurrentShowModelType_WHITEBOARD:
        {
            //白板
            [self.whiteBgView switchShowWhiteBorad:userWelModel.current.page];
            for (WhiteBoardActionModel *wbAction in userWelModel.whiteBoardActions) {
                if (wbAction.pageId == userWelModel.current.page) {
                    [self upDateWbData:wbAction];
                }
            }
            [self changeViewToStyle:LiveCurrentStyle_WhiteBorad isAnimate:YES];
            ClassRoomLog(@"LiveVCTopContentView:进入课堂主窗口初始状态显示 == > 白板id:%d",userWelModel.current.page);
        }
            break;
            
        default:
            break;
    }
    if (userWelModel.current.showType != CurrentShowModelType_BLANK) {
        if (MainShowType_VEDIO == userWelModel.mainshow) {
            //切换到视频
            [self.scrollView setContentOffset:CGPointMake(self.width, 0) animated:NO];
        }else{
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        }

    }
}


#pragma mark-
#pragma mark- 更新课件显示操作
- (void)updateCourseWera:(SwitchClassShowModel *)cwSwitchShowModel
{
    switch (cwSwitchShowModel.currentShow.showType) {
        case CurrentShowModelType_BLANK:
        {
            //初始状态 <iOS目前 以老师主视频 代替>
            [self changeViewToStyle:LiveCurrentStyle_Nomal isAnimate:YES];
            [self.mediaPlayerView stop];
            ClassRoomLog(@"LiveVCTopContentView:状态切换==>初始状态");
        }
            break;
        case CurrentShowModelType_COURSEWARE:
        {
            //课件
            if ([Utils isAudioCourse:cwSwitchShowModel.currentShow.name]) {
                //音频课件
                ClassRoomLog(@"LiveVCTopContentView:状态切换==>音频课件 播放时间: %d",cwSwitchShowModel.currentShow.page);
                [self updateAudioCourse:[[Utils getAudioCoursePath:cwSwitchShowModel.currentShow.name] lastPathComponent] page:cwSwitchShowModel.currentShow.page];
                if ([Utils objectIsNotNull:self.currentCWFileName]) {
                    if (self.currentStyle != LiveCurrentStyle_Audio) {
                        [self changeViewToStyle:LiveCurrentStyle_Audio isAnimate:YES];
                    }
                }else {
                    ClassRoomLog(@"LiveVCTopContentView:音频课件 名字未读取到 不处理");
                }
                
                
            }else if ([Utils isImgCourse:cwSwitchShowModel.currentShow.name]) {
                //图片课件
                [self.mediaPlayerView stop];
                ClassRoomLog(@"LiveVCTopContentView:状态切换==>图片课件");
                [self updateImgCourse:[[Utils getImgCoursePath:cwSwitchShowModel.currentShow.name] lastPathComponent]];
                if ([Utils objectIsNotNull:self.currentCWFileName]) {
                    if (self.currentStyle != LiveCurrentStyle_IMG) {
                        [self changeViewToStyle:LiveCurrentStyle_IMG isAnimate:YES];
                    }
                }else {

                    ClassRoomLog(@"LiveVCTopContentView:图片 名字未读取到 不处理");
                }
                
            }else {
                // pdf 课件
                [self.mediaPlayerView stop];
                ClassRoomLog(@"LiveVCTopContentView:状态切换==>课件pdf");
                [self upDatePDFView:cwSwitchShowModel.currentShow.name showPage:cwSwitchShowModel.currentShow.page+1];
                if ([Utils objectIsNotNull:self.currentCWFileName]) {
                    if (self.currentStyle != LiveCurrentStyle_PDF) {
                        [self changeViewToStyle:LiveCurrentStyle_PDF isAnimate:YES];
                    }
                }else {
                    ClassRoomLog(@"LiveVCTopContentView:PDF 名字未读取到 不处理");
                }
            }
        }
            break;
        case CurrentShowModelType_WHITEBOARD:
        {
            //白板
            ClassRoomLog(@"LiveVCTopContentView:状态切换==>白板");
            [self.mediaPlayerView stop];
            [self.whiteBgView switchShowWhiteBorad:cwSwitchShowModel.currentShow.page];
            [self changeViewToStyle:LiveCurrentStyle_WhiteBorad isAnimate:YES];
        }
            break;
            
        default:
            break;
    }

}

#pragma mark-
#pragma mark- 更新主窗口显示
- (void)updateMainShow:(SetMainShowModel *)mainShow
{
    if (!self.scrollView.scrollEnabled) {
        return;
    }
    
    if (MainShowType_VEDIO == mainShow.showtype) {
        //切换到视频
        [self.scrollView setContentOffset:CGPointMake(self.width, 0) animated:NO];
    }else{
      [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

#pragma mark-
#pragma mark- 添加/删除/关闭课件
- (void)addCourseWare:(AddCourseWareModel *)cwModel
{
    switch (cwModel.actiontype) {
        case AddCourseWareModelType_ADD:
        {
            //增加课件
            ClassRoomLog(@"LiveVCTopContentView:(不处理既不下载,下载课件功能放在课件列表内完成)增加课件: %@",cwModel.cwname);
//            [self addDownLoadFile:cwModel.cwname];
        }
            break;
        case AddCourseWareModelType_DEL:
        {
            //删除课件
            if ([Utils isAudioCourse:cwModel.cwname]) {
                //删除音频课件
                NSString *delImg = [[Utils getAudioCoursePath:cwModel.cwname] lastPathComponent];
                ClassRoomLog(@"LiveVCTopContentView:删除音频课件: %@",cwModel.cwname);
                if ([self.currentCWFileName isEqualToString:delImg]) {
                    ClassRoomLog(@"LiveVCTopContentView:删除正在显示音频课件");
                    [self.mediaPlayerView stop];
                    [self changeViewToStyle:LiveCurrentStyle_Video isAnimate:YES];
                }
                //移除缓存中的文件
                [FILECACHEMANAGER removeFileWithPath:[[FILECACHEMANAGER getFileRootPathWithFileType:FileType_Audio] stringByAppendingPathComponent:delImg]];
                
                
            }else if ([Utils isImgCourse:cwModel.cwname]) {
                //删除图片课件
                NSString *delImg = [[Utils getImgCoursePath:cwModel.cwname] lastPathComponent];
                ClassRoomLog(@"LiveVCTopContentView:删除图片课件: %@",cwModel.cwname);
                if ([self.currentCWFileName isEqualToString:delImg]) {
                    ClassRoomLog(@"LiveVCTopContentView:删除正在显示图片课件");
                    [self changeViewToStyle:LiveCurrentStyle_Video isAnimate:YES];
                }
                //移除缓存中的文件
                [FILECACHEMANAGER removeFileWithPath:[[FILECACHEMANAGER getFileRootPathWithFileType:FileType_Img] stringByAppendingPathComponent:delImg]];
                
            }else {
                //删除PDF 课件
                NSString *delPdf = [Utils getPdfFileName:cwModel.cwname];
                ClassRoomLog(@"LiveVCTopContentView:删除课件: %@",cwModel.cwname);
                
                if ([self.currentCWFileName isEqualToString:delPdf]) {
                    ClassRoomLog(@"LiveVCTopContentView:删除正在显示课件");
                    [self changeViewToStyle:LiveCurrentStyle_Video isAnimate:YES];
                }
                NSString *fileName = [Utils getPdfFileName:cwModel.cwname];
                [self.pdfBgView clearnDataAtDelPDFFile:fileName];
                //移除缓存中的文件
                [FILECACHEMANAGER removeFileWithPath:[[FILECACHEMANAGER getFileRootPathWithFileType:FileType_PPT] stringByAppendingPathComponent:fileName]];
            }
        }
            break;
        case AddCourseWareModelType_CLOSE:
        {
            //关闭课件
            if ([Utils isAudioCourse:cwModel.cwname]) {
                //关闭音频课件
                NSString *cloPdf = [[Utils getAudioCoursePath:cwModel.cwname] lastPathComponent];
                ClassRoomLog(@"LiveVCTopContentView:关闭音频课件: %@  cloImg:%@",cwModel.cwname,cloPdf);
                if ([self.currentCWFileName isEqualToString:cloPdf]) {
                    [self.mediaPlayerView stop];
                    [self changeViewToStyle:LiveCurrentStyle_Video isAnimate:YES];
                }
                
                
            }else if ([Utils isImgCourse:cwModel.cwname]) {
                //关闭图片课件
                NSString *cloPdf = [[Utils getImgCoursePath:cwModel.cwname] lastPathComponent];
                ClassRoomLog(@"LiveVCTopContentView:关闭图片课件: %@  cloImg:%@",cwModel.cwname,cloPdf);
                if ([self.currentCWFileName isEqualToString:cloPdf]) {
                    [self changeViewToStyle:LiveCurrentStyle_Video isAnimate:YES];
                }
                
            }else {
                //关闭pdf 课件
                NSString *cloPdf = [Utils getPdfFileName:cwModel.cwname];
                ClassRoomLog(@"LiveVCTopContentView:关闭课件: %@  cloPdf:%@",cwModel.cwname,cloPdf);
                if ([self.currentCWFileName isEqualToString:cloPdf]) {
                    [self changeViewToStyle:LiveCurrentStyle_Video isAnimate:YES];
                }
            }
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark-
#pragma mark- 更新白板操作
- (void)updateWhiteBoardAction:(WhiteBoardActionModel *)wbActionModel
{
    [self upDateWbData:wbActionModel];
}

#pragma mark-
#pragma mark- 创建白板
- (void)createWhiteBoard:(CreateWhiteBoardModel *)createWbModel
{
    switch (createWbModel.actionytype) {
        case CreateWhiteBoardModelType_ADD:
        {
            //增加白板
            [self.whiteBgView createWhiteBorad:createWbModel.wbid with:nil];
        }
            break;
        case CreateWhiteBoardModelType_DEL:
        {
            //删除白板
            [self.whiteBgView removeWhiteBoradWith:createWbModel.wbid];
            if (self.whiteBgView.subviews.count == 0) {
                [self changeViewToStyle:LiveCurrentStyle_Video isAnimate:YES];
            }
        }
            break;
        default:
            break;
    }
   
}

#pragma mark-
#pragma mark- 课程结束
- (void)classOver
{
    [self.whiteBgView cleanAllWhiteBorad];
    
    [self.clVideo clearnALL];
//    [self.video clearnALL];
//    self.video = nil;
    
    
    if (_whiteBgView) {
        [_whiteBgView removeFromSuperview];
        _whiteBgView = nil;
    }
    
    self.currentCWFileName = nil;
    [self.pdfBgView clearnAllDataAtClassOver];
    if (_pdfBgView) {
        [_pdfBgView removeFromSuperview];
        _pdfBgView = nil;
    }
    
    if (_imgView) {
        [_imgView removeFromSuperview];
        _imgView = nil;
    }
    if (_mediaPlayerView) {
        [_mediaPlayerView stop];
        [_mediaPlayerView removeFromSuperview];
        _mediaPlayerView = nil;
    }
    [self changeViewToStyle:LiveCurrentStyle_ClassOver isAnimate:NO];
}


- (void)changeViewToStyle:(LiveCurrentStyle)style isAnimate:(BOOL)animat
{
    self.currentStyle = style;
    switch (style) {
        case LiveCurrentStyle_Nomal:
        {
            self.classWaitView.hidden = NO;
            self.classOverView.hidden = YES;
            self.scrollView.hidden = YES;
        }
            break;
        case LiveCurrentStyle_Video:
        {
            self.classWaitView.hidden = YES;
            self.classOverView.hidden = YES;
            self.scrollView.hidden = NO;
            self.scrollView.scrollEnabled = NO;
            self.clVideo.hidden = NO;
            [self.scrollView setContentOffset:CGPointMake(self.width, 0) animated:animat];
        }
            break;
        case LiveCurrentStyle_WhiteBorad:
        {
            self.classWaitView.hidden = YES;
            self.classOverView.hidden = YES;
            self.scrollView.hidden = NO;
            self.whiteBgView.hidden = NO;
            self.pdfBgView.hidden = YES;
            self.imgView.hidden = YES;
            self.mediaPlayerView.hidden = YES;
            self.scrollView.scrollEnabled = YES;
            [self.mediaPlayerView stop];
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animat];
        }
            break;
        case LiveCurrentStyle_PDF:
        {
            self.classWaitView.hidden = YES;
            self.classOverView.hidden = YES;
            self.scrollView.hidden = NO;
            self.whiteBgView.hidden = YES;
            self.pdfBgView.hidden = NO;
            self.imgView.hidden = YES;
            self.mediaPlayerView.hidden = YES;
            self.scrollView.scrollEnabled = YES;
            [self.mediaPlayerView stop];
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animat];
        }
            break;
        case LiveCurrentStyle_IMG:
        {
            self.classWaitView.hidden = YES;
            self.classOverView.hidden = YES;
            self.scrollView.hidden = NO;
            self.whiteBgView.hidden = YES;
            self.pdfBgView.hidden = YES;
            self.imgView.hidden = NO;
            self.mediaPlayerView.hidden = YES;
            self.scrollView.scrollEnabled = YES;
            [self.mediaPlayerView stop];
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animat];
        }
            break;
        case LiveCurrentStyle_Audio: {
            
            self.classWaitView.hidden = YES;
            self.classOverView.hidden = YES;
            self.scrollView.hidden = NO;
            self.whiteBgView.hidden = YES;
            self.pdfBgView.hidden = YES;
            self.imgView.hidden = YES;
            self.mediaPlayerView.hidden = NO;
            self.scrollView.scrollEnabled = YES;
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animat];
            
        }
            break;
        case LiveCurrentStyle_ClassOver:
        {
            self.classWaitView.hidden = YES;
            self.classOverView.hidden = NO;
            self.scrollView.hidden = YES;
            self.whiteBgView.hidden = YES;
            self.pdfBgView.hidden = YES;
            self.imgView.hidden = YES;
            self.mediaPlayerView.hidden = YES;
            [self.mediaPlayerView stop];
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animat];
        }
            break;
            
        default:
            break;
    }

}

@end
