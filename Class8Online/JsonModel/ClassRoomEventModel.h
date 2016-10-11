//
//  ClassRoomEventModel.h
//  Class8Online
//
//  Created by chuliangliang on 15/5/21.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "JSONModel.h"

//====================================================
//TODO: 切换老师视频路数
//====================================================
@interface SetTeacherVedioModel : JSONModel
@property (assign, nonatomic) long long cid,uid;
@property (assign, nonatomic) int teachervedio; //显示老师第几路视频
@end

//=====================================================
//TODO: 白板行为
//=====================================================
typedef enum{
    WhiteBoardEventModelType_PEN = 1,   //画笔
    WhiteBoardEventModelType_ERASOR =2, //橡皮
    WhiteBoardEventModelType_TXT = 3,   //文字
    WhiteBoardEventModelType_LASER_POINT = 4,       //激光指示
    WhiteBoardEventModelType_UNDO = 103,            //撤销
    WhiteBoardEventModelType_Clearn = 104,          //全部清空
}WhiteBoardActionModelType;

@interface WhiteBoardActionModel : JSONModel
@property (assign, nonatomic) long long uid,owerid,cid;             //>50 != 0
@property (assign, nonatomic) int paintId;                          //第几笔
@property (nonatomic) int pageId;                                   //白板id
@property (assign, nonatomic) WhiteBoardActionModelType paintype;   //绘制类型
@property (strong, nonatomic) NSString *jsonString;                 //数据源
@end

//=====================================================
//TODO: 白板事件
//=====================================================
@interface WhiteBoardEventModel : JSONModel
@property (strong, nonatomic) WhiteBoardActionModel *wbActionModel;
@end

//=====================================================
//TODO: 设置课堂行为
//=====================================================
typedef enum {
    ClassActionModelType_ASK_SPEAK = 1,             //学生:举手
    ClassActionModelType_CANCEL_SPEAK = 2,          //学生:取消举手
    ClassActionModelType_ALLOW_SPEAK = 3,           //老师:允许发言
    ClassActionModelType_CLEAN_SPEAK = 4,           //老师:清除举手或发言状态
    ClassActionModelType_KICKOUT = 5,               //老师:把学生踢出房间
    ClassActionModelType_ADD_STUDENT_VIDEO = 6,     //老师:把学生添加到坐席区
    ClassActionModelType_DEL_STUDENT_VIDEO = 7,     //老师:把学生从坐席区删除
    ClassActionModelType_OPEN_VOICE = 8,            //打开声音
    ClassActionModelType_CLOSE_VOICE = 9,           //关闭声音
    ClassActionModelType_OPEN_VIDEO = 10,           //打开视频
    ClassActionModelType_CLOSE_VIDEO = 11,          //关闭视频
    ClassActionModelType_MUTE = 12,                 //禁言
    ClassActionModelType_UNMUTE = 13,               //关闭禁言
    ClassActionModelType_ENTER_GROUP = 14,          //进入分组
    ClassActionModelType_LEAVE_GROUP = 15,          //离开分组
    ClassActionModelType_CALL_TEACHER = 16,         //呼叫老师
    
}ClassActionModelType; //课堂行为

@interface ClassActionModel : JSONModel
@property (assign, nonatomic) long long uid,cid,teacherId; //进入和离开分组的时候，这个userid表示为分组的id

@property (assign, nonatomic) ClassActionModelType actiontype;//课堂行为类型
@end


//=====================================================
//TODO: 设置课堂模式 <禁止说话,打文字>
//=====================================================
typedef enum {
    SetClassMode_objType_UNSPEAKABLE = 0,           //禁止举手
    SetClassMode_objType_SPEAKABLE = 1,             //可举手
    SetClassMode_objType_TEXTABLE = 2,              //可聊天
    SetClassMode_objType_UTEXTABLE = 3,             //禁止聊天
    SetClassMode_objType_ASIDEABLE = 4,             //可旁听
    SetClassMode_objType_UNASIDEABLE = 5,           //不可旁听
    SetClassMode_Imageable = 8,                     //允许发图片
    SetClassMode_Imagedisable = 9,                  //禁止发图片
    SetClassMode_Lock = 16,                         //锁定
    SetClassMode_UnLock = 17,                       //解锁
    
}SetClassMode_objType;
@interface SetClassMode_obj : JSONModel
@property (assign, nonatomic) long long uid,cid;
@property (nonatomic) int classmode;
@end

