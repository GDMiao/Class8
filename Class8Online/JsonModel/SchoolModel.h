//
//  SchoolModel.h
//  Class8Online
//
//  Created by miaoguodong on 16/3/17.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

@interface ADModel : JSONModel

@property (strong, nonatomic) NSString *imageURl,*webURL;

@end




@interface SchoolModel : JSONModel

@property (assign, nonatomic) long long schoolID;    // 学校ID
@property (strong, nonatomic) NSDictionary *schoolInfodic; // 学校信息
@property (strong, nonatomic) NSString *schoolName;  // 学校名称
@property (strong, nonatomic) NSString *logoUrl;     // logo 链接
@property (assign, nonatomic) int courseNum;         // 课程数量
@property (assign, nonatomic) int teaNum;            // 教师数量
@property (assign, nonatomic) int stuNum;            // 学生数量
@property (strong, nonatomic) NSMutableDictionary *principalBasicInfo;

@property (strong, nonatomic) NSMutableArray *adList;       // 学校Banners广告位 url



@end

@interface schoollist : JSONModel

@property (strong, nonatomic) NSMutableArray *schoollist;
@property (nonatomic, assign) BOOL hasMore;
- (void)addSchoollist:(schoollist *)list;
@end