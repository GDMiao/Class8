#include "callid.hxx"
#if SERVER_SOURCE
#include "protocol.h"
#include "binder.h"
#else
#include "gnproto.h"
#include "gncompress.h"
#endif


namespace GNET
{

static GNET::Protocol::Type _state_GLoginClient[] = 
{
UserEnter::PROTOCOL_TYPE,
UserEnterResp::PROTOCOL_TYPE,
UserWelcome::PROTOCOL_TYPE,
UserLeave::PROTOCOL_TYPE,
SetMainShow::PROTOCOL_TYPE,
SwitchClassShow::PROTOCOL_TYPE,
CreateWhiteBoard::PROTOCOL_TYPE,
AddCourseWare::PROTOCOL_TYPE,
CreateTalkGroup::PROTOCOL_TYPE,
SetClassState::PROTOCOL_TYPE,
SetClassMode::PROTOCOL_TYPE,
SendTextMsg::PROTOCOL_TYPE,
ClassAction::PROTOCOL_TYPE,
WhiteBoardEvent::PROTOCOL_TYPE,
Error_::PROTOCOL_TYPE,
EvaluateClass::PROTOCOL_TYPE,
ClassInfoRsp::PROTOCOL_TYPE,
ReturnCourse::PROTOCOL_TYPE,
ReturnCourse::PROTOCOL_TYPE,
KickOut::PROTOCOL_TYPE,
MediaServerReq::PROTOCOL_TYPE,
MediaServerResp::PROTOCOL_TYPE,
MediaAddrNotify::PROTOCOL_TYPE,
NotifyTalkGroup::PROTOCOL_TYPE,
NotifyTalkGroupResp::PROTOCOL_TYPE,
NotifyVideoList::PROTOCOL_TYPE,
QueryPreCWares::PROTOCOL_TYPE,
QueryPreCWares::PROTOCOL_TYPE,
QueryPreCWaresResp::PROTOCOL_TYPE,
QueryPreCWaresResp::PROTOCOL_TYPE,
SetTeacherVedio::PROTOCOL_TYPE,
KeepAlive::PROTOCOL_TYPE,
RefreshVideoListReq::PROTOCOL_TYPE,
RefreshVideoListResp::PROTOCOL_TYPE,
MobileConnectClassReq::PROTOCOL_TYPE,
MobileConnectClassResp::PROTOCOL_TYPE,
UpdateCodeReq::PROTOCOL_TYPE,
UpdateCodeResp::PROTOCOL_TYPE,
ChooseMobile::PROTOCOL_TYPE,
ChooseMobileResp::PROTOCOL_TYPE,
Kick::PROTOCOL_TYPE,
PromoteAsAssistant::PROTOCOL_TYPE,
CancelAssistant::PROTOCOL_TYPE,
MesgReminder::PROTOCOL_TYPE,
UpdateCourseInfo::PROTOCOL_TYPE,
ClassGoOn::PROTOCOL_TYPE,
ClassRecord::PROTOCOL_TYPE,
ClassRecord::PROTOCOL_TYPE,
ClassDelayTimeOut::PROTOCOL_TYPE,
CommitCourseWares::PROTOCOL_TYPE,
Login::PROTOCOL_TYPE,
LoginRet::PROTOCOL_TYPE,
LoginRet_DB::PROTOCOL_TYPE,
TokenValidate::PROTOCOL_TYPE,
TokenValidateResp::PROTOCOL_TYPE,
QueryUser::PROTOCOL_TYPE,
ReturnUser::PROTOCOL_TYPE,
QueryUserList::PROTOCOL_TYPE,
QueryUserListResp::PROTOCOL_TYPE,
QueryUserEdu::PROTOCOL_TYPE,
ReturnUserEdu::PROTOCOL_TYPE,
QueryCourse::PROTOCOL_TYPE,
QueryToken::PROTOCOL_TYPE,
ReturnToken::PROTOCOL_TYPE,
FeedBack::PROTOCOL_TYPE,
MesgReq::PROTOCOL_TYPE,
MesgResp::PROTOCOL_TYPE,
QueryAutoLoginToken::PROTOCOL_TYPE,
AutoLoginTokenRsp::PROTOCOL_TYPE,
OnLineNotify::PROTOCOL_TYPE,
MobileConnectReq::PROTOCOL_TYPE,
MobileConnectResp::PROTOCOL_TYPE,
MobileOff::PROTOCOL_TYPE,
QueryOnClasses::PROTOCOL_TYPE,
OnClassesResp::PROTOCOL_TYPE,


};


GNET::Protocol::Manager::Session::State state_GLoginClient(_state_GLoginClient, 
				#ifdef SERVER_SOURCE
				sizeof(_state_GLoginClient) / sizeof(GNET::Protocol::Type), 120,"GLoginClient");
				#else
				sizeof(_state_GLoginClient) / sizeof(GNET::Protocol::Type), 120);
				#endif



};
