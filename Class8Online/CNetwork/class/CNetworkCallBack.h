//
//  CNetworkCallBack.h
//  IOLIBDome
//
//  Created by chuliangliang on 15/4/22.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "gnetdef.h"
#include "gnet.h"

@protocol CNetworkCallBackDelegate <NSObject>

@optional
-(void) cNetWorkCallback:(unsigned int) sessionId  Event:(GNET::EVENT_VALUE) event Data:(GNET::Protocol*) pData;
@end


@interface CNetworkCallBack : NSObject
@property (assign) id<CNetworkCallBackDelegate> delegate;
@end


//回调
int cNetworkCallback(unsigned int sessionId, GNET::EVENT_VALUE event, GNET::Protocol* pData);

CNetworkCallBack*  GetCnetworkCallbackInst();
