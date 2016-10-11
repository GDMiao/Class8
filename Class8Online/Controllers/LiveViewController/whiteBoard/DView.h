//
//  DView.h
//  WWW
//
//  Created by chuliangliang on 15/5/18.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DView : UIView
@property (strong, nonatomic) UIColor *lineColor_;  //线条颜色
@property (assign, nonatomic) CGFloat lineWidth_;   //线条宽度
@property (strong, nonatomic) UIColor *textColor_;  //文字颜色
@property (strong, nonatomic) UIFont *textFont_;    //字体
@property (strong, nonatomic) NSMutableDictionary *layerDic;
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
