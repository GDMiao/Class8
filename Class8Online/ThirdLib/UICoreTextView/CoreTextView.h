//
//  CoreTextView.h
//
//  Created by Gilad Novik on 2013-01-10.
//  Copyright (c) 2013 Gilad Novik.
//
//  Distributed under the permissive zlib License
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <UIKit/UIKit.h>

@protocol CoreTextViewDelegate;

@protocol HTMLRenderer<NSObject>
@required
@property(nonatomic,readonly) CGSize size;
@optional
@property(nonatomic,readonly) CGFloat ascent;
@property(nonatomic,readonly) CGFloat descent;

@required
-(void)renderInContext:(CGContextRef)context rect:(CGRect)rect;
@end

@interface CoreTextView : UIView
@property(nonatomic,strong) NSAttributedString* attributedString;
@property(nonatomic,assign) UIEdgeInsets contentInset;
@property(nonatomic,assign) id<CoreTextViewDelegate> delegate;
@property(nonatomic,assign) BOOL debugBorders;

@property(nonatomic,strong) UIImage *placeholderImage;
@end

@protocol CoreTextViewDelegate<NSObject>
@optional
-(BOOL)coreTextView:(CoreTextView*)view openURL:(NSString*)url;
@end

@interface HTMLParser : NSObject
@property(nonatomic,copy) id<HTMLRenderer> (^rendererHandler)(NSMutableDictionary* attributes);
-(NSAttributedString*)parse:(NSString*)html;

@property(nonatomic,strong) UIColor *textColor;//文字颜色
@property(nonatomic,strong) UIColor *linkColor;//链接颜色
@property(nonatomic,assign) BOOL showUnderline;//下划线
@property(nonatomic,strong) UIFont *textFont;//字号
@end

@interface NSAttributedString (CTHTML)
+(NSAttributedString*)attributedStringWithHTML:(NSString*)html;
+(NSAttributedString*)attributedStringWithHTML:(NSString*)html renderer:(id<HTMLRenderer> (^)(NSMutableDictionary* attributes))renderer;

/**
 * 设置颜色字体
 */
+(NSAttributedString*)attributedStringWithHTML:(NSString*)html textFont:(UIFont *)textFont textColor:(UIColor*)textColor linkColor:(UIColor*)linkColor;
@end
