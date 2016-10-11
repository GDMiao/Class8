//
//  CacheFile.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/28.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CacheFile : NSManagedObject

@property (nonatomic, retain) NSDate * lastOpenTime;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * fileType;

@end
