//
//  MainViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/8.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "RefreshBasicViewController.h"

@interface MainViewController : RefreshBasicViewController<UITableViewDataSource,UITableViewDelegate>
- (void)updateNavBarTitle:(NSString *)title;
@end
