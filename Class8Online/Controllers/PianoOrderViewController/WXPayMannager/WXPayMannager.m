//
//  WXPayMannager.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/30.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//
/*
 AppID：wx706efc08ccb68bc0
 AppSecret：c0434228c05c35f2f0d3d094eafe47ea重置
 */

#import "WXApi.h"
#import "WXPayMannager.h"
#import "OrderModel.h"


#define AppID @"wx706efc08ccb68bc0"
#define AppSecret @"c0434228c05c35f2f0d3d094eafe47ea"
#define PartnerId @"1355842002"
#define Package @"Sign=WXPay"


@implementation WXPayMannager


#pragma mark - WXpay Methods
+ (NSString *)WXJumpToPay:(OrderModel *)ordermodel
{
    
//    // 判断是否安装了微信
//    if(![WXApi isWXAppInstalled]){
//        CSLog(@"没有安装微信");
//        return nil;
//    }
//    else if (![WXApi isWXAppSupportApi]){
//        CSLog(@"不支持微信支付");
//        return nil;
//    }
    
    if (ordermodel != nil) {

        PayReq* req = [[PayReq alloc] init];

        req.partnerId = ordermodel.partnerId;
        req.prepayId = ordermodel.prepayID;
        req.nonceStr = ordermodel.noncestr;
        req.timeStamp = ordermodel.timeStamp.intValue;
        req.package = ordermodel.package;
        req.sign= ordermodel.sign;
        
//        [WXApi sendReq:req];
        BOOL sendRes = [WXApi sendReq:req];
        if (sendRes) {
            CSLog(@"唤起成功");
        }else {
            CSLog(@"唤起失败");
            
        }
        //日志输出
        CSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",AppID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
        return @"";
        
        
    
    }
    else{
        CSLog(@"预付订单生成失败");
        return  [NSString stringWithFormat:@"%d",ordermodel.status];
    }



}




@end
