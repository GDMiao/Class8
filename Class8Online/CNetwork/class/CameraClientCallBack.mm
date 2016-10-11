//
//  CameraClientCallBack.m
//  Class8Online
//
//  Created by chuliangliang on 16/1/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "CameraClientCallBack.h"

@implementation CameraClientCallBack
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
CameraClientCallBack*  cameraCallBack = [[CameraClientCallBack alloc] init];

CameraClientCallBack*  GetCameraClientCallBackInst()
{
    return cameraCallBack;
}

//回调
int cameraClientCallBack(unsigned int sessionId, GNET::EVENT_VALUE event, GNET::Protocol* pData)
{
    if(cameraCallBack != nil && cameraCallBack.delegate != nil)
    {
        if ([cameraCallBack.delegate respondsToSelector:@selector(CameraClientCallBack:Event:Data:)])
        {
            [cameraCallBack.delegate CameraClientCallBack:sessionId Event:event Data:pData];
        }
    }
    return 0;
}
