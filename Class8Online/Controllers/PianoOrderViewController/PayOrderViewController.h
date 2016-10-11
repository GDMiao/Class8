//
//  PayOrderViewController.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/12.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
typedef void (^PayResultBlock) (NSString *payresult);

@interface PayOrderViewController : BasicViewController
@property (copy , nonatomic) PayResultBlock payresulBlock;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UILabel *orderNumL;
@property (weak, nonatomic) IBOutlet UIImageView *orderLine;
@property (weak, nonatomic) IBOutlet UILabel *courseNameL;
@property (weak, nonatomic) IBOutlet UILabel *coursePrice;


@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIButton *qrPaybt;
@property (strong, nonatomic) NSString *orderIdStr;
@property (strong, nonatomic) NSString *orderName;
@property (assign, nonatomic) long long classId,courseId,uid;
@property (assign, nonatomic) float priceTotal;

@property (assign, nonatomic) int payMethodCode;  /* 0 微信； 1 支付宝*/
@property (strong, nonatomic) NSString *payOrders; // 订单号
@property (strong, nonatomic) NSString *payPrices; // 订单Price
@property (strong, nonatomic) NSString *payCourseName; // 订单课程名字
+ (PayOrderViewController *)PaySharSingleton;

- (id)initCommitOderInfoWitUerID:(long long)uid courseID:(long long)coursid classId:(long long)classid;

@end
