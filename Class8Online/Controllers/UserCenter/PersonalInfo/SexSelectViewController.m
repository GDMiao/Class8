//
//  SexSelectViewController.m
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "SexSelectViewController.h"
#import "NoticeSettingCell.h"

#define Sex_Item0 CSLocalizedString(@"sex_VC__female") //女
#define Sex_Item1 CSLocalizedString(@"sex_VC_male") //男
@interface SexSelectViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int chooseSex;
}
@property (strong , nonatomic) NSArray* tableViewData;
@end

@implementation SexSelectViewController

- (void)dealloc {
    self.tableViewData = nil;
    self.tableView = nil;
    self.block = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    chooseSex = 0;
    
    [self.titleView setTitleText:CSLocalizedString(@"sex_VC_nav_title") withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];

    
    self.tableViewData = [[NSArray alloc] initWithObjects:Sex_Item0,Sex_Item1, nil];
    self.tableView.frame = self.allContentView.bounds;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];

    
    int didselectCellIndex = -1;
    
    if (self.userSex == UserGender_FEMALE) {
        didselectCellIndex = 0;
    }else if (self.userSex == UserGender_MALE){
        didselectCellIndex = 1;
    }
    if (didselectCellIndex != -1) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:didselectCellIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)update
{
    
    [self showHUD:nil];
    [self resetHttp];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSNumber numberWithInt:chooseSex] forKey:@"usersex"];
    [params setValue:[NSNumber numberWithLongLong:self.uid] forKey:@"userid"];
    [http_  updateUserInfoparams:params jsonResponseDelegate:self];

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self hiddenHUD];
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"mobileupdatepersonaldata"].location != NSNotFound) {
        JSONModel *rspModel = [[JSONModel alloc] initWithJSON:[request responseJSON]];
        if (rspModel.code_ == RepStatus_Success) {
            [Utils showToast:CSLocalizedString(@"sex_VC_update_success")];
            if (self.block) {
                self.block(chooseSex);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [Utils showToast:CSLocalizedString(@"sex_VC_update_faild")];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hiddenHUD];
    [Utils showToast:CSLocalizedString(@"sex_VC_update_faild")];
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
    if ([selectCellString isEqualToString:Sex_Item0]) {
        //女
        chooseSex = 2;
        [self update];
    }else if ([selectCellString isEqualToString:Sex_Item1]) {
        //男
        chooseSex = 1;
        [self update];
    }
    
}


@end
