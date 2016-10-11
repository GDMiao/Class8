//
//  ChatImageDownUtils.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/31.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatImageDownUtils : NSObject
+ (ChatImageDownUtils *)shareChatImag;
- (BOOL)hasReLoadImagWithUrl:(NSURL *)url;
@end
