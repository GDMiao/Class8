//
//  HttpRequestDelegate.h
//  IShowCatena
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@protocol HttpRequestDelegate <NSObject>
/**
 * http请求成功后的回调
 */
- (void)requestFinished:(ASIHTTPRequest *) request;
/**
 * http请求失败后的回调
 */
- (void)requestFailed:(ASIHTTPRequest *) request;

@end
