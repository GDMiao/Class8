//
//  KL_InsertDBObj.h
//  mobileikaola
//
//  Created by chuliangliang on 15-3-2.
//  Copyright (c) 2015年 ikaola. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ChatDBObject;
@interface InsertDBManagerQueue : NSObject
+ (InsertDBManagerQueue *)shareInsertDbObj;
- (void)addData:(NSDictionary *)itemDic callBack:(void (^)(ChatDBObject *chat))block;

@end
