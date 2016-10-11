//
//  SignOutViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/6/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

typedef void (^ signOutCallBack) (int scores, NSString *text);
@interface SignOutViewController : BasicViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (copy, nonatomic) signOutCallBack callBack;
@end
