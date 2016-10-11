//
//  OrderModel.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/29.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

@interface OrderModel : JSONModel

@property (strong, nonatomic) NSString *courseName,    // 订单课程名字
*courseDescription,                                    // 订单课程描述
*startTime,                                            // 课程开始时间
*orderID,                                              // 订单号
*prepayID,                                             // prepayid
*noncestr,                                             // noncestr
*sign,                                                 // sign
*package,                                              // package
*partnerId,                                            // partnerId
*appID,                                                // appid
*totalPrice;                                           // 课程总价格

//@property (assign, nonatomic) float totalPrice;
@property (assign, nonatomic) int classTotal;          //课程数量
@property (assign, nonatomic) int status;              // 返回状态
@property (strong, nonatomic) NSMutableString *timeStamp;

- (id)initCommitOrderInfoWithJson:(NSDictionary *)json;

@end
