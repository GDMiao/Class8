//
//  CNetworkCallBack.m
//  IOLIBDome
//
//  Created by chuliangliang on 15/4/22.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CNetworkCallBack.h"

@implementation CNetworkCallBack
@synthesize delegate;

-(id)init
{
    self = [super init];
    if (self)
    {
        delegate = nil;
    }
    return self;
}


@end

/////////////////////////////////////////////////////////////////////////////////////////
CNetworkCallBack*  loginClientCallback_ = [[CNetworkCallBack alloc] init];

CNetworkCallBack*  GetCnetworkCallbackInst()
{
    return loginClientCallback_;
}

//回调
int cNetworkCallback(unsigned int sessionId, GNET::EVENT_VALUE event, GNET::Protocol* pData)
{
    if(loginClientCallback_ != nil && loginClientCallback_.delegate != nil)
    {
        if ([loginClientCallback_.delegate respondsToSelector:@selector(cNetWorkCallback:Event:Data:)])
        {
            [loginClientCallback_.delegate cNetWorkCallback:sessionId Event:event Data:pData];
        }
    }
    return 0;
}
