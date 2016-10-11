//
//  DrawPDFView.m
//  Class8Online
//
//  Created by chuliangliang on 15/6/8.
//  Copyright (c) 2015年 Class8Online. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawPDFView : UIView

@property (nonatomic, assign) size_t page,allPage;

@property (strong, nonatomic) UIColor *lineColor_;  //线条颜色
@property (assign, nonatomic) CGFloat lineWidth_;   //线条宽度
@property (strong, nonatomic) UIColor *textColor_;  //文字颜色
@property (strong, nonatomic) UIFont *textFont_;    //字体
@property (strong, nonatomic) NSString *pdfName;    //pdfName;
- (void)updatePdfData:(NSString *)pdfName;

/**
 * 菊花开始转圈
 **/
- (void)startLoad;

/**
 *菊花停止转圈
 **/
- (void)stopLoad;

/**
 * PDF 上绘制点
 **/
- (void)addPdfPoints:(NSArray *)points pdfName:(NSString *)pName currentPage:(size_t)pid paintId:(int)paintid userid:(long long)uid;


/**
 * PDF 上绘制文字
 **/
- (void)addPdfText:(NSString *)text textRct:(CGRect )rect pdfName:(NSString *)pName currentPage:(size_t)pid paintId:(int)paintid userid:(long long)uid;

/**
 * 移除最后图层
 **/
- (void)removeLastLayer;

/**
 * 移除全部当前页码 上所有涂鸦图层
 **/
- (void)removeAllLayer;

/**
 * 下课后清除所有数据
 **/
- (void)clearnAllData;


/**
 * 移除PDF 将该PDF 下所有图层移除
 **/
- (void)removeAllLayerForPdf:(NSString *)pdfName;
/**
 * 移除指定图层
 **/
- (void)removeLayerWithPaintid:(int)paintid userid:(long long)uid;

@end
