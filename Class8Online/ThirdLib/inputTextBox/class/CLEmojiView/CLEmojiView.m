//
//  CLEmojiView.m
//  EmojiView
//
//  Created by chuliangliang on 15/5/27.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "CLEmojiView.h"

#define CLEmoji_idxPathKey @"idxPath"
#define CLEmoji_imgKey @"imgName"
#define CLEmoji_imgKey_showName @"imgshowName"

@interface CLEmojiLayer : CALayer
@property (strong, nonatomic) UIImage *img;
@end
@implementation CLEmojiLayer

//- (void)drawInContext:(CGContextRef)ctx
//{
//    CGImageRef keytopImage = self.img.CGImage;
//    
//    UIGraphicsBeginImageContext(CGSizeMake(Emoji_Width, Emoji_Height));
//    CGContextTranslateCTM(ctx, 0.0, Emoji_Height);
//    CGContextScaleCTM(ctx, 1.0, -1.0);
//    CGContextDrawImage(ctx, CGRectMake((self.bounds.size.width - Emoji_Width) * 0.5, (self.bounds.size.height - Emoji_Height) * 0.5, Emoji_Width, Emoji_Height), keytopImage);
//    UIGraphicsEndImageContext();
//}

@end

@interface CLEmojiView ()
{
    NSInteger _touchedIndex;
}
@property (nonatomic, strong) NSArray *emojis;
@end
@implementation CLEmojiView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initViews];
    }
    return self;
}

- (void)_initViews
{
    self.layer.masksToBounds = YES;
}
- (void)updateEmojis:(NSArray *)arr
{
    self.emojis = arr;
    
    CGFloat x = Emoji_line;
    CGFloat y = 0;
    
    for (int idx = 0; idx < self.emojis.count; idx ++ ) {
        if (idx % Emoji_LINE_COUNT == 0) {
            x = Emoji_line;
            if (idx != 0) {
                y += Emoji_Height + Emoji_line;
            }
        }else {
            x += Emoji_Width + Emoji_line;
        }
        NSDictionary *dic = [self.emojis objectAtIndex:idx];
        NSString *imgName = [dic objectForKey:CLEmoji_imgKey];
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif",imgName]];
        
        CLEmojiLayer *eLayer = [[CLEmojiLayer alloc] init];
        eLayer.frame = CGRectMake(x, y, Emoji_Width, Emoji_Height);
        eLayer.img = img;
        eLayer.contentsGravity = kCAGravityResizeAspect;
        eLayer.contents = (id) [img CGImage];
        [self.layer addSublayer:eLayer];
    }

}

#pragma mark -
#pragma mark Actions
- (NSUInteger)indexWithEvent:(UIEvent*)event
{
    UITouch* touch = [[event allTouches] anyObject];
    NSUInteger x = [touch locationInView:self].x / (self.bounds.size.width / Emoji_LINE_COUNT);
    NSUInteger y = [touch locationInView:self].y / (self.bounds.size.width / Emoji_LINE_COUNT);
    
    return x + (y * Emoji_LINE_COUNT);
}


- (void)updateWithIndex:(NSUInteger)index
{
    if(index < self.emojis.count) {
        _touchedIndex = index;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    if(index < self.emojis.count) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self updateWithIndex:index];
        [CATransaction commit];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    if (index != _touchedIndex && index < self.emojis.count) {
        [self updateWithIndex:index];
    }else if (index >= self.emojis.count){
        _touchedIndex = -1;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (_touchedIndex >= 0) {
        if ([self.delegate respondsToSelector:@selector(didTouchEmojiView:touchedEmojiName:emojiIndexPath:)]) {
            NSDictionary *dic = [self.emojis objectAtIndex:_touchedIndex];
            [self.delegate didTouchEmojiView:self touchedEmojiName:[dic objectForKey:CLEmoji_imgKey_showName] emojiIndexPath:[dic objectForKey:CLEmoji_imgKey]];
        }
    }
    _touchedIndex = -1;
}

@end
