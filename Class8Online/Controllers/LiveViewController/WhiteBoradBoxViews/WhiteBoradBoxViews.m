//
//  WhiteBoradBoxViews.m
//  Class8Online
//
//  Created by chuliangliang on 15/7/25.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "WhiteBoradBoxViews.h"
@interface WhiteBoradBoxViews ()
{
    CGSize self_InitSize;
}
@end
@implementation WhiteBoradBoxViews

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self_InitSize = self.size;
    }
    return self;
}

- (void)dealloc {
    self.currentWB = nil;
}
- (void)updateFrame:(CGRect)frame isAnimate:(BOOL)animate
{
    if (animate) {
        float drPdfMinScale = 1;
        float viewWidth = frame.size.width;
        float viewHeight = frame.size.height;
        drPdfMinScale = MIN(viewWidth/self.currentWB.width, viewHeight/self.currentWB.height);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
            self.currentWB.transform = CGAffineTransformScale(self.currentWB.transform, drPdfMinScale, drPdfMinScale);
            self.currentWB.left = (self.width - self.currentWB.width) * 0.5;
            self.currentWB.top = (self.height - self.currentWB.height) * 0.5;
        }];
    }else {
        float drPdfMinScale = 1;
        float viewWidth = frame.size.width;
        float viewHeight = frame.size.height;
        drPdfMinScale = MIN(viewWidth/self.currentWB.width, viewHeight/self.currentWB.height);
        
        self.frame = frame;
        self.currentWB.transform = CGAffineTransformScale(self.currentWB.transform, drPdfMinScale, drPdfMinScale);
        self.currentWB.left = (self.width - self.currentWB.width) * 0.5;
        self.currentWB.top = (self.height - self.currentWB.height) * 0.5;
        
    }
}

- (void)updateFrame:(CGRect)frame isAnimate:(BOOL)animate atWBViw:(DView *)wbview {
    if (animate) {
        float drPdfMinScale = 1;
        float viewWidth = frame.size.width;
        float viewHeight = frame.size.height;
        drPdfMinScale = MIN(viewWidth/wbview.width, viewHeight/wbview.height);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
            wbview.transform = CGAffineTransformScale(wbview.transform, drPdfMinScale, drPdfMinScale);
            wbview.left = (self.width - wbview.width) * 0.5;
            wbview.top = (self.height - wbview.height) * 0.5;
        }];
    }else {
        float drPdfMinScale = 1;
        float viewWidth = frame.size.width;
        float viewHeight = frame.size.height;
        drPdfMinScale = MIN(viewWidth/wbview.width, viewHeight/wbview.height);
        
        self.frame = frame;
        wbview.transform = CGAffineTransformScale(wbview.transform, drPdfMinScale, drPdfMinScale);
        wbview.left = (self.width - wbview.width) * 0.5;
        wbview.top = (self.height - wbview.height) * 0.5;
        
    }

}


#pragma mark-
#pragma mark- 白板操作 <创建/删除/涂鸦操作>
//========================================================================
//TODO: 白板操作
//========================================================================
//TODO: 根据id 创建白板
#define WB_MIN_TAG 100   //白板视图起始TAG
#define ClassRoomPage 50
#define WB_DefaultKey @"pageid_"

/**
 *创建白板
 **/
- (DView *)createWhiteBoradView:(int)viewTag {
    
    DView *wbView = [[DView alloc] initWithFrame:CGRectMake(0, 0, self_InitSize.width, self_InitSize.width / 4 * 3)];
    wbView.center = self.center;
    wbView.backgroundColor = [UIColor colorWithRed:96 / 255.0 green:123 / 255.0 blue:96 / 255.0 alpha:1];
    wbView.lineColor_ = [UIColor colorWithWhite:244/255.0 alpha:1];
    wbView.lineWidth_ = 1;
    wbView.hidden = YES;
    wbView.tag = viewTag;
    wbView.textColor_ = [UIColor colorWithWhite:244/255.0 alpha:1];
    wbView.textFont_ = [UIFont systemFontOfSize:15.0f];
    [self insertSubview:wbView atIndex:0];
    return wbView;
}

/**
 * 通过 view tag 获取白板
 * 白板为空并且 isCreate == yes 时创建一个 并返回
 **/
- (DView *)getWhiteBorad:(int)viewTag autoCreate:(BOOL)isCreate
{
    DView *wbView = (DView *)[self viewWithTag:viewTag];
    if (!wbView && isCreate) {
        wbView = [self createWhiteBoradView:viewTag];
    }
    return wbView;
}


- (void)createWhiteBorad:(int)wbid with:(WhiteBoardActionModel *)wbModel {
    
    
    if (wbid > ClassRoomPage) {
        ClassRoomLog(@"WhiteBoradBoxViews ==> 创建白板id:%d",wbid);
        int wbViewId = WB_MIN_TAG + wbid;
        DView *wbView = (DView *)[self viewWithTag:wbViewId];
        if (!wbView) {
            wbView = [self createWhiteBoradView:wbViewId];
        }
    }else {
        ClassRoomLog(@"WhiteBoradBoxViews ==> 讨论组白板不创建 白板id:%d",wbid);
    }
}


