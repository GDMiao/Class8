//
//  UserDescriptionViewController.h
//  Class8Online
//
//  Created by 完美世界－李泽众 on 15/7/20.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

typedef void (^DescriptionCallBack) (NSString * description);

@interface UserDescriptionViewController : BasicViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (nonatomic,copy) DescriptionCallBack descriptionCallBack;
@property (assign, nonatomic) long long uid;
@property (strong, nonatomic) NSString *oldDescriptionTxt;

@end
