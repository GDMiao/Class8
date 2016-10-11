//
//  CustomMethod.m
//  MessageList
//
//  Created by 刘超 on 13-11-13.
//  Copyright (c) 2013年 刘超. All rights reserved.
//

#import "CustomMethod.h"
#import "UIImage+GIF.h"
#import "UIImageView+WebCache.h"


@implementation CustomMethod
+(CustomMethod *)shareCustomMethod
{
    static CustomMethod *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        NSBundle *bundle = [ NSBundle mainBundle ];
        
        NSString *filePath = [ bundle pathForResource:@"emojiDic" ofType:@"plist" ];
        sharedInstance.emojiDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        NSString *filePath2 = [ bundle pathForResource:@"emojiKeyArray" ofType:@"plist" ];
        sharedInstance.emojiKeys = [NSArray arrayWithContentsOfFile:filePath2];
    });
    return sharedInstance;
}
-(void)dealloc
{
    self.emojiDic = nil;
    [super dealloc];
}
+ (NSString *)escapedString:(NSString *)oldString
{
    NSString *escapedString_lt = [oldString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt"];
    NSString *escapedString = [escapedString_lt stringByReplacingOccurrencesOfString:@">" withString:@"&gt"];
    return escapedString;
}


+ (void)drawImage:(OHAttributedLabel *)label isGifAnimate:(BOOL)aimate
{
    [label.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //
        if ([obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    for (NSArray *info in label.imageInfoArr) {
//        NSLog(@"%@",info);
        //[info objectAtIndex:0]   @"发招.gif"
        //添加表情
        NSString *imgString = [info objectAtIndex:0];
        NSString *gifImgName = [self getGifImgName:imgString];
        NSString *imgSubUrl = [self getimgUrl:imgString];
        if ([Utils objectIsNotNull:gifImgName]) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:gifImgName ofType:nil];
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            SCGIFImageView *imageView = [[SCGIFImageView alloc] initWithGIFData:data];
            CGRect tmpFrame = CGRectFromString([info objectAtIndex:2]);
            imageView.start = aimate;
            imageView.frame  = tmpFrame;
            [label addSubview:imageView];
            [imageView release];
        }else if ([Utils objectIsNotNull:imgSubUrl]){
            CGRect tmpFrame = CGRectFromString([info objectAtIndex:2]);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:tmpFrame];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",strDownloadChatImageUrl,imgSubUrl]] placeholderImage:nil];
            [label addSubview:imageView];//label内添加图片层
            [label bringSubviewToFront:imageView];
            [imageView release];
        }

    }
}
+ (void)rangeOfString:(NSString *)str array:(NSMutableArray *)ary text:(NSString *)text
{
    NSString *atStr = [NSString stringWithFormat:@"@%@",str];
    NSRange range = [text rangeOfString:atStr];
    if (range.location != NSNotFound) {
        NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
        for (int i=0; i<range.length; i++) {
            [spaceStr appendString:@" "];
        }
        text = [text stringByReplacingCharactersInRange:range withString:spaceStr];
        [ary addObject:atStr];
        [CustomMethod rangeOfString:str array:ary text:text];
    }
}
#pragma mark - 正则匹配@user
+ (NSMutableArray *)addAtUserArr:(NSString *)text atUsers:(NSArray *)atUsers toUser:(NSString *)toUser
{
    //匹配@user
    NSMutableArray *atArr = [NSMutableArray arrayWithCapacity:0];
    if (toUser && toUser.length > 0) {
        [atArr addObject:[NSString stringWithFormat:@"@%@", toUser]];
    }
    for (int i = 0; i < atUsers.count; i++) {
        id obj = [atUsers objectAtIndex:i];
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *name = [atUsers objectAtIndex:i];
            if (name && name.length > 0) {
                [CustomMethod rangeOfString:name array:atArr text:text];
            }
        }
//        else if ([obj isKindOfClass:[KL_ClubUser class]]) {
//            KL_ClubUser *user = [atUsers objectAtIndex:i];
//            if (user && user.uid > 0) {
//                [CustomMethod rangeOfString:user.name array:atArr text:text];
//            }
//        }
        
        i++;
    }
    
    return atArr;
}
//#pragma mark - Club正则匹配@user
//+ (NSMutableArray *)clubAddAtUserArr:(NSString *)text atUsers:(NSArray *)atUsers toUser:(NSString *)toUser
//{
//    //匹配@user
//    NSMutableArray *atArr = [NSMutableArray arrayWithCapacity:0];
//    if (toUser && toUser.length > 0) {
//        [atArr addObject:[NSString stringWithFormat:@"@%@",toUser]];
//    }
//    NSMutableArray *usersAnonyMous = [[NSMutableArray alloc] init];
//    for (int i = 0; i < atUsers.count; i++) {
//        KL_ClubUser *cUser =[atUsers objectAtIndex:i];
//        if (cUser.anonymous) {
//            [usersAnonyMous addObject:[NSString stringWithFormat:@"%@",cUser.name]];
//            continue;
//        }
//        NSString *name = cUser.name;
//        if (name && name.length > 0) {
//           [CustomMethod clubRangeOfString:name array:atArr text:text ];
//        }
//    }
//    for (NSString *tmpUser in usersAnonyMous) {
//        tmpUser = [NSString stringWithFormat:@"@%@",tmpUser];
//        for (int i = 0; i < atArr.count; i ++) {
//            NSString *tuser = [atArr objectAtIndex:i];
//            if ([tmpUser isEqualToString:tuser]) {
//                [atArr removeObjectAtIndex:i];
//                break;
//            }
//        }
//    }
//    return atArr;
//}
+ (void )clubRangeOfString:(NSString *)str array:(NSMutableArray *)ary text:(NSString *)text
{
    NSString *atStr = [NSString stringWithFormat:@"@%@",str];
    NSRange range = [text rangeOfString:atStr];
    if (range.location != NSNotFound) {
        NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
        for (int i=0; i<range.length; i++) {
            [spaceStr appendString:@" "];
        }
        text = [text stringByReplacingCharactersInRange:range withString:spaceStr];
        [ary addObject:atStr];
        [CustomMethod clubRangeOfString:str array:ary text:text];
    }
}


