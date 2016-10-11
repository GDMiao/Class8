//
//  TimePickerView.h
//  TimePickerTest
//
//  Created by miaoguodong on 16/3/22.
//  Copyright © 2016年 miaoguodong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PickerBlock) (NSString *string);
@interface TimePickerView : UIView

@property (copy, nonatomic) PickerBlock myPickerblock;
@property (strong, nonatomic) NSDate *currentDate;
- (id)initWithFrame:(CGRect)frame withPickBlock:(PickerBlock)block;
- (void)showOrHidden:(BOOL)show;

@end
