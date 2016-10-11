//
//  OrderDetailViewController.h
//  Class8Online
//
//  Created by miaoguodong on 16/5/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"


//
//测试商品信息封装在Product中,外部商户可以根据自己商品实际情况定义
//
@interface Product : NSObject{
@private
    float     _price;
    NSString *_subject;
    NSString *_body;
    NSString *_orderId;
}

@property (nonatomic, assign) float price;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *orderId;

@end

@interface OrderDetailViewController : BasicViewController

@end