+ (NSMutableArray *)addAtUserArr:(NSString *)text
{
    //匹配@user
    NSString *regex_http = @"(@[a-zA-Z0-9\\u4e00-\\u9fa5]+)";
    NSArray *array_http = [text componentsMatchedByRegex:regex_http];
    NSMutableArray *atArr = [NSMutableArray arrayWithArray:array_http];
    return atArr;
}
#pragma mark - 正则匹配电话号码，网址链接，Email地址
+ (NSMutableArray *)addHttpArr:(NSString *)text
{
    //匹配网址链接
    NSString *regex_http = @"(https?|ftp|file)+://[^\\s]*";
    NSArray *array_http = [text componentsMatchedByRegex:regex_http];
    NSMutableArray *httpArr = [NSMutableArray arrayWithArray:array_http];
    return httpArr;
}

+ (NSMutableArray *)addPhoneNumArr:(NSString *)text
{
    //匹配电话号码
    NSString *regex_phonenum = @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}";
    NSArray *array_phonenum = [text componentsMatchedByRegex:regex_phonenum];
    NSMutableArray *phoneNumArr = [NSMutableArray arrayWithArray:array_phonenum];
    return phoneNumArr;
}

+ (NSMutableArray *)addEmailArr:(NSString *)text
{
    //匹配Email地址
    NSString *regex_email = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*.\\w+([-.]\\w+)*";
    NSArray *array_email = [text componentsMatchedByRegex:regex_email];
    NSMutableArray *emailArr = [NSMutableArray arrayWithArray:array_email];
    return emailArr;
}
+ (NSString *)transformString:(NSString *)originalStr emojiDic:(NSDictionary *)_emojiDic imageSize:(float)width
{
    return [self transformString:originalStr emojiDic:_emojiDic imageSize:width ignoreTexts:nil];
}
+(BOOL)containEmoji:(NSRange)emojiRange origStr:(NSString *)origStr ignoreTexts:(NSArray *)ignoreTexts
{
    if (ignoreTexts && ignoreTexts.count > 0) {
        NSString *string = origStr;
        for (NSString *atStr in ignoreTexts) {
            NSRange igrange = [string rangeOfString:atStr];
            if (igrange.location != NSNotFound) {
                NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
                for (int i=0; i<igrange.length; i++) {
                    [spaceStr appendString:@" "];
                }
                string = [string stringByReplacingCharactersInRange:igrange withString:spaceStr];
                if (NSLocationInRange(emojiRange.location, igrange)) {
                    return YES;
                }
            }
            
        }
    }
    return NO;
}
+ (NSString *)subQuestionCellStr:(NSString *)originalStr
{
    NSString *text = originalStr;
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = [text componentsMatchedByRegex:regex_emoji];
    NSMutableArray *randAry = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *randKeyAry = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i<array_emoji.count; i++) {
        NSString *str = [array_emoji objectAtIndex:i];
        NSRange range = [text rangeOfString:str];
        
        NSString *i_transCharacter = [[CustomMethod shareCustomMethod].emojiDic objectForKey:str];
        if (i_transCharacter) {
            if (range.location > 80) {
                break;
            }
            text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:@" "];
            
            [randAry addObject:str];
            [randKeyAry addObject:NSStringFromRange(range)];
        }
    }
    
    if (text.length > 80) {
        text = [text stringByReplacingCharactersInRange:NSMakeRange(80, text.length-80) withString:@"..."];
    }
    for (int i = randAry.count-1; i >= 0; i--) {
        NSString *str = [randAry objectAtIndex:i];
        NSString *rangStr = [randKeyAry objectAtIndex:i];
        NSRange rang = NSRangeFromString(rangStr);
        if (rang.location < 80) {
            text = [text stringByReplacingCharactersInRange:NSMakeRange(rang.location, 1) withString:str];
        }
        
    }
    return text;
}
+ (NSString *)transformString:(NSString *)originalStr emojiDic:(NSDictionary *)_emojiDic imageSize:(float)width ignoreTexts:(NSArray *)ignoreTexts
{

#warning 匹配表情...
    if (!_emojiDic) {
        _emojiDic = [CustomMethod shareCustomMethod].emojiDic;
    }
    NSString *text = originalStr;
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = [text componentsMatchedByRegex:regex_emoji];
    NSMutableDictionary *dicIgnors = [NSMutableDictionary dictionaryWithCapacity:1];//要忽略的字符串
    if ([array_emoji count]) {
        for (NSString *str in array_emoji) {
            NSRange range = [text rangeOfString:str];
            
//            NSString *i_transCharacter = [_emojiDic objectForKey:str];
            NSString *i_transCharacter = str;

            if (i_transCharacter) {
                BOOL containEmoji = NO;
                if (ignoreTexts && ignoreTexts.count>0) {
                    containEmoji = [self containEmoji:range origStr:text ignoreTexts:ignoreTexts];
                    if (containEmoji) {
                        if (range.location != NSNotFound) {
                            NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
                            for (int i=0; i<range.length; i++) {
                                [spaceStr appendString:@" "];
                            }
                            text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:spaceStr];
                            [dicIgnors setValue:str forKey:NSStringFromRange(range)];
                            continue;
                        }
                    }
                }
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>",i_transCharacter,width,width];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
                
            }
        }
    }
    //返回转义后的字符串
    NSArray *allkey = [dicIgnors allKeys];
    for (NSString *key in allkey) {
        NSString *value = [dicIgnors objectForKey:key];
        text = [text stringByReplacingCharactersInRange:NSRangeFromString(key) withString:value];
    }
    
    return text;
}
+ (NSString *)transformString:(NSString *)originalStr emojiDic:(NSDictionary *)_emojiDic
{
    //匹配表情，将表情转化为html格式
    return [self transformString:originalStr emojiDic:_emojiDic imageSize:24];
}
+ (NSString *)transformString:(NSString *)originalStr
{
    //匹配表情，将表情转化为html格式
    return [self transformString:originalStr emojiDic:nil imageSize:90];
}
+ (NSString *)transformString:(NSString *)originalStr ignoreTexts:(NSArray *)ignoreTexts
{
    return [self transformString:originalStr emojiDic:nil imageSize:24 ignoreTexts:ignoreTexts];
}
+ (NSString *)transformString:(NSString *)originalStr imageSize:(float)imageSize ignoreTexts:(NSArray *)ignoreTexts
{
    return [self transformString:originalStr emojiDic:nil imageSize:imageSize ignoreTexts:ignoreTexts];
}

