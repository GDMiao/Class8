//
//  WXTestCell.h
//  Class8Online
//
//  Created by miaoguodong on 16/6/1.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXTestCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *appid;
@property (weak, nonatomic) IBOutlet UILabel *noncestr;
@property (weak, nonatomic) IBOutlet UILabel *package;
@property (weak, nonatomic) IBOutlet UILabel *partnerid;
@property (weak, nonatomic) IBOutlet UILabel *prepayid;
@property (weak, nonatomic) IBOutlet UILabel *sign;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;

@property (weak, nonatomic) IBOutlet UILabel *testAppID;
@property (weak, nonatomic) IBOutlet UILabel *testNoncestr;
@property (weak, nonatomic) IBOutlet UILabel *testPackage;
@property (weak, nonatomic) IBOutlet UILabel *testPartnerid;
@property (weak, nonatomic) IBOutlet UILabel *testPrepayid;
@property (weak, nonatomic) IBOutlet UILabel *testSign;
@property (weak, nonatomic) IBOutlet UILabel *testTimestamp;
+ (WXTestCell *)shareHeaderCell;
- (CGFloat)setWXtestCellcontentWith:(NSDictionary *)dit;

@end
