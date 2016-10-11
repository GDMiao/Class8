//
//  PianoHomeViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "PianoHomeViewController.h"
#import "BannerScrollView.h"
#import "PianoCourseCell.h"
#import "PianoTeacherCell.h"
@interface PianoHomeViewController ()<BannerScrollNetDelegate,BannerScrollLocalDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSArray *netBanners;
@property (strong, nonatomic) NSArray *localBanners;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSMutableArray *pCourseArray;
@property (strong, nonatomic) NSMutableArray *pTeaArray;
@property (strong, nonatomic) NSMutableArray *tableData;
@end

@implementation PianoHomeViewController

- (void)dealloc
{
    self.netBanners = nil;
    self.localBanners = nil;
}

- (NSArray *)localBanners
{
    if (!_localBanners) {
        _localBanners = @[@"banner1",@"banner2",@"banner3",@"banner4"];
    }
    return _localBanners;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleView setTitleText:@"PianoHome" withTitleStyle:CTitleStyle_Home];
//    self.allContentView.backgroundColor = [UIColor blueColor];
    // Do any additional setup after loading the view from its nib.
    /** 创建本地滚动视图*/
    [self createLocalScrollView];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.frame = self.allContentView.bounds;
    self.pTeaArray = [NSMutableArray arrayWithObjects:@"王老师",@"刘老师",@"李老师",@"金老师",@"牛老师", nil];
    self.pCourseArray = [NSMutableArray arrayWithObjects:@"指法课",@"高级课",@"入门课",@"表演课",@"欣赏课", nil];
    self.tableData  = [NSMutableArray arrayWithArray:self.pCourseArray];
    [self.tableData addObjectsFromArray:self.pTeaArray];
//    CSLog(@"%@",_tableData[5]);
    [self.tableview reloadData];

    [self showHUD:nil];
}
/**
 * 创建本地banner
 *
 **/
-(void)createLocalScrollView
{
    /** 设置本地scrollView的Frame及所需图片*/
    BannerScrollView *LocalScrollView = [[BannerScrollView alloc]initWithFrame:CGRectMake(0, 0, self.allContentView.width, self.allContentView.width /3 * 1.5) WithLocalImages:self.localBanners];
    
    /** 设置滚动延时*/
    LocalScrollView.AutoScrollDelay = 2;
    
    /** 获取本地图片的index*/
    LocalScrollView.localDelagate = self;
    
    /** 添加到当前View上*/
    if (!self.tableview.tableHeaderView) {
        self.tableview.tableHeaderView = LocalScrollView;
    }
}

/** 获取本地图片的index*/
-(void)didSelectedLocalImageAtIndex:(NSInteger)index
{
    NSLog(@"点中本地图片的下标是:%ld",(long)index);
}
#pragma mark -
#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = self.pCourseArray.count + self.pTeaArray.count;
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *pCourseIdentifier = @"pCourseCell";
    static NSString *PTeaIndentifier = @"pTeaCell";
    if (indexPath.row < self.pCourseArray.count) {
        PianoCourseCell *courseCell = [tableView dequeueReusableCellWithIdentifier:pCourseIdentifier];
        if (!courseCell) {
            UINib *nib = [UINib nibWithNibName:@"PianoCourseCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:pCourseIdentifier];
            courseCell = [tableView dequeueReusableCellWithIdentifier:pCourseIdentifier];
        }
        
        if (indexPath.row == 0) {
            [courseCell setCourseCellContent:self.tableData[indexPath.row] sectionHidden:YES];
        }else if(indexPath.row > 0 && indexPath.row < self.pCourseArray.count){
            [courseCell setCourseCellContent:self.tableData[indexPath.row] sectionHidden:NO];
        }
        CSLog(@"%@",self.tableData[indexPath.row]);
        return courseCell;
    }else{
        PianoTeacherCell *teaCell = [tableView dequeueReusableCellWithIdentifier:PTeaIndentifier];
        if (!teaCell) {
            UINib *nib = [UINib nibWithNibName:@"PianoTeacherCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:PTeaIndentifier];
            teaCell = [tableView dequeueReusableCellWithIdentifier:PTeaIndentifier];
        }
        if (indexPath.row == self.pCourseArray.count) {
            [teaCell setTeaCellContent:self.tableData[indexPath.row] sectionView:YES];
        }else if(indexPath.row > self.pCourseArray.count){
            [teaCell setTeaCellContent:self.tableData[indexPath.row] sectionView:NO];
        }
        CSLog(@"%@ %d",self.tableData[indexPath.row],indexPath.row);
        return teaCell;
    }
   
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    if (indexPath.row < self.pCourseArray.count) {
        if (indexPath.row == 0) {
            cellHeight = [[PianoCourseCell sharCourseCell]setCourseCellContent:self.tableData[indexPath.row] sectionHidden:YES];
        }else{
            cellHeight = [[PianoCourseCell sharCourseCell]setCourseCellContent:self.tableData[indexPath.row] sectionHidden:NO];
        }
    }
    else{
        if (indexPath.row == self.pCourseArray.count) {
            cellHeight = [[PianoTeacherCell sharTeacell]setTeaCellContent:self.tableData[indexPath.row] sectionView:YES];
        }else{
            cellHeight = [[PianoTeacherCell sharTeacell]setTeaCellContent:self.tableData[indexPath.row] sectionView:NO];
        }
    
    }
//    CSLog(@"%f",cellHeight);
    return cellHeight;
    
//    return 150;
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
