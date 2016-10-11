//
//  PDFZoomView.m
//  PDFDemo
//
//  Created by chuliangliang on 15/5/25.
//  Copyright (c) 2015年 class8. All rights reserved.
//

#import "PDFZoomView.h"
#import "FileCacheManager.h"

#define HandDoubleTap 2
#define HandOneTap 1
#define MaxZoomScaleNum 5.0
#define MinZoomScaleNum 1.0

@interface PDFZoomView ()
{
    CGPDFDocumentRef pdf;
    CGSize pdfInstenSize;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation PDFZoomView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}

- (void)dealloc {
    self.scrollView = nil;
    self.delegate = nil;
    self.pdfBjView = nil;
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

- (void)_initView {
    
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    [self addSubview:_scrollView];
    
    float pdfbjViewHeight = self.width * PDFWidthAndHeightProportion;
    self.pdfBjView = [[PDFBackView alloc] initWithFrame:CGRectMake(0,0, self.width, pdfbjViewHeight)];
    self.pdfBjView.center = self.center;
    self.pdfBjView.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:self.pdfBjView];
    
    pdfInstenSize = self.pdfBjView.size;
//    //双击
//    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                       action:@selector(TapsAction:)];
//    [doubleTapGesture setNumberOfTapsRequired:HandDoubleTap];
//    [self.scrollView addGestureRecognizer:doubleTapGesture];
//    
//    //单击
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(TapsAction:)];
//    [tapGesture setNumberOfTapsRequired:HandOneTap];
//    [self.scrollView addGestureRecognizer:tapGesture];
//    
//    //双击失败之后执行单击
//    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    self.scrollView.maximumZoomScale = MaxZoomScaleNum;
    self.scrollView.minimumZoomScale = MinZoomScaleNum;
    self.scrollView.zoomScale = MinZoomScaleNum;
    
}

- (void) updateFrame:(CGRect)frame currentShowSmallView:(BOOL)small
{
 
    if (!CGSizeEqualToSize(frame.size, self.size)) {
        self.frame = frame;
        _scrollView.zoomScale = 1;
        float zooScale = small?MIN(self.scrollView.height/pdfInstenSize.height, self.scrollView.width/pdfInstenSize.width):MAX(1, MIN(self.scrollView.height/self.pdfBjView.height, self.scrollView.width/self.pdfBjView.width));
        _scrollView.minimumZoomScale = zooScale;
        _scrollView.contentOffset = CGPointZero;
        _scrollView.zoomScale  = zooScale;
        [self scrollViewDidZoom:_scrollView];
        
        ClassRoomLog(@"PDFZoomView: PDF 缩放比例: %f",zooScale);
    }
    
    CGFloat Ws = self.scrollView.frame.size.width - self.scrollView.contentInset.left - self.scrollView.contentInset.right;
    CGFloat Hs = self.scrollView.frame.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom;
    CGFloat W = self.pdfBjView.frame.size.width;
    CGFloat H = self.pdfBjView.frame.size.height;
    
    CGRect rct = self.pdfBjView.frame;
    rct.origin.x = MAX((Ws-W)*0.5, 0);
    rct.origin.y = MAX((Hs-H)*0.5, 0);
    self.pdfBjView.frame = rct;

    if (small) {
        self.scrollView.userInteractionEnabled = NO;
    }else {
        self.scrollView.userInteractionEnabled = YES;
    }
}

