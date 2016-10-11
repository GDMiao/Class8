//
//  OrderDetailViewController.m
//  Class8Online
//
//  Created by miaoguodong on 16/5/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"

@implementation Product


@end

@interface OrderDetailViewController ()
@property (nonatomic,strong)UITextField *textField;
@property(nonatomic, strong)NSMutableArray *productList;
@end

@implementation OrderDetailViewController
#pragma mark -
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}






- (void)viewDidLoad {
    [super viewDidLoad];
    [self.titleView setTitleText:@"OrderDetail" withTitleStyle:CTitleStyle_LeftAndRight];
    
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 100, 150, 30)];
    
    [self.view addSubview:_textField];
    _textField.placeholder = @"输入支付金额";
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    payBtn.frame = CGRectMake(100, 200, 150, 30);
    payBtn.backgroundColor = [UIColor orangeColor];
    payBtn.tintColor = [UIColor whiteColor];
    [payBtn setTitle:@"支付" forState:UIControlStateNormal];
    [payBtn addTarget:self action:@selector(payMoney) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
    // Do any additional setup after loading the view from its nib.
}

-(void)payMoney{
    
    /*
     *点击获取prodcut实例并初始化订单信息
     */
    Product *product = nil;
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088221824386853";//商户ID
    NSString *seller = @"piano_ali@class8.com";//商户支付宝账号
    NSString *privateKey = @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAJ+Wf8evZEEkwq+cPldXS8b+uDvQQzCRO/U0a9Jkyyeoxehnqa4kSKpohJ5TnuvLU0iUEb86cdjm7DZoHhivDG9XADh7kIVDMTSw8uLLJTjc/Bn1yF9hB3sAkaFSf34pd6e+hh3paq98X38k13VkNsRw+Dk/R+zJ0O9McA0MdUqlAgMBAAECgYA4l/1+ifNqqqej8Sume52y1xfslkGNkqOJpGpsNTRaPx7X+RMSX2mpjOEi6JKeGf/R6DiW8Rn4ioPQE4JAzKsCrZYZpu1NEHnbjaIUD9YTP3SSULRzbd22PvdkI7KODNZy/RTlnA02AOLAVTBssQAoUiC3iNywY7o1uY9qpwr+4QJBAM+EMayaDA65bBf/35rHIHIgHbrkYOFTEOpSxig13qaP4sDGPDEp9mMy1RhLBd8aaqvi3hYvg5aR8h2B6dFbIokCQQDE36TOu2OVvgxNJeIW+ffLzfGTUlz1y5EVZsBXt4XPGgtACgb2SpeGBDyavn06niuMNmTTSTGUraQQOANTiZA9AkAYbcR3QC85MITUEnAdRWHBbZxyWt44yFGOdC4Vn7nVO80CypNdakYyCVLiqDpJuE9karGgRPmlqQqqhJek6KiZAkBmA1jbwp/UjNjE9RdVPouXMIy4ANqohqYUB90s1qzgZqdjtI5s+rPPPszEhmZPhHweOGVAUlH9r4gu20dl9wclAkAih3RO7QsOYkWt+M/ekXYvocta/vUd2fGyg3qMnJQtvNP645IzAGvCotpmTQhWzPFrz1UZPbGErIzPc11q8fbe";//商户私钥
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
       
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
//    order.subject = product.subject; //商品标题
    order.subject = @"电脑";
    order.body = @"好大一个电脑"; //商品描述
    order.totalFee = [NSString stringWithFormat:@"%@",_textField.text]; //商品价格
    order.notifyURL = @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"Class8Online";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
//        NSLog(@"my  Order String:%@",orderString);
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
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
