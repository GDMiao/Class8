//
//  JSONParse.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/15.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONParse <NSObject>
@required
/*
 * 解析JSON对象，并将JSON对象内部数据转化为Module对象。
 * Module 子类需要实现此Protocol。
 */
-(void) parse:(NSDictionary *)json;
@end