#pragma mark- 手势事件
//单击 / 双击 手势
- (void)TapsAction:(UITapGestureRecognizer *)tap
{
    NSInteger tapCount = tap.numberOfTapsRequired;
    if (HandDoubleTap == tapCount) {
        //双击
        CSLog(@"双击");
        if (self.scrollView.minimumZoomScale <= self.scrollView.zoomScale && self.scrollView.maximumZoomScale > self.scrollView.zoomScale) {
            [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
        }else {
            [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
        }
        
    }else if (HandOneTap == tapCount) {
        //单击
        CSLog(@"单击");
        if ([self.delegate respondsToSelector:@selector(imageZoomViewTapAction)]) {
            [self.delegate imageZoomViewTapAction];
        }
    }
}


#pragma mark- Scrollview delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.pdfBjView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat Ws = self.scrollView.frame.size.width - self.scrollView.contentInset.left - self.scrollView.contentInset.right;
    CGFloat Hs = self.scrollView.frame.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom;
    CGFloat W = self.pdfBjView.frame.size.width;
    CGFloat H = self.pdfBjView.frame.size.height;
    
    CGRect rct = self.pdfBjView.frame;
    rct.origin.x = MAX((Ws-W)*0.5, 0);
    rct.origin.y = MAX((Hs-H)*0.5, 0);
    self.pdfBjView.frame = rct;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------------------------------------------------------------------------------//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//==============================================================
//TODO: PDF内容 相关操作
//==============================================================

#define LineColor_wb @"clr"
#define PointCount @"point-size"
#define PointKEY @"point_"
#define Point_x @"X"
#define Point_y @"Y"
#define LineWidth @"width"
#define ERASOR_ID @"pid"

//文本
#define WBtext_rect @"rect"
#define WBtext_rect_left @"left"
#define WBtext_rect_top @"top"
#define WBtext_rect_width @"width"
#define WBtext_rect_height @"height"
#define WBtext_Text @"txt"

/**
 * 更新 PDF 涂鸦内容
 **/
- (void) updatePDFGraffito:(WhiteBoardActionModel *)wbModel
{
    ClassRoomLog(@"PDFZoomView: PDF 上绘图");
    //更新 增/改/删笔画
    switch (wbModel.paintype) {
        case WhiteBoardEventModelType_PEN:
        {
            //画笔
            NSData* jsData = [wbModel.jsonString dataUsingEncoding:NSUTF8StringEncoding];
            if (jsData) {
                id js = [NSJSONSerialization JSONObjectWithData:jsData options:NSJSONReadingMutableLeaves error:nil];
                if ([js isKindOfClass:[NSDictionary class]]) {
                    int forCount = [js intForKey:PointCount];
                    float lineWidth  = [js floatForKey:LineWidth];
                    int lineColor = [js intForKey:LineColor_wb];
                    
                    NSMutableArray *poins = [[NSMutableArray alloc] init];
                    for (int i = 1 ; i <= forCount; i ++) {
                        NSDictionary *dic = [js objectForKey:[NSString stringWithFormat:@"%@%d",PointKEY,i]];
                        if (![dic isKindOfClass:[NSDictionary class]]) {
                            continue;
                        }
                        float x = [dic floatForKey:Point_x];
                        float y = [dic floatForKey:Point_y];
                        NSValue *value_ = [NSValue valueWithCGPoint:CGPointMake(x, y)];
                        [poins addObject:value_];
                    }
                    self.pdfBjView.pdfView.lineColor_ = [UIColor colorWithRed:GetRValue(lineColor)/255.0 green:GetGValue(lineColor)/255.0 blue:GetBValue(lineColor)/255.0 alpha:1];
                    self.pdfBjView.pdfView.lineWidth_ = lineWidth;
                    ClassRoomLog(@"PDFZoomView: 更新PDF绘图数据 => 画线 白板id:%d 画笔id:%d uid:%lld",wbModel.pageId,wbModel.paintId,wbModel.uid);
                    [self.pdfBjView.pdfView addPdfPoints:poins pdfName:self.pdfBjView.pdfView.pdfName currentPage:self.pdfBjView.pdfView.page-1 paintId:wbModel.paintId userid:wbModel.uid];
                }
            }
        }
            break;
        case WhiteBoardEventModelType_ERASOR:{
            //橡皮
            NSData* jsData = [wbModel.jsonString dataUsingEncoding:NSUTF8StringEncoding];
            if (jsData) {
                id js = [NSJSONSerialization JSONObjectWithData:jsData options:NSJSONReadingMutableLeaves error:nil];
                if ([js isKindOfClass:[NSDictionary class]]) {
                    int paintID = [js intForKey:ERASOR_ID];
                    ClassRoomLog(@"PDFZoomView: 更新PDF绘制数据 => 橡皮 画笔id:%d uid:%lld",paintID,wbModel.uid);
                    [self.pdfBjView.pdfView removeLayerWithPaintid:paintID userid:wbModel.uid];
                }
            }
            
        }
            break;
        case WhiteBoardEventModelType_TXT:
        {
            //文本
            NSData* jsData = [wbModel.jsonString dataUsingEncoding:NSUTF8StringEncoding];
            if (jsData) {
                id js = [NSJSONSerialization JSONObjectWithData:jsData options:NSJSONReadingMutableLeaves error:nil];
                if ([js isKindOfClass:[NSDictionary class]]) {
                    NSString *text = [js stringForKey:WBtext_Text];
                    int lineColor = [js intForKey:LineColor_wb];
                    NSDictionary *dic = [js objectForKey:WBtext_rect];
                    float left = [dic floatForKey:WBtext_rect_left];
                    float top = [dic floatForKey:WBtext_rect_top];
                    float width = [dic floatForKey:WBtext_rect_width];
                    float height = [dic floatForKey:WBtext_rect_height];
                    CGRect textRect = CGRectMake(left, top, width, height);
                    self.pdfBjView.pdfView.textColor_ = [UIColor colorWithRed:GetRValue(lineColor)/255.0 green:GetGValue(lineColor)/255.0 blue:GetBValue(lineColor)/255.0 alpha:1];
                    ClassRoomLog(@"PDFZoomView: 更新PDF绘制文本数据 => 文本 画笔id:%d uid:%lld",wbModel.paintId,wbModel.uid);
                    [self.pdfBjView.pdfView addPdfText:text textRct:textRect pdfName:self.pdfBjView.pdfView.pdfName currentPage:self.pdfBjView.pdfView.page -1 paintId:wbModel.paintId userid:wbModel.uid];
                }
            }
        }
            break;
        case WhiteBoardEventModelType_LASER_POINT:
        {
            //激光指示
            
        }
            break;
        case WhiteBoardEventModelType_UNDO:{
            //撤销
            ClassRoomLog(@"PDFZoomView: 更新PDF 绘制 数据 => 删除最后一笔");
            [self.pdfBjView.pdfView removeLastLayer];
            
        }
            break;
        case WhiteBoardEventModelType_Clearn:
        {
            //清空
            ClassRoomLog(@"PDFZoomView: 更新PDF 绘制 数据 => 移除全部");
            [self.pdfBjView.pdfView removeAllLayer];
        }
            break;
        default:
            break;
    }
}

/**
 *更新PDF 文件
 **/
- (void)updatePDFFile:(NSString *)fileName withCurrentPage:(int)page
{
    page = MAX(1, page);
    ClassRoomLog(@"PDFZoomView: 更新显示PDF 文件: %@ page:%d",fileName,page);
    [self.pdfBjView.pdfView stopLoad];
    if (![self.pdfBjView.pdfView.pdfName isEqualToString:fileName]) {
        [self.pdfBjView.pdfView updatePdfData:fileName];
    }
    self.pdfBjView.pdfView.page = page;

}

/**
 * 下课后 清除数据
 **/
- (void)clearnAllDataAtClassOver
{
    [self.pdfBjView.pdfView clearnAllData];
}

/**
 * 删除PDF课件 移除对应信息
 **/
- (void)clearnDataAtDelPDFFile:(NSString *)fileName
{
    [self.pdfBjView.pdfView removeAllLayerForPdf:fileName];
}

/**
 * 显示PDF 文件加载状态<菊花>
 **/
- (void)showLoadingSttus
{
    [self.pdfBjView.pdfView startLoad];
}

@end
