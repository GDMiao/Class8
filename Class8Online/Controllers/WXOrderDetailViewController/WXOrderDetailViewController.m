//
//  WXOrderDetailViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/5/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "WXOrderDetailViewController.h"
#import "WXApiRequestHandler.h"

@interface WXOrderDetailViewController ()<UITableViewDelegate,UITableViewDataSource>


@end

@implementation WXOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleView setTitleText:@"WXOrderPayer" withTitleStyle:CTitleStyle_LeftAndRight];
    // Do any additional setup after loading the view from its nib.


    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    payBtn.frame = CGRectMake(200, 200, 150, 30);
    payBtn.backgroundColor = [UIColor orangeColor];
    payBtn.tintColor = [UIColor whiteColor];
    [payBtn setTitle:@"微信支付" forState:UIControlStateNormal];
    [payBtn addTarget:self action:@selector(payMoney) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
}



-(void)payMoney{
    CSLog(@"开启微信支付");
    NSString *res = [WXApiRequestHandler jumpToBizPay];
    
    if( ![@"" isEqual:res] ){
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"支付失败" message:res delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alter show];
        
    }
    
    

}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
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
