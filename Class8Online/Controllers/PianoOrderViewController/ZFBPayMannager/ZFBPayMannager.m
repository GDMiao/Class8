//
//  ZFBPayMannager.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/30.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "ZFBPayMannager.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#import "OrderModel.h"
@implementation ZFBPayMannager

- (void)dealloc
{
    self.odermodel = nil;
}


+ (ZFBPayMannager *)zfbSharSingleton
{
    static ZFBPayMannager *zfbshared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zfbshared = [[ZFBPayMannager alloc]init];
    });
    return zfbshared;
}

- (void)ZFBJumpToPay:(OrderModel *)ordermodel
{
    self.odermodel = ordermodel;
    BOOL isLogined;
    isLogined = [[AlipaySDK defaultService]isLogined];
    if (isLogined) {
        CSLog(@"支付宝本地曾登录使用过。");
        
    }else
    {
        CSLog(@"支付宝本地未曾登录使用过。");
    }
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    // 合作者身份 partner (PID): 2088221824386853
    // 安全校验码(Key)  默认加密： 4pj3q0pbfimpsi3clmgyhhsiwtzi9zpq
    // 商户收款账号 seller: piano_ali@class8.com
    // // 私钥 privateKey:
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088221824386853";
    NSString *seller = @"piano_ali@class8.com";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKPsdyZBVQwtZSLyANy74y5ywM5Ypik0PGjdAbUSVGiWyl49ZrZBDr0UOjDm4Tl/+fUaRR5pCD4+H00JdpXwqPnkChWNLR1mpYkhPrnYJxZ5tvXFlHf0IqfkrRt2Hi4hio2/zqDcS2Wrwf2l5FxKMPToKioZ58BTw4grkQT3gDa7AgMBAAECgYAqxCSJvH29wZIjPdPvwq0QjyuyKfqfwVsJWK97WB7hcoW1dHt5jRuVRNOxsmqMH9FMmt/xgSF/a6Gq7Y8cqz7KGD4Lj0w5aXHiPTvq8WMGGk85jLH77SPshfnpTJl+pWME2FoF2BrzXEqvgI2k8y4acnFiDWzgR3RsLyhf4J46cQJBANMqryPdKG+/neaP1YjvRwliGn/mFZ0vavy4raPAnUizRniH6sa8/Rtb/IUIEX9inSmPufNNcRH+PipCcCmQWe8CQQDGuggYKiAuGOuDDtVB7ERDqd9gOC6MQSjvKkBEiLKr9Vb6oke8IOhSJF41ebh37rBfpnBJ1YuXV9DDlPdtsSv1AkBy0cvHkXJySNufyWfPfGPA22ITV1U7UdQ3tGdeGdar+CcCVM044PwzSzIkV73D6SgRuD/g5qPrp7W/nr6EKyRrAkEAld4V3KNoQVtpwRyel2im0qB5ZQb5k6xQQo2KiiTNGgGb5sgbcTUf/1KN+aYiB9BqErhiVkxFSY1gUx80ufSzQQJAVU3ywg79aUIY7qingxUceGsRzCwCddLxaelh4A2k0+X5W/aDeJtRvdj+0bEBgSSRBRv5LwM+79k8glEraRbPRA=="; // rsa_private_key_pkcs8
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    /*
     MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB

     */
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
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = self.odermodel.orderID; //订单ID（由商家自行制定）
    order.subject = self.odermodel.courseName; //商品标题
    order.body = self.odermodel.courseDescription; //商品描述
    order.totalFee = self.odermodel.totalPrice; //商品价格
    order.notifyURL = @"http://piano.class8.com/alipayNofity"; //回调URL notify_url=http://www.xxx.com/notify_alipay.asp
    
    //下面的参数是固定的，不需要改变
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"PianoDLMusic";
    
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
        
        /**
         *  支付接口
         *
         *  @param orderStr       订单信息
         *  @param schemeStr      调用支付的app注册在info.plist中的scheme
         *  @param compltionBlock 支付结果回调Block
         */
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
       
        }];
    }
    
    

}








@end
