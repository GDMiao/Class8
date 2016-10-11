//
//  MediaPreView.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/13.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaPreView : UIView
@property (nonatomic, strong) NSString *audioPath;
- (void)resetMdeiaPlay; /*重置播放器*/
- (void)stop;
- (void)play;
- (void)pause;
- (void)playAtTime:(float)time;
- (void)showTitle:(NSString *)text; /*弃用*/
@end
