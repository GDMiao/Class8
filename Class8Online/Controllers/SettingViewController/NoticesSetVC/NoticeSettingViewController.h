//
//  NoticeSettingViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/9/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

#define Items0 CSLocalizedString(@"noticeSet_VC_10min")
#define Items1 CSLocalizedString(@"noticeSet_VC_30min")
#define Items2 CSLocalizedString(@"noticeSet_VC_1h")
#define Items3 CSLocalizedString(@"noticeSet_VC_close")
@interface NoticeSettingViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
