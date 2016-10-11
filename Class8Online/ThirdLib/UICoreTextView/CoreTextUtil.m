//
//  CoreTextUtil.m
//  CoreTextViewDome
//
//  Created by chuliangliang on 15/6/17.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CoreTextUtil.h"
#import "RegexKitLite.h"

//颜色
#define MakeColor(r,g,b) ([UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1])

@implementation CoreTextUtil

+ (NSAttributedString *)createAttribitedString:(NSString *)contentText font:(float)f
{
    return [NSAttributedString attributedStringWithHTML:contentText textFont:[UIFont systemFontOfSize:f] textColor:MakeColor(0x25, 0x25, 0x25) linkColor:MakeColor(0x44, 0x8c, 0xe4)];
}
+ (NSAttributedString *)createAttribitedString:(NSString *)contentText font:(float)f
                                     textColor:(UIColor *)tColor linkTextColor:(UIColor *)lColor
{
    return [NSAttributedString attributedStringWithHTML:contentText textFont:[UIFont systemFontOfSize:f] textColor:tColor linkColor:lColor];
    
}


//==============================
//TODO:方法
//==============================
/**
 * 添加At
 **/
+(NSString *)addAt:(NSString *)content atUserDic:(NSDictionary *)userDic
{
    return [content stringByReplacingOccurrencesOfRegex:@"@([^\\s@]+)" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        //过滤at
        NSString *name = capturedStrings[1];
        if (name) {
            NSNumber *number = [userDic objectForKey:name];
            if (number) {
                long long uid = number.longLongValue;
                return [NSString stringWithFormat:@"<a href='%@%lld'>%@</a>",kCoreTextHrefUser,uid,capturedStrings[0]];
            }
        }
        
        return capturedStrings[0];
    }];
}

/**
 * 添加表情 size 表情尺寸
 **/
+(NSString *)addEmoji:(NSString *)content imageSize:(int)size
{
    return [content stringByReplacingOccurrencesOfRegex:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *faceName = capturedStrings[0];
        if (faceName) {
            NSString *imageName = @"坏笑.png";
            if (imageName) {
                return [NSString stringWithFormat:@"<img width='%d' height='%d' src='%@' valign='middle'/>",size,size,imageName];
            }
        }
        
        return capturedStrings[0];
    }];
}

/**
 *添加GIF 表情
 **/
+(NSString *)addGIFEmoji:(NSString *)content gifSize:(CGSize)size
{
    return [content stringByReplacingOccurrencesOfRegex:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5:*]+\\]" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *faceName = capturedStrings[0];
        if (faceName) {
            NSString *imageName = [self getGifImgName:[[faceName stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@"" ]];
            if (imageName) {
                return [NSString stringWithFormat:@"<GIF width='%f' height='%f' src='%@' valign='middle'/>",size.width,size.height,imageName];
            }
        }
        
        return capturedStrings[0];
    }];
}

//获取GIF 表情名
+ (NSString *)getGifImgName:(NSString *)string {
    NSArray *gifImg = [string componentsSeparatedByString:@":"];
    if (gifImg.count != 3) {
        return nil;
    }
    
    NSString *imgString = [NSString stringWithFormat:@"%@-%@.gif",[gifImg firstObject],[gifImg objectAtIndex:1]];
    return imgString;
}


/**
 * 添加网络图片图片
 **/
+ (NSString *)addImage:(NSString *)content  imageMaxWidth:(int)maxWidth
{
//    NSString *regex = @"\\{img:URL=[a-zA-Z0-9\\u4e00-\\u9fa5.*:*/*?*&*_*=*,*]+\\}";
        NSString *regex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5.*:*/*?*&*_*=*,*]+\\]";
    
    return [content stringByReplacingOccurrencesOfRegex:regex usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        //图片地址
        NSString *imageURL = capturedStrings[0];
//        NSString *imageUrl = [[imageURL stringByReplacingOccurrencesOfString:@"{img:URL=" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""];
        NSString *imageUrl = [[imageURL stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
        imageUrl = [NSString stringWithFormat:@"%@%@",strDownloadChatImageUrl,imageUrl];
//        ClassRoomLog(@"聊天图片: %@",imageUrl);
        //图片宽高
        int width = 92;
        int height = 80;
        CGSize oldSize = CGSizeMake(maxWidth, maxWidth);
        if (oldSize.width > 0) {
            width = oldSize.width;
        }
        if (oldSize.height > 0) {
            height = oldSize.height;
        }
        
        NSString *replaceStr = @"";
        if (imageUrl.length > 0) {
            replaceStr = [NSString stringWithFormat:@"<a href='%@%@'><u style='none'><img width='%d' height='%d' src='%@' /></u></a>",kCoreTextHrefImage,imageUrl,width,height,imageUrl];
        }
        return replaceStr;
    }];

}

/**
 * 添加用户名生成Html标签
 **/
+(NSString *)addUserLinkText:(NSString *)content uid:(long long)uid
{
    return [NSString stringWithFormat:@"<a href='%@%lld'>%@</a>",kCoreTextHrefUser,uid,content];
}
/**
 * 给文本添加颜色
 * content 需要变化的文本
 * color 颜色 (Color格式 #FF0000)
 **/
+(NSString *)addContent:(NSString *)content color:(NSString *)color
{
    return [NSString stringWithFormat:@"<span color='%@'>%@</span>",color,content];
}

/**
 * 给文本添加颜色 字体大小
 * content 需要变化的文本
 * color 颜色 (Color格式 #FF0000)
 * size 字号
 **/
+ (NSString *)addContent:(NSString *)content color:(NSString *)color fontSize:(float)size
{
     return [NSString stringWithFormat:@"<span color='%@' size=%f>%@ </span>",color,size,content];
}

/*
 * 设置换行模式 break-word : 以字母为准
 * warp : 换行方式
 * text: 源文字
 */
+ (NSString *)setTextLineBreak:(NSString *)text warpText:(NSString *)warp
{
    //<html><body><span wrap='break-word'>哈哈风哈哈hhshfahfhahfahfahfahhfahhshfahfhahfahfahfahhfa</span></body></html>
    return [NSString stringWithFormat:@"<span wrap='%@'>%@</span>",warp,text];
}

/**
 * 过滤pc发来HTML 数据源
 * 例如 取消数据头中的空格
 **/
+ (NSString *)filterContentText:(NSString *)content
{
    content = [content stringByReplacingOccurrencesOfString:HTML_BODY1_FOR_CHAT_PC withString:@""];
    return content;
}
@end
