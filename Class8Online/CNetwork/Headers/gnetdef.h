#ifndef __GNETDEF_H__
#define __GNETDEF_H__

namespace GNET{

#define WM_IOEVENT      (0x400 + 100)
#define WM_IOPROTOCOL   (0x400 + 101)



#define _STATUS_OFFLINE         0
#define _STATUS_ONLINE          3
#define _STATUS_HIDDEN          6
#define _STATUS_BUSY            8
#define _STATUS_DEPART          9

#define _HANDLE_BEGIN       -1
#define _HANDLE_END         -1
#define _SID_INVALID        0

//邮件类型定义
#define _MA_UNREAD           0x0001
#define _MA_ATTACH_OBJ       0x0002
#define _MA_ATTACH_MONEY     0x0004
#define _MA_PRESERVE         0x0010
    
enum EVENT_VALUE
{

    
    
 EVENT_ADDSESSION  =  1,  
 EVENT_DELSESSION,
 EVENT_ABORTSESSION,
 EVENT_PINGRETURN,
 EVENT_DISCONNECT,
 
 EVENT_LOAD_SUCCESS, //class8 请求成功
 EVENT_LOAD_FAILD,  //class8  请求失败
    
 EVENT_ERRORINFO,
 EVENT_LOGIN_SUCCESS,
 EVENT_KICKOUTUSER,

 EVENT_UPDATEIMINFO,
 EVENT_RECVBUDDYBASEINFO,
 EVENT_CS_QUERYVIPINFORESP,

 EVENT_CS_HOTPROBLEMRESP,
 EVENT_CS_SIMILARPROBLEMRESP,
 EVENT_CS_PROBLEMANSWERRESP,
    
 EVENT_CS_SERVICERESP,
 EVENT_CS_SUBMITPHOTORESP,
 
 EVENT_CS_QUERYSTATUSRESP,
 EVENT_CS_QUERYCLEARSTORAGERESP,
    
    
        
};

    
enum ErrCode {
	ERR_SUCCESS = 0,            //成功
	ERR_TOBECONTINUE = 1,       //成功，并且还有更多数据未传递完，目前未用

	ERR_INVALID_ACCOUNT = 2,    //帐号不存在
	ERR_INVALID_PASSWORD = 3,   //密码错误
	ERR_TIMEOUT = 4,            //超时
	ERR_INVALID_ARGUMENT = 5,   //参数错误
	ERR_FRIEND_SYNCHRONIZE = 6, //好友信息保存到数据库时无法同步
	ERR_SERVERNOTSUPPLY = 7,    //该服务器不支持该请求
	ERR_COMMUNICATION=8,        //网络通讯错误
	ERR_ACCOUNTLOCKED=9,        //多次重复登陆，当前用户的一个登陆正在被处理，处于锁定状态
	ERR_MULTILOGIN  =10,        //多次重复登陆，且用户选择自动下线
	// keyexchange      
	ERR_INVALID_NONCE    = 11,  //无效的nonce值
    //logout
    ERR_LOGOUT_FAIL      = 12,  //AUTH登出失败
	// deliver use
	ERR_DELIVER_SEND     = 21,  //转发失败
	ERR_DELIVER_TIMEOUT  = 22,  //转发超时
    //login check
    ERR_IP_LOCK		   = 26,
    ERR_ID_LOCK		   = 27, //连续三次使用密保卡登录失败，暂时封停，稍后再尝试登录游戏
    ERR_MATRIXFAILURE	   = 28, //密保卡错误
    ERR_PASSWD_EXCEED          = 29, //输错密码的频率超过了deliver中的配置
    ERR_MATRIX_EXCEED          = 30, //输错密保卡的频率超过了deliver中的配置
	//player login
	ERR_LOGINFAIL   =   31,     //登陆游戏失败
	ERR_KICKOUT     =   32,     //被踢下线
	ERR_CREATEROLE  =   33,     //创建角色失败
	ERR_DELETEROLE  =   34,     //删除角色失败
	ERR_ROLELIST    =   35,     //获得角色列表失败
	ERR_UNDODELROLE =   36,     //撤销删除角色失败
	ERR_LINKISFULL	=	39,		//服务器人数已满
	//add friend
	ERR_ADDFRD_REQUEST     = 51,  //请求加为好友
	ERR_ADDFRD_REFUSE      = 52,  //拒绝加为好友
	ERR_ADDFRD_AGREE       = 53,  //同意加为好友
	ERR_ADDFRD_AGREEANDADD = 54,  //同意并希望将对方加为好友

