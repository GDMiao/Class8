//
//  StudentListView.h
//  Class8Online
//
//  Created by chuliangliang on 15/8/3.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserChatBgView.h"
typedef void (^userDataCountBlock) (int count);
@interface StudentListView : UIView
{
    int userAllCount;
}
@property (assign, nonatomic) long long teaUID,courseid,classid;
@property (nonatomic, copy) userDataCountBlock uCountBlock;
@property (nonatomic, strong) UserChatBgView *uChatbgView;
- (id)initWithFrame:(CGRect)frame uCHatViewShowAtView:(UIView *)v;
- (id)initWithFrame:(CGRect)frame uCHatViewShowAtViewController:(UIViewController *)vc;
- (void)initTableData:(NSDictionary *)userDic;
- (void)insertUser:(User *)user;
- (void)delUser:(long long)uid;
- (void)deviceOrientation:(BOOL)down;
@end