/*
 * 拓展 club 标题匹配表情 和 置顶/加精 图片
 */
+ (NSString *)transformStringWithClubPostsTitle:(NSString *)originalStr imageSize:(float)imageSize isTop:(BOOL)top isEssential:(BOOL)essential
{
    return  [self transformStringPostsTitle:originalStr emojiDic:nil imageSize:imageSize ignoreTexts:nil isTop:top
                                isEssential:essential isNewPost:NO];
}
/*
 * 拓展 club 标题匹配表情 和 置顶/加精 图片 和 是否新帖 add for 2.3
 */
+ (NSString *)transformStringWithClubPostsTitle:(NSString *)originalStr imageSize:(float)imageSize isTop:(BOOL)top isEssential:(BOOL)essential isNewPost:(BOOL)isNew
{
    return  [self transformStringPostsTitle:originalStr emojiDic:nil imageSize:imageSize ignoreTexts:nil isTop:top
                                isEssential:essential isNewPost:isNew];

}

// 除了匹配 表情外 增加匹配 置顶/ 加精 只有club主贴 会使用
+ (NSString *)transformStringPostsTitle:(NSString *)originalStr emojiDic:(NSDictionary *)_emojiDic imageSize:(float)width ignoreTexts:(NSArray *)ignoreTexts isTop:(BOOL)top isEssential:(BOOL)essential isNewPost:(BOOL)isNew
{
    if (!_emojiDic) {
        _emojiDic = [CustomMethod shareCustomMethod].emojiDic;
    }
    NSString *text = originalStr;
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = [text componentsMatchedByRegex:regex_emoji];
    NSMutableDictionary *dicIgnors = [NSMutableDictionary dictionaryWithCapacity:1];//要忽略的字符串
    if ([array_emoji count]) {
        for (NSString *str in array_emoji) {
            NSRange range = [text rangeOfString:str];
            
            NSString *i_transCharacter = [_emojiDic objectForKey:str];
            if (i_transCharacter) {
                BOOL containEmoji = NO;
                if (ignoreTexts && ignoreTexts.count>0) {
                    containEmoji = [self containEmoji:range origStr:text ignoreTexts:ignoreTexts];
                    if (containEmoji) {
                        if (range.location != NSNotFound) {
                            NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
                            for (int i=0; i<range.length; i++) {
                                [spaceStr appendString:@" "];
                            }
                            text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:spaceStr];
                            [dicIgnors setValue:str forKey:NSStringFromRange(range)];
                            continue;
                        }
                    }
                }
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>",i_transCharacter,width,width];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
                
            }else if ([str isEqualToString:@"[置顶]"] && top) {
                top = NO;
                //匹配置顶
                BOOL containEmoji = NO;
                if (ignoreTexts && ignoreTexts.count>0) {
                    containEmoji = [self containEmoji:range origStr:text ignoreTexts:ignoreTexts];
                    if (containEmoji) {
                        if (range.location != NSNotFound) {
                            NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
                            for (int i=0; i<range.length; i++) {
                                [spaceStr appendString:@" "];
                            }
                            text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:spaceStr];
                            [dicIgnors setValue:str forKey:NSStringFromRange(range)];
                            continue;
                        }
                    }
                }
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>",@"club置顶",30.0,18.0];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
            }else if ([str isEqualToString:@"[加精]"] && essential) {
                essential = NO;
                //匹配加精
                BOOL containEmoji = NO;
                if (ignoreTexts && ignoreTexts.count>0) {
                    containEmoji = [self containEmoji:range origStr:text ignoreTexts:ignoreTexts];
                    if (containEmoji) {
                        if (range.location != NSNotFound) {
                            NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
                            for (int i=0; i<range.length; i++) {
                                [spaceStr appendString:@" "];
                            }
                            text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:spaceStr];
                            [dicIgnors setValue:str forKey:NSStringFromRange(range)];
                            continue;
                        }
                    }
                }
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>",@"club精",18.0,18.0];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];

            }else if([str isEqualToString:@"[新]"] && isNew) {
                isNew = NO;
                //匹配新帖标识
                BOOL containEmoji = NO;
                if (ignoreTexts && ignoreTexts.count>0) {
                    containEmoji = [self containEmoji:range origStr:text ignoreTexts:ignoreTexts];
                    if (containEmoji) {
                        if (range.location != NSNotFound) {
                            NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
                            for (int i=0; i<range.length; i++) {
                                [spaceStr appendString:@" "];
                            }
                            text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:spaceStr];
                            [dicIgnors setValue:str forKey:NSStringFromRange(range)];
                            continue;
                        }
                    }
                }
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>",@"club-home新贴",18.0,18.0];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
            }
        }
    }
    //返回转义后的字符串
    NSArray *allkey = [dicIgnors allKeys];
    for (NSString *key in allkey) {
        NSString *value = [dicIgnors objectForKey:key];
        text = [text stringByReplacingCharactersInRange:NSRangeFromString(key) withString:value];
    }
    
    return text;
}


