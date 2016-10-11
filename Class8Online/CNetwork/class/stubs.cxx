#ifdef SERVER_SOURCE
#include "binder.h"
#else
#include "gncompress.h"
#endif

#include "gnet.h"

namespace GNET
{
#ifdef SERVER_SOURCE
static ProtocolBinder  __ProtocolBinder_stub(PROTOCOL_BINDER, 65536);
#else
static CompressBinder  __CompressBinder_stub(PROTOCOL_COMPRESSBINDER);
#endif

static UserEnter    __stub_UserEnter((void*)0);
static UserEnterResp    __stub_UserEnterResp((void*)0);
static UserWelcome    __stub_UserWelcome((void*)0);
static UserLeave    __stub_UserLeave((void*)0);
static SetMainShow    __stub_SetMainShow((void*)0);
static SwitchClassShow    __stub_SwitchClassShow((void*)0);
static CreateWhiteBoard    __stub_CreateWhiteBoard((void*)0);
static AddCourseWare    __stub_AddCourseWare((void*)0);
static CreateTalkGroup    __stub_CreateTalkGroup((void*)0);
static SetClassState    __stub_SetClassState((void*)0);
static SetClassMode    __stub_SetClassMode((void*)0);
static SendTextMsg    __stub_SendTextMsg((void*)0);
static ClassAction    __stub_ClassAction((void*)0);
static WhiteBoardEvent    __stub_WhiteBoardEvent((void*)0);
static Error_    __stub_Error_((void*)0);
static EvaluateClass    __stub_EvaluateClass((void*)0);
static ClassInfoRsp    __stub_ClassInfoRsp((void*)0);
static ReturnCourse    __stub_ReturnCourse((void*)0);
static KickOut    __stub_KickOut((void*)0);
static MediaServerReq    __stub_MediaServerReq((void*)0);
static MediaServerResp    __stub_MediaServerResp((void*)0);
static MediaAddrNotify    __stub_MediaAddrNotify((void*)0);
static NotifyTalkGroup    __stub_NotifyTalkGroup((void*)0);
static NotifyTalkGroupResp    __stub_NotifyTalkGroupResp((void*)0);
static NotifyVideoList    __stub_NotifyVideoList((void*)0);
static QueryPreCWares    __stub_QueryPreCWares((void*)0);
static QueryPreCWaresResp    __stub_QueryPreCWaresResp((void*)0);
static SetTeacherVedio    __stub_SetTeacherVedio((void*)0);
static KeepAlive    __stub_KeepAlive((void*)0);
static RefreshVideoListReq    __stub_RefreshVideoListReq((void*)0);
static RefreshVideoListResp    __stub_RefreshVideoListResp((void*)0);
static MobileConnectClassReq    __stub_MobileConnectClassReq((void*)0);
static MobileConnectClassResp    __stub_MobileConnectClassResp((void*)0);
static UpdateCodeReq    __stub_UpdateCodeReq((void*)0);
static UpdateCodeResp    __stub_UpdateCodeResp((void*)0);
static ChooseMobile    __stub_ChooseMobile((void*)0);
static ChooseMobileResp    __stub_ChooseMobileResp((void*)0);
static Kick    __stub_Kick((void*)0);
static PromoteAsAssistant    __stub_PromoteAsAssistant((void*)0);
static CancelAssistant    __stub_CancelAssistant((void*)0);
static MesgReminder    __stub_MesgReminder((void*)0);
static UpdateCourseInfo    __stub_UpdateCourseInfo((void*)0);
static ClassGoOn    __stub_ClassGoOn((void*)0);
static ClassRecord    __stub_ClassRecord((void*)0);
static ClassDelayTimeOut    __stub_ClassDelayTimeOut((void*)0);
static CommitCourseWares    __stub_CommitCourseWares((void*)0);
static Login    __stub_Login((void*)0);
static LoginRet    __stub_LoginRet((void*)0);
static LoginRet_DB    __stub_LoginRet_DB((void*)0);
static TokenValidate    __stub_TokenValidate((void*)0);
static TokenValidateResp    __stub_TokenValidateResp((void*)0);
static QueryUser    __stub_QueryUser((void*)0);
static ReturnUser    __stub_ReturnUser((void*)0);
static QueryUserList    __stub_QueryUserList((void*)0);
static QueryUserListResp    __stub_QueryUserListResp((void*)0);
static QueryUserEdu    __stub_QueryUserEdu((void*)0);
static ReturnUserEdu    __stub_ReturnUserEdu((void*)0);
static QueryCourse    __stub_QueryCourse((void*)0);
static QueryToken    __stub_QueryToken((void*)0);
static ReturnToken    __stub_ReturnToken((void*)0);
static FeedBack    __stub_FeedBack((void*)0);
static MesgReq    __stub_MesgReq((void*)0);
static MesgResp    __stub_MesgResp((void*)0);
static QueryAutoLoginToken    __stub_QueryAutoLoginToken((void*)0);
static AutoLoginTokenRsp    __stub_AutoLoginTokenRsp((void*)0);
static OnLineNotify    __stub_OnLineNotify((void*)0);
static MobileConnectReq    __stub_MobileConnectReq((void*)0);
static MobileConnectResp    __stub_MobileConnectResp((void*)0);
static MobileOff    __stub_MobileOff((void*)0);
static QueryOnClasses    __stub_QueryOnClasses((void*)0);
static OnClassesResp    __stub_OnClassesResp((void*)0);



};
