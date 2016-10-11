//
//  SubmitOrderViewController.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/12.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
typedef void (^PayResultBlock) (NSString *payresult);
@interface SubmitOrderViewController : BasicViewController
@property (assign, nonatomic) long long userid,coursid,classid;
@property (strong, nonatomic) NSString *courseTime,*courseName;
@property (assign, nonatomic) float coursePrice;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UILabel *introduceL;
@property (weak, nonatomic) IBOutlet UILabel *classTimeL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;

@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UILabel *dyqLeft;
@property (weak, nonatomic) IBOutlet UILabel *dyqRight;
@property (weak, nonatomic) IBOutlet UIButton *moredyqBt;

@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UILabel *zjLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (weak, nonatomic) IBOutlet UILabel *yyhprice;

@property (weak, nonatomic) IBOutlet UIView *view4;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (copy , nonatomic) PayResultBlock payresulBlock;


- (IBAction)SubmitOrderAction:(UIButton *)sender;









@end
