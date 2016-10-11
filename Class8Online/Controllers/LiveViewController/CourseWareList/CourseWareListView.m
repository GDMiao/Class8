//
//  CourseWareListView.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CourseWareListView.h"
#import "CWListCell.h"
#import "Downloader.h"


@interface CourseWareListView ()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat CWViewWidth;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) Downloader *download;
@end

@implementation CourseWareListView

- (void)dealloc {
    self.tableView = nil;
    self.tableViewData = nil;
    self.download = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame atTableViewData:(NSArray *)data
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableViewData = [[NSMutableArray alloc] init];
        self.download = [[Downloader alloc] init];
        [self.download setDownloadMaxOperationCount:3];

        for (NSString *fileName in data) {
            [self addCourseWare:fileName isRefreshTab:NO];
        }
        [self _initSubViews];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        self.tableViewData = [[NSMutableArray alloc] init];
        [self _initSubViews];
  
    }
    return self;
}

- (void)_initSubViews {
    CWViewWidth = self.width;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (IS_IOS8) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }else if (IS_IOS7) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }

    [self addSubview:self.tableView];

    

    /*
    //临时测试数据
    NSArray *arcArr = @[@"http://dlsw.baidu.com/sw-search-sp/soft/a2/25705/sinaSHOW-v1-1.1395901693.dmg",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.3_setup.1435732931.dmg",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/56/25779/Skype_6.14.99.351.1395978010.dmg",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/40/12856/QIYImedia_1_06_v4.0.0.32.1437470004.exe",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/70/17456/BaiduAn_Setup_5.0.0.6748_50043.1437563719.exe",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/44/17448/Baidusd_Setup_4.2.0.7666.1437615396.exe",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/0b/11390/AliIM2014_taobao_8.00.71C.1433754301.exe",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/a8/12690/AliIM2013_2.0.0.1.4752206.exe",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/23/15192/CC_Setup_3.16.2_10155_gfxz.1425897973.exe",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/fe/11383/FetionNew2015May_V5.6.2800.0_setup.1431067010.exe"
                        ];
    
    
    for (NSString *file in arcArr) {
        [self addCourseWare:file isRefreshTab:NO];
    }
    */
    
    [self reloadTableViewData];
    
    //监听下载状态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(courseWareStartDownload:) name:KNotification_DownLoadFIleDidStart object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(courseWareDownloading:) name:KNotification_DownLoading object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(courseWareDownloadFail:) name:KNotification_DownLoadFileDidFaild object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(courseWareDownloadFinish:) name:KNotification_DownLoadFIleDidFinish object:nil];

}

/**
 *添加课件
 **/
