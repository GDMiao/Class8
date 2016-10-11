//
//  PDFZoomView.h
//  PDFDemo
//
//  Created by chuliangliang on 15/5/25.
//  Copyright (c) 2015年 class8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFBackView.h"
#import "ClassRoomEventModel.h"



@protocol PDFViewZoomViewDelegate <NSObject>
@optional
- (void)imageZoomViewTapAction;

@end

@interface PDFZoomView : UIView<UIScrollViewDelegate>
@property (nonatomic, weak) id<PDFViewZoomViewDelegate>delegate;
@property (nonatomic, strong) PDFBackView *pdfBjView;
- (void) updateFrame:(CGRect)frame currentShowSmallView:(BOOL)small;

/**
 * 更新 PDF 涂鸦内容
 **/
- (void) updatePDFGraffito:(WhiteBoardActionModel *)wbModel;

/**
 * 更新PDF 文件
 **/
- (void)updatePDFFile:(NSString *)fileName withCurrentPage:(int)page;

/**
 * 下课后 清除数据
 **/
- (void)clearnAllDataAtClassOver;

/**
 * 删除PDF课件 移除对应信息
 **/
- (void)clearnDataAtDelPDFFile:(NSString *)fileName;

/**
 * 显示PDF 文件加载状态<菊花>
 **/
- (void)showLoadingSttus;
@end
