//
//  AllTeachersViewController.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/6.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface AllTeachersViewController : BasicViewController


@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIImageView *searchBgImg;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;


- (IBAction)searchButtonAction:(UIButton *)sender;

@end
