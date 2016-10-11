//
//  NSDictionary+JSON.h
//  IShowCatena
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//


#import <Foundation/Foundation.h>
/**
 * 扩展 NSDictionary, 为JSON提供支持方法.
 */
@interface NSDictionary(JSON)
/**
 * 忽略NSNull对象，将NSNull转化为nil。
 */
- (id)objectForKeyIgnoreNull:(id)aKey;
/**
 * 按照指定key获取String类型值
 */
-(NSString *) stringForKey:(NSString *) key;
/**
 * 按照指定key获取int类型值
 */

-(int) intForKey:(NSString *) key;

/**
 *获取网络数据接口的code码 不存在返回-1000
 **/
- (int)codeForKey:(NSString *)key;
/**
 * 按照指定key获取long类型值
 */
-(long long) longForKey:(NSString *) key;
/**
 * 按照指定key获取bool类型值
 */
-(BOOL) boolForKey:(NSString *) key;
/**
 * 按照指定key获取Array类型值
 */
-(NSArray *) arrayForKey:(NSString *) key;
/**
 * 按照指定key获取float类型值
 */
-(float) floatForKey:(NSString *)key;
/**
 * 按照指定key获取double类型值
 */
-(float) doubleForKey:(NSString *)key;
@end
