//
//  ASIHTTPRequest+JSON.m
//
//  Created by zs2 on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  @author wanglong

#import "ASIHTTPRequest+JSON.h"

@implementation ASIHTTPRequest(JSON)
-(NSDictionary *) responseJSON
{
    if (![self responseData]) {
        return nil;
    }
    id js = [NSJSONSerialization JSONObjectWithData:[self responseData] options:NSJSONReadingMutableLeaves error:nil];
    if (!js) {
        js = @{};
    }
    return js;
    
//    NSString *requestStr = [self responseString];
//    return [requestStr JSONValue];
}

-(NSArray *) responseJSONArray
{
    NSString *requestStr = [self responseString];
    requestStr = [requestStr stringByReplacingOccurrencesOfString:@"(" withString:@""];
    requestStr = [requestStr stringByReplacingOccurrencesOfString:@")" withString:@""];
    return (NSArray *)[requestStr JSONValue];
}
@end
