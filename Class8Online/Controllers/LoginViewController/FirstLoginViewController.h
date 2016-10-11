//
//  FirstLoginViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/5/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "StyledPageControl.h"

@interface FirstLoginViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UIImageView *bjImg;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *registeredButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) StyledPageControl *pageControl;

@property (assign, nonatomic) BOOL isPush;

- (IBAction)loginAction:(UIButton *)sender;
- (IBAction)registeredAction:(UIButton *)sender;
@end
