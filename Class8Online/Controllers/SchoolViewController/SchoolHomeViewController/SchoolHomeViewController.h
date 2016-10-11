//
//  SchoolHomeViewController.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/14.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface SchoolHomeViewController : BasicViewController

@property (weak, nonatomic) IBOutlet UIView *navContentView;

@property (weak, nonatomic) IBOutlet UIImageView *navBjImg;
@property (weak, nonatomic) IBOutlet UILabel *navTitleL;

- (void)beginLoadData;

@end
