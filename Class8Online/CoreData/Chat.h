//
//  Chat.h
//  Class8Online
//
//  Created by chuliangliang on 15/6/3.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chat : NSManagedObject

@property (nonatomic, retain) NSNumber * courseID;
@property (nonatomic, retain) NSNumber * isMe;
@property (nonatomic, retain) NSNumber * isSystemMsg;
@property (nonatomic, retain) NSNumber * msgId;
@property (nonatomic, retain) NSNumber * recUserid;
@property (nonatomic, retain) NSNumber * recvgroupid;
@property (nonatomic, retain) NSNumber * recvtype;
@property (nonatomic, retain) NSNumber * sendUserid;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * sendUserNick;
@property (nonatomic, retain) NSNumber * loginUid;

@end
