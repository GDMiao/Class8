//
//  JSonModel.h
//  Class8Online
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONParse.h"
#import "NSDictionary+JSON.h"

typedef enum
{
    RepStatus_Success = 0,  /*成功*/
    RepStatus_Faild,        /*失败*/
}RepStatus;

@interface JSONModel : NSObject<JSONParse>

//返回代码,0为成功,否则 错误
@property(assign,nonatomic) int code_;
//返回消息
@property(assign,nonatomic) double SysCurMills;//服务器时间的毫秒数
@property(strong,nonatomic) NSString *message_;
//接口返回的字符串解析为json对象.
@property(strong,nonatomic) NSDictionary *json_;
//使用JSON构造
-(id)initWithJSON:(NSDictionary *) json;

@end
