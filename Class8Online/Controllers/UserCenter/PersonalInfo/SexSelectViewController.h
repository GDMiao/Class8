//
//  SexSelectViewController.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

typedef void (^SexSelectCallBack) (int sex);

@interface SexSelectViewController : BasicViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,copy) SexSelectCallBack block;
@property (assign, nonatomic) int userSex;
@property (assign, nonatomic) long long uid;



@end