	//QQ DB retcode
	ERR_FAILED            = 41,
	ERR_EXCEPTION         = 42,
	ERR_NOTFOUND          = 43,
	ERR_INVALIDHANDLE     = 44,
	ERR_DUPLICATRECORD    = 45,
	ERR_NOFREESPACE       = 46,

	//game DB
	ERR_DATANOTFIND            = 60,  //数据不存在        
	ERR_GENERAL		           = 61,
	ERR_PERMISSION_DENIED      = 63, 
	ERR_DATABASE_TIMEOUT       = 64,
	ERR_UNAVAILABLE            = 65,  //已婚人士不能删除角色
	ERR_CMDCOOLING             = 66,  //命令正在冷却中
    //faction error code (101-200)  
    ERR_FC_NETWORKERR       =   101,    //服务器网络通讯错误
    ERR_FC_INVALID_OPERATION=   102,    //无效的操作类型
    ERR_FC_OP_TIMEOUT       =   103,    //操作超时
    ERR_FC_CREATE_ALREADY   =   104,    //玩家已经是某个帮派的成员，不能再创建帮派
    ERR_FC_CREATE_DUP       =   105,    //帮派名称重复
    ERR_FC_DBFAILURE        =   106,    //数据库IO错误
    ERR_FC_NO_PRIVILEGE     =   107,    //没有相关操作的权限
	ERR_FC_INVALIDNAME      =   108,    //不能使用此名称
	ERR_FC_FULL             =   109,    //人数已达上限
    ERR_FC_APPLY_REJOIN     =   110,    //已经是某个帮派的成员，申请失败
    ERR_FC_JOIN_SUCCESS     =   111,    //成功加入帮派
    ERR_FC_JOIN_REFUSE      =   112,    //申请被拒绝
    ERR_FC_ACCEPT_REACCEPT  =   113,    //被批准加入帮派的玩家已经加入帮派
    ERR_FC_FACTION_NOTEXIST =   114,    //帮派不存在or玩家没有申请过加入本帮派
    ERR_FC_NOTAMEMBER       =   115,    //玩家不是本帮派的帮众
    ERR_FC_CHECKCONDITION   =   116,    //不满足操作条件，如SP不够，资金不够
    ERR_FC_DATAERROR        =   117,    //操作参数类型错误，客户端提交的操作参数格式错误
	ERR_FC_OFFLINE          =   118,    //玩家不在线
	ERR_FC_INVITEELEVEL     =   120,    //被邀请方级别不够，不能加入
	ERR_FC_PREDELSUCCESS    =   121,    //帮派解散成功，七天后正式解散
	ERR_FC_DISMISSWAITING   =   122,    //帮派正在解散中
	ERR_FC_INVITEENOFAMILY  =   123,    //被邀请人没有加入家族，不能邀请进入帮派
	ERR_FC_LEAVINGFAMILY    =   124,    //被邀请者离开家族不足七天，不能加入新的家族

	//敌对帮派错误代码
	ERR_FC_INFACTION 			=	125,
	ERR_HOSTILE_COOLING			=	126,  // 加为敌对帮派不足10小时，不能撤销敌对状态
	ERR_HOSTILE_ALREADY			=	127,  // 已经是敌对状态
	ERR_HOSTILE_FULL 			=	128,  // 敌对帮派数达到上限
	ERR_HOSTILE_PEER_FULL 		=	129,  // 对方敌对状态数达到上限
	ERR_HOSTILE_LEVEL_LIMIT		=	130,  // 两个帮派等级相差过大，不能进入敌对状态
	ERR_HOSTILE_ITEM 			=	131,  // 没有宣战物品
	ERR_HOSTILE_PROTECTED 		=	132,  // 特殊物品保护，不能进入敌对状态
	ERR_HOSTILE_PEER_PROTECTED 	=	133,  // 对方有特殊物品保护，不能进入敌对状态

	//聊天室错误代码
	ERR_CHAT_CREATE_FAILED     =   151, //创建失败
	ERR_CHAT_INVALID_SUBJECT   =   152, //非法主题
	ERR_CHAT_ROOM_NOT_FOUND    =   153, //聊天室不存在
	ERR_CHAT_JOIN_REFUSED      =   154, //加入请求被拒绝
	ERR_CHAT_INVITE_REFUSED    =   155, //聊天邀请被拒绝
	ERR_CHAT_INVALID_PASSWORD  =   156, //聊天室密码错误
	ERR_CHAT_INVALID_ROLE      =   157, //角色未找到
	ERR_CHAT_PERMISSION_DENY   =   158, //没有权限
	ERR_CHAT_EXCESSIVE         =   159, //加入聊天室过多
	ERR_CHAT_ROOM_FULL         =   160, //人数已达上限
	ERR_CHAT_SEND_FAILURE      =   161, //发送失败

