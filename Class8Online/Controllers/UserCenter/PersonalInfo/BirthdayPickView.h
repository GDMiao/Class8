//
//  BirthdayPickView.h
//  Class8Online
//
//  Created by chuliangliang on 16/3/25.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BirthdayPickCallBack)(BOOL isCancel, NSDate *date); //NSString *birYear,NSString *birMonth,NSString *birDay
@interface BirthdayPickView : UIView
@property (copy, nonatomic) BirthdayPickCallBack block;

- (void)showOrHidden:(BOOL)show;
@end