- (void)addCourseWare:(NSString *)text isRefreshTab:(BOOL)reload
{
   /*
    //临时测试
    CWModel *cwModelTest = [[CWModel alloc] init];
    cwModelTest.cwOrigPath = cwModelTest.cwURLSubPath = text;
    cwModelTest.cwName = [text lastPathComponent];
    cwModelTest.cwStyle = CWStyle_Audio;
    cwModelTest.loadState = CWLoadState_Wait;
    cwModelTest.progress = 0.0;
    [self.tableViewData addObject:cwModelTest];
    
    if ([self.download fileExisted:[cwModelTest.cwURLSubPath lastPathComponent] fileType:FileType_Default]) {
        cwModelTest.loadState = CWLoadState_Done;
    }else{
        cwModelTest.loadState = CWLoadState_Wait;
        [self.download addDownloaderFileUrl:cwModelTest.cwURLSubPath fileType:FileType_Default byUser:YES delegate:nil];
    }
    


    
    return;
    */
    
    CWModel *cwModel = [[CWModel alloc] init];
    cwModel.cwOrigPath = text;
    cwModel.cwName = [Utils getCourseWareName:text];
    if ([Utils isAudioCourse:text]) {
        //音频课件
        cwModel.cwURLSubPath = [Utils getMediaURLSubPath:text];
        cwModel.cwStyle = CWStyle_Audio;
        
        if ([self.download fileExisted:[cwModel.cwURLSubPath lastPathComponent] fileType:FileType_Audio]) {
            cwModel.loadState = CWLoadState_Done;
        }else{
            cwModel.loadState = CWLoadState_Wait;
            [self.download addDownloaderFileUrl:[NSString stringWithFormat:@"%@%@",PDFDownloadUrl,cwModel.cwURLSubPath] fileType:FileType_Audio byUser:YES delegate:nil];
        }

    }else if ([Utils isVideoCourseWare:text]) {
        //媒体课件 <视频/音频>
        cwModel.cwURLSubPath = [Utils getMediaURLSubPath:text];
        cwModel.cwStyle = CWStyle_Video;

        if ([self.download fileExisted:[cwModel.cwURLSubPath lastPathComponent] fileType:FileType_video]) {
            cwModel.loadState = CWLoadState_Done;
        }else{
            cwModel.loadState = CWLoadState_Wait;
            [self.download addDownloaderFileUrl:[NSString stringWithFormat:@"%@%@",PDFDownloadUrl,cwModel.cwURLSubPath] fileType:FileType_video byUser:YES delegate:nil];
        }

    }else if ([Utils isImgCourse:text]) {
        //图片课件
        cwModel.cwURLSubPath = [Utils getImgCoursePath:text];
        cwModel.cwStyle = CWStyle_IMG;
        
        if ([self.download fileExisted:[cwModel.cwURLSubPath lastPathComponent] fileType:FileType_Img]) {
            cwModel.loadState = CWLoadState_Done;
        }else{
            cwModel.loadState = CWLoadState_Wait;
            [self.download addDownloaderFileUrl:[NSString stringWithFormat:@"%@%@",PDFDownloadUrl,cwModel.cwURLSubPath] fileType:FileType_Img byUser:YES delegate:nil];
        }

    }else {
        //PDF 课件
       NSString *pdfURLPath = [Utils getPDFDownLoadPath:text];
        if (!pdfURLPath || pdfURLPath.length <= 0) {
            return;
        }
        cwModel.cwURLSubPath = [Utils getPDFDownLoadPath:text];
        cwModel.cwStyle = CWStyle_PDF;
        if ([self.download fileExisted:[cwModel.cwURLSubPath lastPathComponent] fileType:FileType_PPT]) {
            cwModel.loadState = CWLoadState_Done;
        }else{
            cwModel.loadState = CWLoadState_Wait;
            [self.download addDownloaderFileUrl:[NSString stringWithFormat:@"%@%@",PDFDownloadUrl,cwModel.cwURLSubPath] fileType:FileType_PPT byUser:YES delegate:nil];
        }

    }

    cwModel.progress = 0.0;
    
    [self.tableViewData addObject:cwModel];
    if (reload) {
        [self reloadTableViewData];
    }
}

/**
 * 刷新单元格
 **/
- (void)reloadTableViewData
{
    if (self.tableViewData.count > 0) {
        self.tableView.tableFooterView = nil;
    }else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,CWViewWidth, 20)];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = CSLocalizedString(@"live_VC_courseWareList_no");
        self.tableView.tableFooterView = label;
    }
    [self.tableView reloadData];
}

/**
 *删除课件
 **/
- (void)delCourseWare:(NSString *)text
{
    BOOL isHas = NO;
    for (CWModel *cModel in self.tableViewData) {
        if ([cModel.cwOrigPath rangeOfString:text].location != NSNotFound) {
            [self.tableViewData removeObject:cModel];
            isHas = YES;
            break;
        }
    }
    if (isHas) {
        
        [self reloadTableViewData];
    }
    ClassRoomLog(@"CourseWareListView: 课件列表删除课件 ==> %@",isHas?@"成功":@"失败");
}

#pragma mark-
#pragma mark- 添加/删除/关闭课件 这里这负责列表数据同步 关闭课件不在这里处理
- (void)updateCourseWare:(AddCourseWareModel *)cwModel
{
    switch (cwModel.actiontype) {
        case AddCourseWareModelType_ADD:
        {
            //增加课件
            ClassRoomLog(@"CourseWareListView: 增加课件: %@",cwModel.cwname);
            [self addCourseWare:cwModel.cwname isRefreshTab:YES];
        }
            break;
        case AddCourseWareModelType_DEL:
        {
            //删除课件
            [self delCourseWare:cwModel.cwname];
        }
            break;
        case AddCourseWareModelType_CLOSE:
        {
            //关闭课件
            ClassRoomLog(@"CourseWareListView: 关闭课件 => 在线课堂课件列表页不处理");
        }
            break;
            
        default:
            break;
    }

}

#pragma mark-
#pragma mark- 下课清缓存
- (void)classOver
{
    [self.download cancelAllRequest];
    [self.tableViewData removeAllObjects];
    [self reloadTableViewData];;
}


#pragma mark-
#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[CWListCell shareCWListCell] cellHeight:[self.tableViewData objectAtIndex:indexPath.row]];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewData.count;
}

