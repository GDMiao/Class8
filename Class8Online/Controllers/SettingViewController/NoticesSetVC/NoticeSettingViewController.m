//
//  NoticeSettingViewController.m
//  Class8Online
//
//  Created by chuliangliang on 15/9/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "NoticeSettingViewController.h"
#import "NoticeSettingCell.h"

@interface NoticeSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *tableViewData;
@end

@implementation NoticeSettingViewController

- (void)dealloc {
    self.tableViewData = nil;
    self.tableView = nil;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleView setTitleText:CSLocalizedString(@"noticeSet_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    
    self.tableView.frame = CGRectMake(0, 0, self.allContentView.width, self.allContentView.height);
    self.tableViewData = [[NSArray alloc] initWithObjects:Items0,Items1,Items2,Items3, nil];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.tableViewData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndity = @"noticeSettingCell";
    NoticeSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndity];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"NoticeSettingCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIndity];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIndity];
    }
    [cell setContentlabelText:[self.tableViewData objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectCellString =  [self.tableViewData objectAtIndex:indexPath.row];
    CSLog(@"选中: %@",selectCellString);
    
}
@end
