//
//  PDFBackView.h
//  Class8Online
//
//  Created by chuliangliang on 15/6/25.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawPDFView.h"
#define PDFWidthAndHeightProportion 0.706666
@interface PDFBackView : UIView
@property (strong, nonatomic) DrawPDFView *pdfView;

/**
 * 更新坐标放大比例 弃用 for 2015/06/29
 **/
- (void)updateFrame:(CGRect)frame isAnimate:(BOOL)animate;
@end
