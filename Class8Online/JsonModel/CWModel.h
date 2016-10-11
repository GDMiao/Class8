//
//  CWModel.h
//  Class8Online
//
//  Created by chuliangliang on 15/7/23.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//


/**
 * 在线课堂页 课件列表
 **/
#import "JSONModel.h"

typedef enum {
    CWStyle_PDF = 10,           //PDF
    CWStyle_IMG,                //图片
    CWStyle_Audio,              //音频
    CWStyle_Video,              //视频
}CWStyle;

typedef enum {
    CWLoadState_Wait = 20,      //等待下载
    CWLoadState_Loading,        //下载中
    CWLoadState_Fail,           //下载失败
    CWLoadState_Done,           //下砸完成
}CWLoadState;
@interface CWModel : JSONModel
@property (nonatomic, strong) NSString *cwName, //显示的课件名
*cwURLSubPath,                                  //下载路径
*cwOrigPath;                                    //原始内容 下载路径:文件名

@property (nonatomic, assign) CWStyle cwStyle;

@property (nonatomic, assign) CWLoadState loadState;

@property (nonatomic, assign) CGFloat progress; /*下载进度 等待/失败/完成 均为0 */



@end
