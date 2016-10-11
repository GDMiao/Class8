//
//  DrawPDFView.m
//  Class8Online
//
//  Created by chuliangliang on 15/6/8.
//  Copyright (c) 2015年 Class8Online. All rights reserved.
//

#import "DrawPDFView.h"
#import <CoreText/CoreText.h>
#import "Downloader.h"

@interface DrawPDFUtils : NSObject
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
@implementation DrawPDFUtils

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



@interface PDFDrawLayer : CALayer
@property (strong, nonatomic) NSArray *points__;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) CGFloat lineWidth;

@end
@implementation PDFDrawLayer

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
            startPoint = [DrawPDFUtils pointConver:startPoint showSize:self.bounds.size];
            CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
        }else {
            CGPoint addPoint;
            NSValue *value =  [self.points__ objectAtIndex:i];
            [value getValue:&addPoint];
            addPoint = [DrawPDFUtils pointConver:addPoint showSize:self.bounds.size];
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

//===================
// 绘图层
//===================
@interface PDFDRrawView : UIView
@property (strong, nonatomic) UIColor *lineColor_;  //线条颜色
@property (assign, nonatomic) CGFloat lineWidth_;   //线条宽度
@property (strong, nonatomic) UIColor *textColor_;  //文字颜色
@property (strong, nonatomic) UIFont *textFont_;    //字体
@property (strong, nonatomic) NSMutableDictionary *layerDic;
@property (strong, nonatomic) NSMutableArray *paints; //笔画key 数组 对应的 笔画 图层

//=================================
//TODO : 绘制线条
//=================================
- (void)addPoints:(NSArray *)point paintID:(int)pid userid:(long long)uid;

//=================================
//TODO: 绘制文字图层
//=================================
- (void)addTextLayer:(NSString *)text paintID:(int)pid textRct:(CGRect )rect userid:(long long)uid;

//=================================
//TODO : 移除图层
//=================================
- (void)removeLayerDiclayerForKey:(NSInteger )index userid:(long long)uid;

/**
 * 移除全部图层
 **/
- (void)removeAllLayerDiclayer;
/**
 * 移除最后一个图层
 **/
- (void)removeLastLayer;

@end

@implementation PDFDRrawView

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
    
    PDFDrawLayer *dlayer = [[PDFDrawLayer alloc] init];
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
    CGRect tRect = [DrawPDFUtils pointConverRect:rect showSize:self.bounds.size];
    
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
    }
    [self.paints removeObject:keyString];
}


@end




//PDF
@interface DrawPDFPageView : UIView
{
    CGPDFPageRef pdfPage;
}

- (void)setNowPDFpage:(CGPDFPageRef)page;
@end
@implementation DrawPDFPageView

- (void)setNowPDFpage:(CGPDFPageRef)page {
    pdfPage = page;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!pdfPage) {
        return;
    }
    // 绘制pdf一
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat scaleFactor = [[UIScreen mainScreen] scale];
    CGContextTranslateCTM(ctx, 0.0, self.bounds.size.height);
    CGContextScaleCTM(ctx, scaleFactor, -scaleFactor);
    CGContextSaveGState(ctx);
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, CGRectMake(0, 0, self.bounds.size.width /scaleFactor, self.bounds.size.height / scaleFactor), 0, true);
    CGContextConcatCTM(ctx, pdfTransform);
    CGContextDrawPDFPage(ctx, pdfPage);
    CGContextRestoreGState(ctx);
    
//    //绘制pdf方法二
//    //prevent releasing while drawing
//    CGPDFPageRetain(pdfPage);
//    CGContextRetain(ctx);
//    CGContextSaveGState(ctx);
//    CGRect bounding = self.bounds;
//    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
//    CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));
//    CGContextTranslateCTM(ctx, 0.0, bounding.size.height);
//    CGContextScaleCTM(ctx, 1.0, -1.0);
//    CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, bounding, 0, true));
//    CGContextDrawPDFPage(ctx, pdfPage);
//    CGContextRestoreGState(ctx);
//    CGContextRelease(ctx);
//    CGPDFPageRelease(pdfPage);

}

@end

@interface DrawPDFView ()
{
    CGPDFDocumentRef pdf;
    UIActivityIndicatorView *activiView;
}
@property (nonatomic, strong) DrawPDFPageView *pdfPageView;
@property (nonatomic, strong) PDFDRrawView *currentPdfDrawView;
@property (nonatomic, strong) NSMutableDictionary *pdfDrawDic; //pdf 画笔视图 key : 课件名-课件id value :PDFDRrawView
@property (nonatomic, assign) size_t pdfNowPageid;
@end

