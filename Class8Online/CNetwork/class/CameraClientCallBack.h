//
//  CameraClientCallBack.h
//  Class8Online
//
//  Created by chuliangliang on 16/1/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "gnetdef.h"
#include "gnet.h"

@protocol CameraClientCallBackDelegate <NSObject>

@optional
-(void) CameraClientCallBack:(unsigned int) sessionId  Event:(GNET::EVENT_VALUE) event Data:(GNET::Protocol*) pData;
@end


@interface CameraClientCallBack : NSObject
@property (assign) id<CameraClientCallBackDelegate> delegate;

@end

//回调
int cameraClientCallBack(unsigned int sessionId, GNET::EVENT_VALUE event, GNET::Protocol* pData);

CameraClientCallBack*  GetCameraClientCallBackInst();
