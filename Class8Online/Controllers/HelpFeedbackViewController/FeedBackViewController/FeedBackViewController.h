//
//  FeedBackViewController.h
//  Class8Online
//
//  Created by miaoguodong on 16/3/21.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"

@interface FeedBackViewController : BasicViewController

@property (weak, nonatomic) IBOutlet UITextView *feedTextView;
@property (weak, nonatomic) IBOutlet UILabel *haveInput;
@property (weak, nonatomic) IBOutlet UILabel *currentWords;
@property (weak, nonatomic) IBOutlet UILabel *totalWords;
@property (weak, nonatomic) IBOutlet UILabel *words;
@property (weak, nonatomic) IBOutlet UILabel *placeholderL;





@end