//=====================================================
//TODO: 上下课
//=====================================================
typedef enum{
    SetClassStateModelType_CLASS_BEGIN = 2,         //上课
    SetClassStateModelType_CLASS_END = 4,           //下课
    
}SetClassStateModelType;
@interface SetClassStateModel : JSONModel
@property (assign, nonatomic) long long uid,cid,classid;
@property (assign, nonatomic) int ret;              //老师上下课操作返回状态码
@property (assign, nonatomic) SetClassStateModelType classstate;
@end

//=====================================================
//TODO: 添加课件
//=====================================================
typedef enum {
    AddCourseWareModelType_ADD = 1,                 //ADD
    AddCourseWareModelType_DEL = 2,                 //DEL
    AddCourseWareModelType_CLOSE = 3,               //CLOSE
}AddCourseWareModelType;

typedef enum{
    AddCourseWareSenderType_CLIENT = 1,             //来自客户端
    AddCourseWareSenderType_WEBSERVER= 2,           //来自web服务器
}AddCourseWareSenderType; //课件来源

@interface AddCourseWareModel : JSONModel
@property (assign, nonatomic) AddCourseWareModelType actiontype;
@property (assign, nonatomic) long long uid,cid;
@property (strong, nonatomic) NSString *cwtype, //课件类型
*cwname;//课件名
@property (assign, nonatomic) AddCourseWareSenderType senderType; //来源类型
@end

//=====================================================
//TODO: 创建白板
//=====================================================
typedef enum {
    CreateWhiteBoardModelType_ADD = 1,              //add
    CreateWhiteBoardModelType_DEL = 2,              //del
    CreateWhiteBoardModelType_MODIFY = 3,           //MODIFY<修改名字>
}CreateWhiteBoardModelType;

@interface CreateWhiteBoardModel : JSONModel
@property (assign, nonatomic) CreateWhiteBoardModelType actionytype;
@property (assign, nonatomic) int wbid; //白板id
@property (assign, nonatomic) long long courseId, //课程id
uid; //用户id
@property (strong, nonatomic) NSString *wbName; //白板名字
@end

//=====================================================
//TODO: 当前课堂展示的内容 <ppt/白板/主视频>
//=====================================================
typedef enum {
    
    CurrentShowModelType_BLANK = 0,                 //初始化界面
    CurrentShowModelType_COURSEWARE = 1,            //课件
    CurrentShowModelType_WHITEBOARD = 2,            //白板
    
}CurrentShowModelType;

@interface CurrentShowModel : JSONModel
@property (assign, nonatomic) int page;
@property (assign, nonatomic) CurrentShowModelType showType;
@property (strong, nonatomic) NSString *name;
@end

//=====================================================
//TODO: 课堂显示控制
//=====================================================
@interface SwitchClassShowModel : JSONModel
@property (assign, nonatomic) long long courseId, //课程id
uid; //用户id
@property(strong, nonatomic) CurrentShowModel *currentShow;
@end


//=====================================================
//TODO: 课堂主窗口展示控制
//=====================================================
typedef enum{
    MainShowType_CW_WB = 1,     //课件、白板
    MainShowType_VEDIO = 2,     //视频
}MainShowType;                  //主窗口展示类型
@interface SetMainShowModel : JSONModel
@property (assign, nonatomic) long long teacher,classid;
@property (assign, nonatomic) MainShowType showtype;
@end


//=====================================================
//TODO: 用户进入课堂 回调
//=====================================================

typedef enum {
    WelClassStateModelType_CLASS_NOT_ON = 0,        //未开始
    WelClassStateModelType_CLASS_WAIT_ON = 1,       //准备中
    WelClassStateModelType_CLASS__ON_NOT_BEGIN = 2, //正在进行,但未上课
    WelClassStateModelType_CLASS_ON_AND_BEGIN = 4,  //上课中

}WelClassStateModelType;

typedef enum {
    WelClassModelType_SPEAKABLE = 1,                //可以举手
    WelClassModelType_TEXTABLE = 2,                 //可以聊天
    WelClassModelType_ASIDEABLE = 4,                //都不可以
    
}WelClassModelType;