@implementation DrawPDFView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}
- (void)dealloc {
    self.pdfPageView = nil;
    self.pdfDrawDic = nil;
    self.currentPdfDrawView = nil;
    self.lineColor_ = nil;
    self.textColor_ = nil;
    self.textFont_ = nil;
    self.pdfName = nil;
    if (activiView) {
        activiView = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//获取图片和显示视图宽度的比例系数
- (float)getImgWidthFactor:(CGSize )size {
    return   self.bounds.size.width / size.width;
}
//获取图片和显示视图高度的比例系数
- (float)getImgHeightFactor:(CGSize)size {
    return  self.bounds.size.height / size.height;
}

//获获取尺寸
- (CGSize)newSizeByoriginalSize:(CGSize)oldSize maxSize:(CGSize)mSize
{
    if (oldSize.width <= 0 || oldSize.height <= 0) {
        return CGSizeZero;
    }
    
    CGSize newSize = CGSizeZero;
    if (oldSize.width > mSize.width || oldSize.height > mSize.height) {
        //按比例计算尺寸
        float bs = [self getImgWidthFactor:oldSize];
        float newHeight = oldSize.height * bs;
        newSize = CGSizeMake(mSize.width, newHeight);
        
        if (newHeight > mSize.height) {
            bs = [self getImgHeightFactor:oldSize];
            float newWidth = oldSize.width * bs;
            newSize = CGSizeMake(newWidth, mSize.height);
        }
    }else {
        
        newSize = oldSize;
    }
    return newSize;
}

- (void)_initSubViews {
    self.page = 0;
    self.allPage = 0;
    

    self.pdfPageView = [[DrawPDFPageView alloc] initWithFrame:CGRectZero];
    self.pdfPageView.center = self.center;
    self.pdfPageView.backgroundColor = [UIColor whiteColor];
    self.pdfPageView.layer.contentsScale = [UIScreen mainScreen].scale;
    [self addSubview:self.pdfPageView];
    
    
    self.pdfDrawDic = [[NSMutableDictionary alloc] init];
    self.currentPdfDrawView = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloaderFile:) name:KNotification_DownLoading object:nil];
    
    activiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activiView.center = self.center;
    activiView.hidesWhenStopped = YES;
    [activiView stopAnimating];
    [self addSubview:activiView];
    
    
}

/**
 * 菊花开始转圈
 **/
- (void)startLoad {
    [activiView startAnimating];
}

/**
 *菊花停止转圈
 **/
- (void)stopLoad {
    [activiView stopAnimating];
}

#pragma mark - 
#pragma mark - 下载文件
- (void)downloaderFile:(NSNotification *)notification
{
    NSDictionary *dic = (NSDictionary *)[notification object];
    NSString *fileNme = [dic stringForKey:DOWNLOADERFILENAME];
    float pro = [dic floatForKey:DOWNLOADPROGRESS];
    ClassRoomLog(@"下载文件名: %@,进度:%f",fileNme,pro);
}

#pragma mark -
#pragma mark - 获取pdf文件
- (void)updatePdfData:(NSString *)pdfName
{
    self.pdfName = pdfName;
    NSString *filePath__ = [[FILECACHEMANAGER getFileRootPathWithFileType:FileType_PPT] stringByAppendingPathComponent:pdfName];

    [self upDatePDF:filePath__];
}

- (void)upDatePDF:(NSString *)filePath
{

    pdf = [self MyGetPDFDocumentRef:filePath];
    _page = 0;
    self.allPage = CGPDFDocumentGetNumberOfPages(pdf);
    
}

