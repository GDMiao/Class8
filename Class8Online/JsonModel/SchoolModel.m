//
//  SchoolModel.m
//  Class8Online
//
//  Created by miaoguodong on 16/3/17.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#import "SchoolModel.h"

@implementation ADModel

- (void)dealloc
{
    self.imageURl = nil;
    self.webURL = nil;
}

- (void)parse:(NSDictionary *)json
{
    
}

@end

@implementation SchoolModel

- (void)dealloc
{
    self.schoolName = nil;
    self.logoUrl = nil;
    self.adList = nil;
}

- (void)parse:(NSDictionary *)json
{
    self.schoolInfodic = [json objectForKey:@"schoolInfo"];
    self.schoolName = [self.schoolInfodic stringForKey:@"name"];
    self.logoUrl = [self.schoolInfodic stringForKey:@"logoUrl"];
    self.schoolID = [json longForKey:@"schoolId"];
    self.courseNum = [json intForKey:@"countCourse"];
    self.teaNum = [json intForKey:@"countTeacher"];
    self.stuNum = [json intForKey:@"countStudent"];
    
    NSArray *bannerArr = [json arrayForKey:@"schoolBanners"];
    NSMutableArray *tempadlist = [[NSMutableArray alloc]init];
    for (int i = 0; i< 4; i++) {
        ADModel *admodel = [[ADModel alloc]init];
        admodel.imageURl = [bannerArr[i] stringForKey:@"bannerUrl"];
        admodel.webURL = [bannerArr[i] stringForKey:@"linkUrl"];
        [tempadlist addObject:admodel];
    }
    
    self.adList = tempadlist;
}


@end

const int courseListOnePageCount = 5;
@implementation schoollist

- (void)dealloc
{
    self.schoollist = nil;
}

- (void)parse:(NSDictionary *)json
{
    NSMutableArray *tempArr = [NSMutableArray array];
    
    NSArray *schList = [json objectForKey:@"result"];
    for (NSDictionary *dic in schList) {
        SchoolModel *model = [[SchoolModel alloc]initWithJSON:dic];
        [tempArr addObject:model];
    }
    self.schoollist = tempArr;

}

- (void)addSchoollist:(schoollist *)list
{
 
}

@end