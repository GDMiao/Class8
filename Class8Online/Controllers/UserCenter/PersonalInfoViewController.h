//
//  PersonalInfoViewController.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/5/6.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"


@interface PersonalInfoViewController : BasicViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

- (id)initWithUser:(User *)user;
@property (nonatomic,strong) UITableView * tableView;
//@property (nonatomic,assign) long long birthday,uid;
@property (nonatomic, strong) User *user;

@end