//TODO: 根据id 删除白板
- (void)removeWhiteBoradWith:(int)wbid {
    int wbViewTag = WB_MIN_TAG + wbid;
    DView *wbView = (DView *)[self viewWithTag:wbViewTag];
    if (wbid) {
        [wbView removeFromSuperview];
        if (self.currentWB.tag == wbViewTag) {
            self.currentWB = nil;
        }
        ClassRoomLog(@"WhiteBoradBoxViews ==> 删除白板 白板id:%d",wbid);
    }else {
        ClassRoomLog(@"WhiteBoradBoxViews ==> 未找到删除白板 白板id:%d",wbid);
    }
}



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
 * 白板数据更新之 画笔
 **/
- (void)whiteBoradWithPEN:(WhiteBoardActionModel *)wbModel
{
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
            self.currentWB.lineColor_ = [UIColor colorWithRed:GetRValue(lineColor)/255.0 green:GetGValue(lineColor)/255.0 blue:GetBValue(lineColor)/255.0 alpha:1];
            self.currentWB.lineWidth_ = lineWidth;
            ClassRoomLog(@"WhiteBoradBoxViews ==> 更新白板数据 => 画线 白板id:%d 画笔id:%d uid:%lld",wbModel.pageId,wbModel.paintId,wbModel.uid);
            [self.currentWB addPoints:poins paintID:wbModel.paintId userid:wbModel.uid];
        }
    }

}

/**
 * 白板数据更新之 橡皮擦
 **/
- (void)whiteBoradWithERASOR:(WhiteBoardActionModel *)wbModel
{
    NSData* jsData = [wbModel.jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsData) {
        id js = [NSJSONSerialization JSONObjectWithData:jsData options:NSJSONReadingMutableLeaves error:nil];
        if ([js isKindOfClass:[NSDictionary class]]) {
            int paintID = [js intForKey:ERASOR_ID];
            ClassRoomLog(@"WhiteBoradBoxViews ==> 更新白板数据 => 橡皮 画笔id:%d uid:%lld",wbModel.paintId,wbModel.uid);
            [self.currentWB removeLayerDiclayerForKey:paintID userid:wbModel.uid];
        }
    }
}


/**
 * 白板数据更新之 橡皮擦
 **/
- (void)whiteBoradWithTXT:(WhiteBoardActionModel *)wbModel
{
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
            self.currentWB.textColor_ = [UIColor colorWithRed:GetRValue(lineColor)/255.0 green:GetGValue(lineColor)/255.0 blue:GetBValue(lineColor)/255.0 alpha:1];
            ClassRoomLog(@"WhiteBoradBoxViews ==> 更新白板数据 => 文本 画笔id:%d uid:%lld",wbModel.paintId,wbModel.uid);
            [self.currentWB addTextLayer:text paintID:wbModel.paintId textRct:textRect userid:wbModel.uid];
        }
    }
}

- (void)updateWBdata:(WhiteBoardActionModel *)wbModel
{
    //更新 增/改/删笔画
    switch (wbModel.paintype) {
        case WhiteBoardEventModelType_PEN:
        {
            //画笔
            [self whiteBoradWithPEN:wbModel];
        }
            break;
        case WhiteBoardEventModelType_ERASOR:{
            //橡皮
            [self whiteBoradWithERASOR:wbModel];
        }
            break;
        case WhiteBoardEventModelType_TXT:
        {
            //文本
            [self whiteBoradWithTXT:wbModel];
        }
            break;
        case WhiteBoardEventModelType_LASER_POINT:
        {
            //激光指示
            
        }
            break;
        case WhiteBoardEventModelType_UNDO:{
            //撤销
            
            [self.currentWB removeLastLayer];
            
        }
            break;
        case WhiteBoardEventModelType_Clearn:
        {
            //清空
            ClassRoomLog(@"WhiteBoradBoxViews ==> 更新白板数据 => 移除全部");
            [self.currentWB removeAllLayerDiclayer];
        }
            break;
        default:
            break;
    }

}

#pragma mark-
#pragma mark- 更新白板涂鸦数据 返回YES 代表 属于白板涂鸦数据并更新 返回 NO为非白板数据(PDF涂鸦)
- (BOOL)updateWhiteBoradData:(WhiteBoardActionModel *)wbModel
{
    ClassRoomLog(@"WhiteBoradBoxViews ==> 更新白板数据 <删除笔画/增加笔画/增加文字>类型(1=> 画笔  2=> 橡皮 3=>文字 103  =>撤销 104 => 清空) type = %d",wbModel.paintype);
    
    int wbViewTag = wbModel.pageId + WB_MIN_TAG;
    self.currentWB = [self getWhiteBorad:wbViewTag autoCreate:NO];

    if (self.currentWB) {
        [self updateWBdata:wbModel];
    }else {
        return NO;
    }
    
    return YES;
}


#pragma mark-
#pragma mark- 切换显示模式为显示 白板
- (void)switchShowWhiteBorad:(int)wbid
{
    int wbViewTag = wbid + WB_MIN_TAG;
    if (self.currentWB) {
        self.currentWB.hidden = YES;
    }
    self.currentWB = [self getWhiteBorad:wbViewTag autoCreate:YES];
    self.currentWB.hidden = NO;
    [self updateFrame:self.bounds isAnimate:NO atWBViw:self.currentWB];
    ClassRoomLog(@"WhiteBoradBoxViews ==> 切换显示 白板id: %d",wbViewTag);

}

#pragma mark-
#pragma mark- 下课清除所有白板数据
- (void)cleanAllWhiteBorad
{
    self.currentWB = nil;
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DView *wbView = (DView *)obj;
        [wbView removeFromSuperview];
        wbView = nil;
    }];
}


@end