    //跑商交易错误代码
	ERR_BUSINESS_MONEY_NOT_MATCH	=	175,   //钱不符合期望
	ERR_BUSINESS_MONEY_EXCEED		=	176,   //钱溢出，不允许买和卖
	ERR_BUSINESS_INVENTORY_IS_FULL	=	177, 
	ERR_BUSINESS_BUY_TOO_MUCH		=	178,   //买的太多,超过出货量
	
	ERR_SP_NOT_INIT            =   231, //系统没有初始化完成
    ERR_SP_SPARETIME           =   232, //剩余时间不满足挂售条件
    ERR_SP_INVA_POINT          =   233, //无效的挂售点数，必须是30元的整数倍
    ERR_SP_EXPIRED             =   234, //该点卡已经过期
    ERR_SP_NOMONEY             =   237, //虚拟币不足
    ERR_SP_SELLING             =   239, //点卡已经处于销售状态
    ERR_SP_MONEYEXCEED         =   242, //金钱数达到上限
    ERR_SP_BUYSELF             =   243, //不能购买自己挂售的点卡

    //城战错误代码
    ERR_BS_INVALIDROLE         =   260, //角色身份不符合
    ERR_BS_FAILED              =   261, //竞价失败
    ERR_BS_OUTOFSERVICE        =   262, //城战服务暂时不可用
	ERR_BS_NEWBIE_BANNED       =   263, //加入帮派72小时内不允许进入城战
	ERR_BS_ALREADYBID          =   265, //不能多次竞价
	ERR_BS_NOTBATTLECITY       =   266, //该地图没有开启城战
	ERR_BS_PROCESSBIDDING      =   267, //正在处理请求，请重试
	ERR_BS_BIDSELF             =   268, //不能对自己的领地竞价
	ERR_BS_BIDNOOWNERCITY      =   269, //有领地帮派不能对无主领地竞价
	ERR_BS_NOMONEY             =   270, //金币数不足
	ERR_BS_LEVELNOTENOUGH      =   271, //帮派级别不足
	ERR_BS_RANKNOTENOUGH       =   272, //帮派排名不足
	ERR_BS_CREDITNOTENOUGH     =   273, //帮派贡献度不足
	