- (CGPDFDocumentRef)MyGetPDFDocumentRef:(NSString *)filePath
{
    
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    path = CFStringCreateWithCString(NULL, [filePath UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, 0);
    CFRelease(path);
    document = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    return document;
}
- (void)setPage:(size_t)page {
    
    if (page > self.allPage ) {
        return;
    }
    
    _page = page;
    [self updatePdfPage:page];
    
    [self createWb:NO];
}

- (void)updatePdfPage:(size_t)page {
    
    CGPDFPageRef page_pdf = CGPDFDocumentGetPage(pdf, self.page);
    CGRect pdfShowRect = CGPDFPageGetBoxRect(page_pdf, kCGPDFCropBox);
    
    CGSize showSize = [self newSizeByoriginalSize:pdfShowRect.size maxSize:self.bounds.size];
    self.pdfPageView.frame = CGRectMake((self.pdfPageView.center.x - showSize.width * 0.5),0, showSize.width, showSize.height);
    [self.pdfPageView setNowPDFpage:page_pdf];
    
}

#pragma mark - 创建pdf 白板

- (void)createWb:(BOOL)isCreate {
    if (self.currentPdfDrawView) {
        self.currentPdfDrawView.hidden = YES;
    }
    //查找pdf 绘图

    PDFDRrawView *pdfDv = [self getPdfView:self.pdfName currentPage:self.page];
    if (pdfDv) {
        self.currentPdfDrawView = pdfDv;
        self.currentPdfDrawView.frame = self.pdfPageView.frame;
        self.currentPdfDrawView.center = self.pdfPageView.center;
        self.currentPdfDrawView.hidden = NO;
    }else if (isCreate) {
        //创建新的绘制pdf图层
        PDFDRrawView *pview = [[PDFDRrawView alloc] initWithFrame:self.pdfPageView.frame];
        pview.center = self.pdfPageView.center;
        pview.backgroundColor = [UIColor clearColor];
        pview.lineColor_ = self.lineColor_;
        pview.lineWidth_ = self.lineWidth_;
        pview.textColor_ = self.textColor_;
        pview.textFont_ = self.textFont_;

        [self addSubview:pview];
        self.currentPdfDrawView = pview;
        [self addPdfView:pview forKey:self.pdfName currentPage:self.page];
    }else {
        self.currentPdfDrawView = nil;
    }
}

- (PDFDRrawView *)getPdfView:(NSString *)pdfName currentPage:(size_t)page
{
    NSString *pdfDrawKey = [NSString stringWithFormat:@"%@-%zu",pdfName,page];
    PDFDRrawView *pdfDv = [self.pdfDrawDic objectForKey:pdfDrawKey];
    return pdfDv;
}
- (void)addPdfView:(PDFDRrawView *)pview forKey:(NSString *)pdfName currentPage:(size_t)page
{
    if (!pview) {
        return;
    }
    NSString *pdfDrawKey = [NSString stringWithFormat:@"%@-%zu",pdfName,page];
    [self.pdfDrawDic setObject:pview forKey:pdfDrawKey];
}

/**
 * PDF 上绘制点
 **/
- (void)addPdfPoints:(NSArray *)points pdfName:(NSString *)pName currentPage:(size_t)pid paintId:(int)paintid userid:(long long)uid
{
    self.pdfName = pName;
    self.pdfNowPageid = pid;
    [self createWb:YES];
    self.currentPdfDrawView.lineWidth_ = self.lineWidth_;
    self.currentPdfDrawView.lineColor_ = self.lineColor_;
    [self.currentPdfDrawView addPoints:points paintID:paintid userid:uid];
}

/**
 * PDF 上绘制文字
 **/
- (void)addPdfText:(NSString *)text textRct:(CGRect )rect pdfName:(NSString *)pName currentPage:(size_t)pid paintId:(int)paintid userid:(long long)uid
{
    self.pdfName = pName;
    self.pdfNowPageid = pid;
    [self createWb:YES];
    self.currentPdfDrawView.textFont_ = self.textFont_;
    self.currentPdfDrawView.textColor_ = self.textColor_;
    
    [self.currentPdfDrawView addTextLayer:text paintID:paintid textRct:rect userid:uid];

}

/**
 * 移除最后图层
 **/
- (void)removeLastLayer {

    PDFDRrawView *pview = [self getPdfView:self.pdfName currentPage:self.page];
    if (pview) {
        [pview removeLastLayer];
    }
}

/**
 * 移除全部
 **/
- (void)removeAllLayer
{
    PDFDRrawView *pview = [self getPdfView:self.pdfName currentPage:self.page];
    if (pview) {
        [pview removeAllLayerDiclayer];
    }
}

/**
 * 下课后清除所有数据
 **/
- (void)clearnAllData {
    
}

/**
 * 移除PDF 将该PDF 下所有图层移除
 **/
- (void)removeAllLayerForPdf:(NSString *)pdfName
{
    NSArray *keys = self.pdfDrawDic.allKeys;
    for (NSString *key in keys) {
        NSRange keyRange = [key rangeOfString:pdfName];
        if (keyRange.location == 0 && keyRange.length == pdfName.length) {
            PDFDRrawView *pdfDv = [self.pdfDrawDic objectForKey:key];
            if (pdfDv) {
                [pdfDv removeAllLayerDiclayer];
                [self.pdfDrawDic removeObjectForKey:key];
            }
        }
    }
}


/**
 * 移除指定图层
 **/
- (void)removeLayerWithPaintid:(int)paintid userid:(long long)uid
{
    PDFDRrawView *pview = [self getPdfView:self.pdfName currentPage:self.page];
    if (pview) {
        [pview removeLayerDiclayerForKey:paintid userid:uid];
    }

}
@end