#define CWCELL_ICON 2001
#define CWCELL_TITLE 2002
#define CWCELL_RIGHTBTN 2003
#define CWCELL_LOADING 2004

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *chatCellIdn = @"CWListCell";
    CWListCell *cell = [tableView dequeueReusableCellWithIdentifier:chatCellIdn];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"CWListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:chatCellIdn];
        cell = [tableView dequeueReusableCellWithIdentifier:chatCellIdn];
    }
    [cell.cwRightBtn addTarget:self action:@selector(courseWareRightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.cwRightBtn.tag = indexPath.row;
    
    cell.contentWidth = CWViewWidth;
    CWModel *cwModel = [self.tableViewData objectAtIndex:indexPath.row];
    [cell setCourseWare:cwModel];
    return cell;
}

#pragma mark- 
#pragma mark- 列表右侧按钮点击事件
- (void)courseWareRightButtonAction:(UIButton *)button {
    CWModel *cwModel = [self.tableViewData objectAtIndex:button.tag];
    cwModel.loadState = CWLoadState_Wait;
    FileType fType = FileType_Default;
    switch (cwModel.cwStyle) {
        case CWStyle_PDF:
        {
            fType = FileType_PPT;
        }
         break;
        case CWStyle_IMG:
        {
            fType = FileType_Img;
        }
            break;
        case CWStyle_Audio:
        {
            fType = FileType_Audio;
        }
            break;
        case CWStyle_Video:
        {
            fType = FileType_video;
        }
            break;
        default:
            break;
    }
    ClassRoomLog(@"CourseWareListView: 重新下载:%@",cwModel.cwURLSubPath);
    [self.download addDownloaderFileUrl:[NSString stringWithFormat:@"%@%@",PDFDownloadUrl,cwModel.cwURLSubPath] fileType:fType byUser:YES delegate:nil];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark- 
#pragma mark - download  Notifications
- (void)courseWareStartDownload:(NSNotification *)notification {
    BOOL isHas = NO;
    NSDictionary *userInfo = (NSDictionary *)[notification object];
    NSString *cwName = [userInfo stringForKey:DOWNLOADERFILENAME];

    NSUInteger index = 0;
    for (CWModel *cModel in self.tableViewData) {
        if ([cModel.cwURLSubPath rangeOfString:cwName].location != NSNotFound) {
            cModel.progress = 0.0;
            cModel.loadState = CWLoadState_Loading;
            index = [self.tableViewData indexOfObject:cModel];
            isHas = YES;
            break;
        }
    }
    
    if (isHas) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)courseWareDownloading:(NSNotification *)notification {
    
    BOOL isHas = NO;
    NSDictionary *downloadDic = (NSDictionary *)[notification object];
    NSString *cwName = [downloadDic stringForKey:DOWNLOADERFILENAME];
    CGFloat progress = [downloadDic floatForKey:DOWNLOADPROGRESS];
    NSUInteger index = 0;
    CGFloat oldProgress = 0.0;
    for (CWModel *cModel in self.tableViewData) {
        if ([cModel.cwURLSubPath rangeOfString:cwName].location != NSNotFound) {
            cModel.progress = MAX(cModel.progress, progress);
            oldProgress = cModel.progress;
            cModel.loadState = CWLoadState_Loading;
            index = [self.tableViewData indexOfObject:cModel];
            isHas = YES;
            break;
        }
    }
    if (isHas) {
        CWListCell *cell = (CWListCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if (cell) {
            NSString *downloadProgressString = [NSString stringWithFormat:@"%.1f%%",oldProgress * 100];
            [cell.cwRightBtn setTitle:downloadProgressString forState:UIControlStateNormal];
        }
    }
}

- (void)courseWareDownloadFail:(NSNotification *)notification {
    
    BOOL isHas = NO;
    NSDictionary *userInfo = (NSDictionary *)[notification object];
    NSString *cwName = [userInfo stringForKey:DOWNLOADERFILENAME];
    NSUInteger index = 0;
    for (CWModel *cModel in self.tableViewData) {
        if ([cModel.cwURLSubPath rangeOfString:cwName].location != NSNotFound) {
            cModel.progress = 0.0;
            cModel.loadState = CWLoadState_Fail;
            isHas = YES;
            index = [self.tableViewData indexOfObject:cModel];
            break;
        }
    }
    
    if (isHas) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }

}
- (void)courseWareDownloadFinish:(NSNotification *)notification {
    
    BOOL isHas = NO;
    NSDictionary *userInfo = (NSDictionary *)[notification object];
    NSString *cwName = [userInfo stringForKey:DOWNLOADERFILENAME];
    NSUInteger index = 0;
    for (CWModel *cModel in self.tableViewData) {
        if ([cModel.cwURLSubPath rangeOfString:cwName].location != NSNotFound) {
            cModel.progress = 0.0;
            cModel.loadState = CWLoadState_Done;
            isHas = YES;
            index = [self.tableViewData indexOfObject:cModel];
            break;
        }
    }
    
    if (isHas) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}



@end
