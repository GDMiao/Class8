//
//  ClassRoomEventModel.m
//  Class8Online
//
//  Created by chuliangliang on 15/5/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//



#import "ClassRoomEventModel.h"


//====================================================
//TODO: 切换老师视频路数
//====================================================
@implementation SetTeacherVedioModel
- (void)dealloc { }
@end


//=====================================================
//TODO: 白板行为
//=====================================================
@implementation WhiteBoardActionModel

- (void)dealloc {
    self.jsonString = nil;
}

@end

//=====================================================
//TODO: 白板事件
//=====================================================
@implementation WhiteBoardEventModel
- (void)dealloc {
    self.wbActionModel = nil;
}
@end

//=====================================================
//TODO: 设置课堂行为
//=====================================================
@implementation ClassActionModel
- (void)dealloc {}
@end

//=====================================================
//TODO: 设置课堂模式 <禁止说话,打文字>
//=====================================================
@implementation SetClassMode_obj : JSONModel
- (void)dealloc {}
@end

//=====================================================
//TODO: 上下课
//=====================================================
@implementation SetClassStateModel : JSONModel
- (void)dealloc {}
@end

//=====================================================
//TODO: 添加课件
//=====================================================
@implementation AddCourseWareModel : JSONModel
- (void)dealloc {
    self.cwtype = nil;
    self.cwname = nil;
}
@end

//=====================================================
//TODO: 创建白板
//=====================================================
@implementation CreateWhiteBoardModel : JSONModel
- (void)dealloc {
    self.wbName = nil;
}
@end;

//=====================================================
//TODO: 当前课堂展示的内容 <ppt/白板/主视频>
//=====================================================
@implementation CurrentShowModel : JSONModel
- (void)dealloc {
    self.name = nil;
}
@end


//=====================================================
//TODO: 课堂显示控制
//=====================================================
@implementation SwitchClassShowModel : JSONModel
- (void)dealloc {
    self.currentShow = nil;
}
@end;

//=====================================================
//TODO: 课堂主窗口展示控制
//=====================================================
@implementation SetMainShowModel

- (void)dealloc
{

}
@end

//=====================================================
//TODO: 用户进入课堂 回调
//=====================================================
@implementation UserWelecomeModel

- (void)dealloc {
    self.userlist = nil;
    self.topvideolist = nil;
    self.cousewarelist = nil;
    self.whiteBoardActions = nil;    
    self.current = nil;
    self.cname = nil;
    self.teacherVideoDic = nil;
    self.userListDic = nil;
    self.teaVideoSrcUrl = nil;
}

@end


//=====================================================
//TODO: 用户进入课堂
//=====================================================
@implementation UserEnterModel

- (void)dealloc {
    self.user = nil;
}

@end


//=====================================================
//TODO: 进入课堂时核实身份
//=====================================================
@implementation UserEnterRespModel

- (void)dealloc {
    self.cname = nil;
    self.userheadurl = nil;
    self.user = nil;
}

@end


//=====================================================
//TODO: 用户离开课堂
//=====================================================
@implementation UserLeaveModel : JSONModel
@end


@implementation SendTextMsgModel
- (void)dealloc {
    self.text = nil;
}

@end

//======================================================
//TODO: 在线课堂事件
//======================================================
@implementation ClassRoomEventModel
- (void)dealloc {}
@end
