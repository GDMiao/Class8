//
//  CourseWithCommentsView.h
//  Class8Online
//
//  Created by chuliangliang on 15/5/14.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLLRefreshHeadController.h"
#import "HttpRequest.h"

@class CommentList;
@interface CourseWithCommentsView : UIView<CLLRefreshHeadControllerDelegate,HttpRequestDelegate>
{
    HttpRequest *http_;
    BOOL isRefresh; //是否是下拉刷新
}
@property (nonatomic,strong)CLLRefreshHeadController *refreshControll;
@property (assign, nonatomic) CGFloat avgScore;
@property (strong, nonatomic) CommentList *dataList;
@property (assign, nonatomic) long long courseid;
@property (assign, nonatomic) UIViewController *viewController;
/**
 * 手动下拉刷新
 **/
- (void)startRefresh;

@end