typedef enum{
    WelCode_SUCCESS = 0,                            //成功
    WelCode_ENTERTIME_NOT_COME=1,                   //未到进入课堂时间
    WelCode_CLASS_END=2,                            //课已结束
    WelCode_AUTHORITY_ERR=3,                        //权限不够
    WelCode_BLACKLIST = 4,                          //黑名单禁止入课堂
    WelCode_CLASSROOM_LOCKED = 5,                   //课堂加锁
}WelCode;                                           //进入课堂返回值
@interface UserWelecomeModel : JSONModel
@property (assign, nonatomic) WelCode retCode;                          //进入课堂返回Code
@property (assign, nonatomic) long long cid,teaUid,classid,askStuUID;   //askStuUID : 正在提问的学生的uid 默认为-1 代表无提问者
@property (assign, nonatomic) int durationtime,                         //上课持续时间,单位(分),从老师点上课算起
teachervedio,                                                           //显示老师的第几路视频
classmode,                                                              //是否能够举手发言,文字聊天
feedback,                                                               //是否评价过本节课 0：未评价 1：已评价
signSatate,                                                             //是否已签到 0:未签到 1:已签到 <已经弃用>
mainshow,                                                               //当前主窗口显示类型
timebeforeclass;                                                        //离计划上课还有多长时间，单位(分)
@property (strong, nonatomic) NSMutableArray *userlist,                 //学生列表 UserInfo中只填写了userid，authority，state，pushadd,pulladdr
*topvideolist,                                                          //顶部学生坐席区视屏列表 <iOS 端暂时不使用>
*cousewarelist,                                                         //课件列表
*whiteBoardActions;                                                     //白板操作teachervedio
@property (strong, nonatomic) NSString *cname,                          //课堂名
*c_Icon,                                                                //课堂icon
*teaVideoSrcUrl,                                                        //完整地址<包含教师三路视频 + 一路音频>
*code_text,                                                             //Code信息 暂时未解析
*userheadurl;                                                           //用户头像地址
@property (strong, nonatomic) CurrentShowModel *current;                //当前课主窗口
@property (assign, nonatomic) WelClassStateModelType classstate;        //上课/下课
@property (strong, nonatomic) NSDictionary *teacherVideoDic;            //教师的音视频地址
@property (strong, nonatomic) NSMutableDictionary *userListDic,         //课堂内部的学生 key : uid value: user对象
*userListWithVideoUrlDic;                                               //用户列表 保存的用户视频 key: uid value: 音视频地址
@end

//=====================================================
//TODO: 用户进入课堂
//=====================================================
@interface UserEnterModel : JSONModel

@property (assign, nonatomic) long long courseId; //课程id
@property (assign, nonatomic) int device; //设备
@property (nonatomic) char netisp; //网络运营商
@property (strong, nonatomic) User *user;
@end

//=====================================================
//TODO: 进入课堂时核实身份
//=====================================================
typedef enum{
    UserEnterRespCode_SUCCESS = 0,              //成功
    UserEnterRespCode_ENTERTIME_NOT_COME = 1,   //未到进入课堂时间
    UserEnterRespCode_CLASS_END = 2,            //课已结束
    UserEnterRespCode_AUTHORITY_ERR = 3,        //权限不够
}UserEnterRespCode; //返回结果枚举


@interface UserEnterRespModel : JSONModel
@property (assign, nonatomic) UserEnterRespCode retCode;    //返回code
@property (assign, nonatomic) long long cid,classid;        //课程id 、 课节id
@property (strong, nonatomic) NSString *cname;              //课程名
@property (assign, nonatomic) int feedback,                 //是否评价过本节课 0：未评价 1：已评价
device;                                                     //设备类型
@property (assign, nonatomic) NSString *userheadurl;        //用户头像
@property (assign, nonatomic) int netisp;                   //网络类型
@property (assign, nonatomic) User *user;                   //用户信息
@end


//=====================================================
//TODO: 用户离开课堂
//=====================================================
@interface UserLeaveModel : JSONModel
@property (assign, nonatomic) long long uid,    //用户id
cid,                                            //课堂id
inTime;                                         //本次进入到离开课堂的时长(秒)
@end

typedef enum{
    MsgRecvType_CLASS = 1,
    MsgRecvType_GROUP,
    MsgRecvType_USER,
}MsgRecvType; //消息接收类型

@interface SendTextMsgModel : JSONModel
@property (assign, nonatomic) long long courseId,uid,recvid,msgId;
@property (assign, nonatomic) MsgRecvType recvtype;
@property (assign, nonatomic) int recvgroupid; //分组id
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) long long time;
@property (assign, nonatomic) BOOL isMe;
@property (strong, nonatomic) NSDate *datetime;
@end
//======================================================
//TODO: 在线课堂事件
//======================================================
@interface ClassRoomEventModel : JSONModel

@end

