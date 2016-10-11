//
//  SubmitOrderViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/12.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "SubmitOrderViewController.h"
#import "PayOrderViewController.h"
#import "OrderModel.h"
const int totalRequestCount = 1;

@interface SubmitOrderViewController ()
{
    float price,dyprice,totalPPrice;
    BOOL isAllocData;               //是否初始化加载数据
    int didLoadRequestCount;        //已经成功返回数据的请求个数
}

@property (strong, nonatomic) OrderModel *ordermodel;
@end



@implementation SubmitOrderViewController



- (void)dealloc
{
    [self resetHttp];
    self.view1 = nil;
    self.view2 = nil;
    self.view3 = nil;
    self.view4 = nil;
    self.introduceL = nil;
    self.classTimeL = nil;
    self.priceL = nil;
    self.dyqLeft = nil;
    self.dyqRight = nil;
    self.moredyqBt = nil;
    self.zjLabel = nil;
    self.totalPrice = nil;
    self.yyhprice = nil;
    self.submitButton = nil;
    self.payresulBlock = nil;
    self.courseTime = nil;
    self.courseName = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setTitleText:@"提交订单" withTitleStyle:CTitleStyle_OnlyBack];
    self.allContentView.frame = CGRectMake(0 , 64, SCREENWIDTH, SCREENHEIGHT - 64);
//    [self updataCommitOderInfo];
    [self OrderUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)updataCommitOderInfo
{
    [self resetHttp];
    isAllocData = YES;
    didLoadRequestCount = 0;
//    [http_ getInquiryOrderInfoWithCourseid:self.coursid jsonResPonseDelegate:self];
//    [http_ getPianoCommitOrderWithUid:self.userid Courseid:self.coursid Classid:self.classid jsonResPonseDelegate:self];
    
    [self showHUD:nil];
}

#pragma mark-
#pragma mark- HttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *urlString = [[request url] absoluteString];
    if ([urlString rangeOfString:@"commitOrder"].location != NSNotFound) {
        OrderModel *order = [[OrderModel alloc]initCommitOrderInfoWithJson:[request responseJSON]];
        if (order.code_ == 0) {
            if (isAllocData) {
                didLoadRequestCount ++;
                self.ordermodel = order;
                
            }
            
        }else{
            if (isAllocData) {
                [self hiddenHUD];
            }
            [Utils showToast:@"未知错误"];
        }
    }
    
    if (isAllocData && didLoadRequestCount == totalRequestCount) {
        //初始化数据成功 刷新UI
        [self hiddenHUD];
        isAllocData = NO;
        [self OrderUI];
    }else if (didLoadRequestCount == totalRequestCount) {
        //获取下一页数据之后 刷新UI
        
    }else if (isAllocData){
        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    didLoadRequestCount = 2;
    if (didLoadRequestCount == totalRequestCount) {
        //请求出错
        [self hiddenHUD];
        [Utils showToast:@"未知错误"];
    }
}

/**
 * SubmitOrder UI
 **/
- (void)OrderUI
{
    // view1
    self.view1.left = 0;
    self.view1.top = 0;
    self.view1.width = self.allContentView.width;
    self.introduceL.text = self.courseName;
    [self.introduceL sizeToFit];
    self.introduceL.left = 12;
    self.introduceL.top = 18;
    self.introduceL.width = SCREENWIDTH - self.introduceL.left*2;
    
    self.classTimeL.text = self.courseTime;;
    [self.classTimeL sizeToFit];
    self.classTimeL.left = self.introduceL.left;
    self.classTimeL.top = self.introduceL.bottom + 16;
    
    self.priceL.text = [NSString stringWithFormat:@"￥%0.2f",self.coursePrice];
    [self.priceL sizeToFit];
    self.priceL.right = SCREENWIDTH - 15;
    self.priceL.top = self.introduceL.bottom + 15;
    price = self.coursePrice;
    if (self.view1.height > 100) {
        self.view1.height = self.priceL.bottom + 22;
    }
    
    // view2
    self.view2.left = self.view1.left;
    self.view2.top = self.view1.bottom + 12;
    self.view2.width = self.allContentView.width;
    [self.dyqLeft sizeToFit];
    self.dyqLeft.left = 12;
    self.dyqLeft.top = 19;
    
    self.moredyqBt.right = SCREENWIDTH - 15;
    self.moredyqBt.top = self.dyqLeft.top;
    [self.moredyqBt addTarget:self action:@selector(moreYouhuijuan:) forControlEvents:UIControlEventTouchUpInside];
    
    self.dyqRight.text = [NSString stringWithFormat:@"请选择抵用券"];
    [self.dyqRight sizeToFit];
    self.dyqRight.right = self.moredyqBt.left - 10;
    self.dyqRight.top = self.dyqLeft.top;
    dyprice = 0; // 暂时设定0 元
    
    // view3
    self.view3.left = self.view2.left;
    self.view3.top = self.view2.bottom + 1;
    self.view3.width = self.allContentView.width;
    [self.zjLabel sizeToFit];
    self.zjLabel.left = 12;
    self.zjLabel.top = 19;
    
    totalPPrice =price - dyprice;
    NSString *priceStr = [NSString stringWithFormat:@"￥%0.2f",totalPPrice];
    self.totalPrice.text = priceStr;
    [self.totalPrice sizeToFit];
    self.totalPrice.right = SCREENWIDTH - 15;
    self.totalPrice.top = self.zjLabel.top - 2;
    
    self.yyhprice.text = [NSString stringWithFormat:@"(已经优惠%0.2f元)",dyprice];
    [self.yyhprice sizeToFit];
    self.yyhprice.right = self.totalPrice.right;
    self.yyhprice.top = self.totalPrice.bottom;
    
    // view4
    self.view4.left = self.view3.left;
//    CSLog(@"%f",self.allContentView.bottom);
    self.view4.height = 50;
    self.view4.top = self.allContentView.height - self.view4.height;
    self.view4.width = self.allContentView.width;
    
    self.submitButton.left = 12;
    self.submitButton.top = 5;
    self.submitButton.backgroundColor = MakeColor(0x23, 0x95, 0x199);
    self.submitButton.width = self.view4.width - self.submitButton.left *2;
    self.submitButton.layer.cornerRadius = 5.f;
    self.submitButton.tag = totalPPrice;
    
}

- (IBAction)SubmitOrderAction:(UIButton *)sender {
    CSLog(@"提交订单%ld元",(long)self.submitButton.tag);
    __weak typeof(self) weakself = self;
    PayOrderViewController *payorderVC = [[PayOrderViewController alloc]initCommitOderInfoWitUerID:self.userid courseID:self.coursid classId:self.classid];
//    payorderVC.orderIdStr = self.ordermodel.orderID;
//    payorderVC.orderName = self.ordermodel.courseName;
    payorderVC.priceTotal = totalPPrice;
    payorderVC.payresulBlock = ^(NSString *payreslut){
//        CSLog(@"%@",payreslut);
        weakself.payresulBlock(payreslut);
    };

    [self.navigationController pushViewController:payorderVC animated:YES];
    
}

- (void)moreYouhuijuan:(UIButton *)button
{
    CSLog(@"更多优惠劵");
}
- (int)StringToIntValue:(NSString *)string{
    
    int value = 0;
    value = [string intValue];
    return value;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
