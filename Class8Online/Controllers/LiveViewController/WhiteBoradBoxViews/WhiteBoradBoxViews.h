//
//  WhiteBoradBoxViews.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/25.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DView.h"
#import "ClassRoomEventModel.h"

@interface WhiteBoradBoxViews : UIView
@property (strong, nonatomic) DView *currentWB; //当前展示的白板
- (void)updateFrame:(CGRect)frame isAnimate:(BOOL)animate;

#pragma mark-
#pragma mark- 创建白板
- (void)createWhiteBorad:(int)wbid with:(WhiteBoardActionModel *)wbModel;

#pragma mark-
#pragma mark- 删除白板
- (void)removeWhiteBoradWith:(int)wbid;

#pragma mark-
#pragma mark- 更新白板涂鸦数据 返回YES 代表 属于白板涂鸦数据并更新 返回 NO为非白板数据(PDF涂鸦)
- (BOOL)updateWhiteBoradData:(WhiteBoardActionModel *)wbModel;


#pragma mark-
#pragma mark- 切换显示模式为显示 白板
- (void)switchShowWhiteBorad:(int)wbid;


#pragma mark-
#pragma mark- 下课清除所有白板数据
- (void)cleanAllWhiteBorad;

@end
