//
//  CoreTextUtil.h
//  CoreTextViewDome
//
//  Created by chuliangliang on 15/6/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextView.h"
//图片链接
#define kCoreTextHrefImage @"imageId:"
//用户链接
#define kCoreTextHrefUser @"userId:"

@interface CoreTextUtil : NSObject

+ (NSAttributedString *)createAttribitedString:(NSString *)contentText font:(float)f;

+ (NSAttributedString *)createAttribitedString:(NSString *)contentText font:(float)f
                                     textColor:(UIColor *)tColor linkTextColor:(UIColor *)lColor;


//==============================
//TODO:方法
//==============================

/**
 * 添加At
 **/
+(NSString *)addAt:(NSString *)content atUserDic:(NSDictionary *)userDic;

/**
 * 添加表情 size 表情尺寸
 **/
+(NSString *)addEmoji:(NSString *)content imageSize:(int)size;

/**
 *添加GIF 表情
 **/
+(NSString *)addGIFEmoji:(NSString *)content gifSize:(CGSize)size;

/**
 * 添加网络图片图片
 **/
+ (NSString *)addImage:(NSString *)content imageMaxWidth:(int)maxWidth;

/**
 * 添加用户名生成Html标签
 **/
+(NSString *)addUserLinkText:(NSString *)content uid:(long long)uid;

/**
 * 给文本添加颜色
 * content 需要变化的文本
 * color 颜色 (Color格式 #FF0000)
 **/
+(NSString *)addContent:(NSString *)content color:(NSString *)color;

/**
 * 给文本添加颜色 字体大小
 * content 需要变化的文本
 * color 颜色 (Color格式 #FF0000)
 * size 字号
 **/
+ (NSString *)addContent:(NSString *)content color:(NSString *)color fontSize:(float)size;

/* 
 * 设置换行模式 break-word : 以字母为准
 * warp : 换行方式
 * text: 源文字
 */
+ (NSString *)setTextLineBreak:(NSString *)text warpText:(NSString *)warp;


/**
 * 过滤pc发来HTML 数据源的style 设置
 * 例如 取消数据头中的空格
 **/
+ (NSString *)filterContentText:(NSString *)content;
@end
