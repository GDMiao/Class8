//
//  CommitModel.m
//  Class8Online
//
//  Created by miaoguodong on 16/6/29.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CommitModel.h"

@implementation CommitModel

- (void)dealloc
{
    self.courseName = nil;
    self.courseDescription = nil;
    self.orderID = nil;
    self.timeStamp = nil;
}

- (void)parse:(NSDictionary *)json
{
    NSDictionary *commitinfo = [json objectForKey:@"course"];
    
    NSDictionary *paramsdict = [json objectForKey:@"params"];
    self.orderID = [json stringForKey:@"orderid"];
    self.prepayID = [paramsdict stringForKey:@"prepayid"];
    self.noncestr = [paramsdict stringForKey:@"noncestr"];
    self.package = [paramsdict stringForKey:@"package"];
    self.appID = [paramsdict stringForKey:@"appid"];
    self.sign = [paramsdict stringForKey:@"sign"];
    self.partnerId = [paramsdict stringForKey:@"partnerid"];
    self.status = [json intForKey:@"status"];
    self.courseName = [commitinfo stringForKey:@"courseName"];
    self.courseDescription = [commitinfo stringForKey:@"description"];
    self.totalPrice = [commitinfo stringForKey:@"priceTotal"];
    self.timeStamp = [paramsdict objectForKey:@"timestamp"];
    

}

- (id)initCommitOrderInfoWithJson:(NSDictionary *)json
{
    self.code_ = 500;
    self = [self init];
    if(self && json && [json isKindOfClass:[NSDictionary class]])
    {
        self.json_ =json;
        //代码
        id code = [self.json_ objectForKeyIgnoreNull:@"status"];
        if(code)
        {
            @try {
                self.code_= [[code description] intValue];
            }
            @catch (NSException *exception) {
            }
            
        }
        //消息
        id message = [self.json_ objectForKeyIgnoreNull:@"message"];
        if (message) {
            @try {
                self.message_= [message description];
            }
            @catch (NSException *exception) {
            }
        }else {
            self.message_ = CSLocalizedString(@"json_error_unknown");
        }
        self.SysCurMills = [self.json_ doubleForKey:@"SysCurMills"];
        //数据内容
        [self parse:json];
    }

    return self;
}


@end
