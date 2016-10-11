//
//  AllCoursesViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface AllCoursesViewController : BasicViewController<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIImageView *searchBgImg;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIImageView *serchBottomLine;


- (IBAction)searchButtonAction:(UIButton *)sender;

@end
