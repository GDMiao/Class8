//
//  SettingViewController.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface SettingViewController : BasicViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic,retain) UITableView * settingTable;
@property (nonatomic,retain) NSString * nameStr;
- (void)updateUserInfo; /*外部调用用来更新数据*/
@end
