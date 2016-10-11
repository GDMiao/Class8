//
//  SchoolNoticeModel.h
//  Class8Online
//
//  Created by miaoguodong on 16/3/18.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

@interface SchoolNoticeModel : JSONModel

@property (strong, nonatomic) NSString *contentTxt,
*title,
*createTime,
*linkUrl;


@end


@interface SchoolNoticeList : JSONModel

@property (nonatomic ,strong) NSMutableArray *list;
@property (nonatomic, assign) BOOL hasMore;
- (void)addNoticeList:(SchoolNoticeList *)list;


@end