	//战场错误代码
	ERR_BATTLE_TEAM_FULL		=	340,  // 队伍已满
	ERR_BATTLE_LEVEL_LIMIT		=	341,  // 玩家级别不够
	ERR_BATTLE_JOIN_ALREADY 	=	342,  // 玩家已经报名战场
	ERR_BATTLE_NOTEXIST			=	343,  // 战场不存在
	ERR_BATTLE_NOTINBATTLE		=	344,  // 玩家不在战场
	ERR_BATTLE_COOLTIME			=	345,  // 加入冷却
	ERR_BATTLE_JOINTIMES		=	346,  // 加入次数满
	ERR_BATTLE_NOTINGROUP		=	347,  // 不在队伍中
	ERR_BATTLE_FAILED			=	348,  // 操作失败
	ERR_BATTLE_PRIVILEDGE		=	349,  // 权限不够
	ERR_BATTLE_STATUS			=	350,  // 战场状态错误
	
};

#define _MSG_CONVERSATION   1
#define _MSG_ADDFRD_RQST    2
#define _MSG_ADDFRD_RE      3

#define _INFO_PUBLIC        1
#define _INFO_PRIVATE       2
#define _INFO_PROTECTED     3

enum{
	//Trade
	ERR_TRADE_PARTNER_OFFLINE=  68,     //对方已经下线
	ERR_TRADE_AGREE         =   0,      //同意交易
	ERR_TRADE_REFUSE        =   69,     //对方拒绝交易
	ERR_TRADE_BUSY_TRADER   =   70,     //trader 已经在交易中
	ERR_TRADE_DB_FAILURE    =   71,     //读写数据库失败
	ERR_TRADE_JOIN_IN       =   72,     //加入交易失败，交易对象的双方已经存在
	ERR_TRADE_INVALID_TRADER=   73,     //无效的交易者
	ERR_TRADE_ADDGOODS      =   74,     //增加交易物品失败
	ERR_TRADE_RMVGOODS      =   75,     //减少交易物品失败
	ERR_TRADE_READY_HALF    =   76,     //提交完成一半，等待对方提交
	ERR_TRADE_READY         =   77,     //提交完成
	ERR_TRADE_SUBMIT_FAIL   =   78,     //提交失败
	ERR_TRADE_CONFIRM_FAIL  =   79,     //确认失败
	ERR_TRADE_DONE          =   80,     //交易完成
	ERR_TRADE_HALFDONE      =   81,     //交易完成一半，等待另一方确认
	ERR_TRADE_DISCARDFAIL   =   82,     //取消交易失败
	ERR_TRADE_MOVE_FAIL     =   83,     //移动物品失败
	ERR_TRADE_SPACE         =   84,     //物品栏空间不足
	ERR_TRADE_SETPSSN       =   85,     //设置交易者财产错误
	ERR_TRADE_ATTACH_HALF   =   86,     //成功加入一个一个交易者
	ERR_TRADE_ATTACH_DONE   =   87,     //成功加入两个交易者
};

enum{
	ERR_COMBAT_MASTEROFFLINE = 1,       //对方帮主不在线
	ERR_COMBAT_NOPROSPERITY  = 2,       //帮派繁荣度不足
	ERR_COMBAT_COOLING       = 3,       //挑战命令冷却中
	ERR_COMBAT_BUSY          = 4,       //对方正在野战中
	ERR_COMBAT_LOWLEVEL      = 5,       //对方帮派等级不足2级
	
};

enum ERR_STOCK
{
    ERR_STOCK_CLOSED        = 1,        //元宝交易系统未开放
    ERR_STOCK_ACCOUNTBUSY   = 2,        //相关账户正在进行交易，请稍候
    ERR_STOCK_INVALIDINPUT  = 3,        //输入数据错误
    ERR_STOCK_OVERFLOW      = 4,        //超过金额上限
    ERR_STOCK_DATABASE      = 5,        //数据库忙，请稍候
    ERR_STOCK_NOTENOUGH     = 6,        //账户余额不足
	ERR_STOCK_MAXCOMMISSION = 7,        //交易数目已达上限
	ERR_STOCK_NOTFOUND      = 8,
	ERR_STOCK_CASHLOCKED    = 9,
	ERR_STOCK_CASHUNLOCKFAILED= 10,
};


#define _TRADE_END_TIMEOUT  0
#define _TRADE_END_NORMAL   1       

//player logout style
#define _PLAYER_LOGOUT_FULL 0
#define _PLAYER_LOGOUT_HALF 1

#define  _ROLE_STATUS_NORMAL    1

//玩家状态
enum
{
    ROLE_BASE_STATUS_DEFAULT	= 0x01, //正常
    ROLE_BASE_STATUS_DELETING   = 0x02, //正在删除
    ROLE_BASE_STATUS_DELETED	= 0x04, //已经删除
    ROLE_BASE_STATUS_BACKED		= 0x08, //玩家长期未登陆，数据在备份库中，此状态对客户端没用，玩家登陆时服务器根据此状态决定从哪里获取玩家数据
    ROLE_BASE_STATUS_NEWRETURN  = 0x10, //老玩家回归
};

enum FS_ERR
{
	// Friend error code (201-250)
	ERR_FS_OFFLINE          =  1,     //玩家不在线
	ERR_FS_REFUSE           =  2,     //被拒绝
	ERR_FS_TIMEOUT          =  3,     //超时
	ERR_FS_NOSPACE          =  4,     //无剩余空间
	ERR_FS_NOFOUND          =  5,     //未找到
	ERR_FS_ERRPARAM         =  6,     //参数错误
	ERR_FS_DUPLICATE        =  7,     //重复
};
enum PRIVATE_CHANNEL
{
	CHANNEL_NORMAL			= 0,		//非好友
	CHANNEL_NORMALRE		= 1,		//非好友自动回复
	CHANNEL_FRIEND			= 2,		//好友
	CHANNEL_FRIEND_RE		= 3,		//好友自动回复
	CHANNEL_USERINFO		= 4,		//好友相关信息
	CHANNEL_TEAM_RALLY		= 5,		//队伍集结点通知
};

enum AUCTION_INFORM
{
    _AUCTION_ITEM_SOLD,
    _AUCTION_BID_WIN,
    _AUCTION_BID_LOSE,
    _AUCTION_BID_CANCEL,
	_AUCTION_BID_TIMEOUT,   
};

enum BATTLE_INFORM
{
    _BATTLE_BONUS,           // 领地分红
    _BATTLE_WIN_PRIZE,       // 城战胜利,获得奖金
    _BATTLE_BID_FAILED,      // 竞价失败,退还押金
    _BATTLE_BID_WITHDRAW,    // 城战取消,退还押金
};

enum MAIL_SENDER_TYPE
{
    _MST_PLAYER=0,
    _MST_NPC,
    _MST_AUCTION,
    _MST_WEB,
    _MST_BATTLE,
    _MST_TYPE_NUM,
};

}

#endif	//	__GNETDEF_H__
