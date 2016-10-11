//
//  WXPayMannager.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/30.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OrderModel;
#import "WXApiObject.h"
@interface WXPayMannager : NSObject



+ (NSString *)WXJumpToPay:(OrderModel *)ordermodel;


@end