//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

//TODO: 在线课堂..匹配表情
+ (NSString *)class_8transformString:(NSString *)originalStr
{
    return [self class_8transformString:originalStr imageSize:40 ignoreTexts:nil];
}
//在线课堂..匹配表情
+ (NSString *)class_8transformString:(NSString *)originalStr  imageSize:(float)width ignoreTexts:(NSArray *)ignoreTexts
{
    NSString *text = originalStr;
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5.:]+\\]";
    NSArray *array_emoji = [text componentsMatchedByRegex:regex_emoji];
    NSMutableDictionary *dicIgnors = [NSMutableDictionary dictionaryWithCapacity:1];//要忽略的字符串
    if ([array_emoji count]) {
        for (NSString *str in array_emoji) {
            NSRange range = [text rangeOfString:str];
            
            NSString *i_transCharacter = str;
            if ([self isPic:str]) {
                BOOL containEmoji = NO;
                if (ignoreTexts && ignoreTexts.count>0) {
                    containEmoji = [self containEmoji:range origStr:text ignoreTexts:ignoreTexts];
                    if (containEmoji) {
                        if (range.location != NSNotFound) {
                            NSMutableString *spaceStr = [NSMutableString stringWithCapacity:1];
                            for (int i=0; i<range.length; i++) {
                                [spaceStr appendString:@" "];
                            }
                            text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:spaceStr];
                            [dicIgnors setValue:str forKey:NSStringFromRange(range)];
                            continue;
                        }
                    }
                }
                NSString *imgString = [[i_transCharacter stringByReplacingOccurrencesOfString:@"]" withString:@""] stringByReplacingOccurrencesOfString:@"[" withString:@""];
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>",imgString,width,width];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
                
            }
        }
    }
    //返回转义后的字符串
    NSArray *allkey = [dicIgnors allKeys];
    for (NSString *key in allkey) {
        NSString *value = [dicIgnors objectForKey:key];
        text = [text stringByReplacingCharactersInRange:NSRangeFromString(key) withString:value];
    }
    
    return text;
}

//是否是图片和gif表情
+ (BOOL)isPic:(NSString *)string
{
    //匹配表情
    NSArray *gifImg = [string componentsSeparatedByString:@":"];
    NSArray *img = [string componentsSeparatedByString:@"."];
    if (gifImg.count == 3) {
        return YES;
    }else if (img.count == 2) {
        return YES;
    }
    return NO;
}


//获取GIF 表情名
+ (NSString *)getGifImgName:(NSString *)string {
    NSArray *gifImg = [string componentsSeparatedByString:@":"];
    if (gifImg.count != 3) {
        return nil;
    }

    NSString *imgString = [NSString stringWithFormat:@"%@.gif",[gifImg lastObject]];
    return imgString;
}
//获取网络图片地址
+ (NSString *)getimgUrl:(NSString *)string {
    NSArray *img = [string componentsSeparatedByString:@"."];
    if (img.count != 2) {
        return nil;
    }
    return string;
}
@end
