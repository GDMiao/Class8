//
//  ASIHTTPRequest+JSON.h
//
//  Created by zs2 on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  @author wanglong

#import "ASIHTTPRequest.h"


@interface ASIHTTPRequest(JSON)
/*
 * 提供将返回的NSString转换为JSON方法。
 */
-(NSDictionary *) responseJSON;
-(NSArray *) responseJSONArray;
@end
