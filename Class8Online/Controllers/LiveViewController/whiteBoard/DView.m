//
//  DView.m
//  WWW
//
//  Created by chuliangliang on 15/5/18.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "DView.h"
#import <CoreText/CoreText.h>

@interface LayerUtils : NSObject
/**
 * 绘制点
 * 点位置的转换
 **/
+ (CGPoint)pointConver:(CGPoint)point showSize:(CGSize)size;

/**
 * 绘制文字
 * 点位置的转换
 **/
+ (CGRect)pointConverRect:(CGRect)rect showSize:(CGSize)size;

@end
@implementation LayerUtils

+ (CGPoint)pointConver:(CGPoint)point showSize:(CGSize)size
{
    point.x = point.x * size.width;
    point.y = point.y * size.width;
    
    return point;
}

/**
 * 绘制文字
 * 点位置的转换
 **/
+ (CGRect)pointConverRect:(CGRect)rect showSize:(CGSize)size
{
    CGRect newRect = CGRectZero;
    
    CGPoint point = rect.origin;
    newRect.origin.x = point.x * size.width;
    newRect.origin.y = point.y * size.width;
    
    
    CGSize tSize = [self textShowSize:rect.size scaleNum:1-point.x];
    newRect.size.width = MIN(tSize.width, size.width - newRect.origin.x);
    newRect.size.height = MIN(tSize.height, size.height - newRect.origin.y);

    return newRect;
}

/**
 * 换算显示区域
 **/
+ (CGSize)textShowSize:(CGSize )tSize scaleNum:(float)sNum{
    CGSize newSize = CGSizeZero;
    newSize.width = tSize.width * sNum;
    newSize.height = tSize.height * sNum;

    return newSize;
}
@end

@interface Dlayer : CALayer
@property (strong, nonatomic) NSArray *points__;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) CGFloat lineWidth;

@end
@implementation Dlayer

- (void)dealloc {
    self.points__ = nil;
    self.lineColor = nil;
}
- (void)drawInContext:(CGContextRef)ctx {
    //绘制线条
    CGMutablePathRef path = CGPathCreateMutable();
    
    for (int i = 0; i < self.points__.count; i ++ ) {
        if (i == 0) {
            CGPoint startPoint;
            NSValue *value =  [self.points__ objectAtIndex:i];
            [value getValue:&startPoint];
            startPoint = [LayerUtils pointConver:startPoint showSize:self.bounds.size];
            CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
        }else {
            CGPoint addPoint;
            NSValue *value =  [self.points__ objectAtIndex:i];
            [value getValue:&addPoint];
            addPoint = [LayerUtils pointConver:addPoint showSize:self.bounds.size];
            CGPathAddLineToPoint(path, NULL, addPoint.x, addPoint.y);
        }
    }
    
    //    UIBezierPath *path_bz = [UIBezierPath bezierPathWithCGPath:path];
    CGContextAddPath(ctx,path);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(path);

}

@end

@interface DView ()
@property (strong, nonatomic) NSMutableArray *paints; //笔画key 数组 对应的 笔画 图层
@end
@implementation DView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layerDic = [[NSMutableDictionary alloc] init];
        self.paints = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc {
    self.layerDic = nil;
    self.lineColor_ = nil;
    self.paints = nil;
}
//=================================
//TODO : 绘制线条
//=================================
- (void)addPoints:(NSArray *)point paintID:(int)pid userid:(long long)uid
{

    Dlayer *dlayer = [[Dlayer alloc] init];
    dlayer.frame = self.bounds;
    dlayer.points__ = point;
    dlayer.lineColor = self.lineColor_;
    dlayer.lineWidth = self.lineWidth_;
    [dlayer setNeedsDisplay];
    [self.layer addSublayer:dlayer];
    [self addLayerdicLayer:dlayer forkey:pid userid:uid];
}

