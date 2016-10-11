//
//  LiveViewController.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "BasicViewController.h"
#import "LiveVCTopContentView.h"

@interface LiveViewController : BasicViewController
-(id)initWithRoomName:(NSString *)roomName coureid:(long long)cid classid:(long long)classid;
@property (weak, nonatomic) IBOutlet LiveVCTopContentView *topContenView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end
