//
//  ZFBPayMannager.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/30.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OrderModel;
@class Order;
@interface ZFBPayMannager : NSObject

@property (strong, nonatomic) OrderModel *odermodel;

+ (ZFBPayMannager *)zfbSharSingleton;

- (void)ZFBJumpToPay:(OrderModel *)ordermodel;

@end