//=================================
//TODO: 绘制文字图层
//=================================
- (void)addTextLayer:(NSString *)text paintID:(int)pid textRct:(CGRect )rect userid:(long long)uid
{
    
    ClassRoomLog(@"DView: 绘制文字图层rect: %@",NSStringFromCGRect(rect));
    
    CGRect tRect = [LayerUtils pointConverRect:rect showSize:self.bounds.size];
    
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.frame = tRect;
    titleLayer.alignmentMode = kCAAlignmentLeft;
    titleLayer.truncationMode = kCATruncationEnd;
    titleLayer.contentsScale = [[UIScreen mainScreen] scale];
    titleLayer.wrapped = YES;
    [self.layer addSublayer:titleLayer];
    [self drawTextString:text showTextLayer:titleLayer];
    
    [self addLayerdicLayer:titleLayer forkey:pid userid:uid];
    
}
/**
 * 设置文字属性 字体自适应
 **/
- (void)drawTextString:(NSString *)text  showTextLayer:(CATextLayer *)textLayer{
    UIFont *textFont = self.textFont_;
    
    int fontSize = textFont.pointSize;
    NSMutableAttributedString *theString = [[NSMutableAttributedString alloc] initWithString:text];
    //设置文字颜色
    [theString addAttribute:(NSString *)kCTForegroundColorAttributeName value:self.textColor_ range:NSMakeRange(0, theString.string.length)];
    
    //设置文字字体
    CFStringRef fontName = (__bridge CFStringRef)textFont.fontName;
    CTFontRef font = CTFontCreateWithName(fontName, fontSize, NULL);
    [theString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, theString.string.length)];
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)theString);
    
    CGRect columnRect = CGRectMake(0, 0 , textLayer.bounds.size.width, textLayer.bounds.size.height);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, columnRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CFRange frameRange = CTFrameGetVisibleStringRange(frame);
    
    
    while(theString.string.length > frameRange.length){
        
        fontSize--;
        
        CFStringRef fontName = (__bridge CFStringRef)textFont.fontName;
        
        CTFontRef font = CTFontCreateWithName(fontName, fontSize, NULL);
        
        [theString addAttribute:(NSString *)kCTFontAttributeName
                          value:(__bridge id)font
                          range:NSMakeRange(0, theString.string.length)];
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)theString);
        
        CGRect columnRect = CGRectMake(0, 0 , textLayer.bounds.size.width, textLayer.bounds.size.height);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, columnRect);
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        
        frameRange = CTFrameGetVisibleStringRange(frame);
    }
    textLayer.string = theString;
}


//=================================
//TODO : 保存图层
//=================================
- (void)addLayerdicLayer:(CALayer *)layer forkey:(NSInteger)index userid:(long long)uid{
    NSString *keyString = [NSString stringWithFormat:@"%lld-%ld",uid,(long)index];
    [self.layerDic setObject:layer forKey:keyString];
    [self.paints addObject:keyString];
}


//=================================
//TODO : 移除图层
//=================================
- (void)removeLayerDiclayerForKey:(NSInteger )index userid:(long long)uid
{
    NSString *keyString = [NSString stringWithFormat:@"%lld-%ld",uid,(long)index];
    CALayer *layer = [self.layerDic objectForKey:keyString];
    if (layer) {
        [layer removeFromSuperlayer];
        layer = nil;
        [self.layerDic removeObjectForKey:keyString];
    }
}

/**
 * 移除全部图层
 **/
- (void)removeAllLayerDiclayer
{
    NSArray *keys = [self.layerDic allKeys];
    for (NSString *key in keys) {
        
        CALayer *layer = [self.layerDic objectForKey:key];
        if (layer) {
            [layer removeFromSuperlayer];
            layer = nil;
        }

    }
    [self.layerDic removeAllObjects];
}

/**
 * 移除最后一个图层
 **/
- (void)removeLastLayer {
    
    NSString *keyString = [self.paints lastObject];
    CALayer *layer = [self.layerDic objectForKey:keyString];
    if (layer) {
        [layer removeFromSuperlayer];
        layer = nil;
        [self.layerDic removeObjectForKey:keyString];
        CSLog(@"更新白板数据 => 撤销 %@",keyString);
    }
    [self.paints removeObject:keyString];
}
@end
