#pragma once

#include "rpcgen_account.h"


namespace rpcgen_account
{
	gnet::ProtocolManager::Stub* stubs[] =
	{
		new gnet::ProtocolManager::TStub<gnet::UserEnter>(),
		new gnet::ProtocolManager::TStub<gnet::UserEnterResp>(),
		new gnet::ProtocolManager::TStub<gnet::UserWelcome>(),
		new gnet::ProtocolManager::TStub<gnet::UserLeave>(),
		new gnet::ProtocolManager::TStub<gnet::SetMainShow>(),
		new gnet::ProtocolManager::TStub<gnet::SwitchClassShow>(),
		new gnet::ProtocolManager::TStub<gnet::CreateWhiteBoard>(),
		new gnet::ProtocolManager::TStub<gnet::AddCourseWare>(),
		new gnet::ProtocolManager::TStub<gnet::CreateTalkGroup>(),
		new gnet::ProtocolManager::TStub<gnet::SetClassState>(),
		new gnet::ProtocolManager::TStub<gnet::SetClassMode>(),
		new gnet::ProtocolManager::TStub<gnet::SendTextMsg>(),
		new gnet::ProtocolManager::TStub<gnet::ClassAction>(),
		new gnet::ProtocolManager::TStub<gnet::WhiteBoardEvent>(),
		new gnet::ProtocolManager::TStub<gnet::Error_>(),
		new gnet::ProtocolManager::TStub<gnet::EvaluateClass>(),
		new gnet::ProtocolManager::TStub<gnet::ClassInfoRsp>(),
		new gnet::ProtocolManager::TStub<gnet::ReturnCourse>(),
		new gnet::ProtocolManager::TStub<gnet::ReturnCourse>(),
		new gnet::ProtocolManager::TStub<gnet::KickOut>(),
		new gnet::ProtocolManager::TStub<gnet::MediaServerReq>(),
		new gnet::ProtocolManager::TStub<gnet::MediaServerResp>(),
		new gnet::ProtocolManager::TStub<gnet::MediaAddrNotify>(),
		new gnet::ProtocolManager::TStub<gnet::NotifyTalkGroup>(),
		new gnet::ProtocolManager::TStub<gnet::NotifyTalkGroupResp>(),
		new gnet::ProtocolManager::TStub<gnet::NotifyVideoList>(),
		new gnet::ProtocolManager::TStub<gnet::QueryPreCWares>(),
		new gnet::ProtocolManager::TStub<gnet::QueryPreCWares>(),
		new gnet::ProtocolManager::TStub<gnet::QueryPreCWaresResp>(),
		new gnet::ProtocolManager::TStub<gnet::QueryPreCWaresResp>(),
		new gnet::ProtocolManager::TStub<gnet::SetTeacherVedio>(),
		new gnet::ProtocolManager::TStub<gnet::KeepAlive>(),
		new gnet::ProtocolManager::TStub<gnet::RefreshVideoListReq>(),
		new gnet::ProtocolManager::TStub<gnet::RefreshVideoListResp>(),
		new gnet::ProtocolManager::TStub<gnet::MobileConnectClassReq>(),
		new gnet::ProtocolManager::TStub<gnet::MobileConnectClassResp>(),
		new gnet::ProtocolManager::TStub<gnet::UpdateCodeReq>(),
		new gnet::ProtocolManager::TStub<gnet::UpdateCodeResp>(),
		new gnet::ProtocolManager::TStub<gnet::ChooseMobile>(),
		new gnet::ProtocolManager::TStub<gnet::ChooseMobileResp>(),
		new gnet::ProtocolManager::TStub<gnet::Kick>(),
		new gnet::ProtocolManager::TStub<gnet::PromoteAsAssistant>(),
		new gnet::ProtocolManager::TStub<gnet::CancelAssistant>(),
		new gnet::ProtocolManager::TStub<gnet::MesgReminder>(),
		new gnet::ProtocolManager::TStub<gnet::UpdateCourseInfo>(),
		new gnet::ProtocolManager::TStub<gnet::ClassGoOn>(),
		new gnet::ProtocolManager::TStub<gnet::ClassRecord>(),
		new gnet::ProtocolManager::TStub<gnet::ClassRecord>(),
		new gnet::ProtocolManager::TStub<gnet::ClassDelayTimeOut>(),
		new gnet::ProtocolManager::TStub<gnet::CommitCourseWares>(),
		new gnet::ProtocolManager::TStub<gnet::Login>(),
		new gnet::ProtocolManager::TStub<gnet::LoginRet>(),
		new gnet::ProtocolManager::TStub<gnet::LoginRet_DB>(),
		new gnet::ProtocolManager::TStub<gnet::TokenValidate>(),
		new gnet::ProtocolManager::TStub<gnet::TokenValidateResp>(),
		new gnet::ProtocolManager::TStub<gnet::QueryUser>(),
		new gnet::ProtocolManager::TStub<gnet::ReturnUser>(),
		new gnet::ProtocolManager::TStub<gnet::QueryUserList>(),
		new gnet::ProtocolManager::TStub<gnet::QueryUserListResp>(),
		new gnet::ProtocolManager::TStub<gnet::QueryUserEdu>(),
		new gnet::ProtocolManager::TStub<gnet::ReturnUserEdu>(),
		new gnet::ProtocolManager::TStub<gnet::QueryCourse>(),
		new gnet::ProtocolManager::TStub<gnet::QueryToken>(),
		new gnet::ProtocolManager::TStub<gnet::ReturnToken>(),
		new gnet::ProtocolManager::TStub<gnet::FeedBack>(),
		new gnet::ProtocolManager::TStub<gnet::TranCursewave>(),
		new gnet::ProtocolManager::TStub<gnet::RTranCursewave>(),
		new gnet::ProtocolManager::TStub<gnet::MesgReq>(),
		new gnet::ProtocolManager::TStub<gnet::MesgResp>(),
		new gnet::ProtocolManager::TStub<gnet::QueryAutoLoginToken>(),
		new gnet::ProtocolManager::TStub<gnet::AutoLoginTokenRsp>(),
		new gnet::ProtocolManager::TStub<gnet::OnLineNotify>()
	};

	void RegisterProtocols()
	{
		int size = sizeof(stubs)/sizeof(*stubs);
		for (int i=0; i<size; i++)
			gnet::ProtocolManager::AddStub(stubs[i]);
	}

	void UnregisterProtocols()
	{
		int size = sizeof(stubs)/sizeof(*stubs);
		for (int i=0; i<size; i++)
			gnet::ProtocolManager::DelStub(stubs[i]);
	}

	struct ProtocolType2Name
	{
		unsigned	type;
		const char*	name;
	};

	ProtocolType2Name nameList[] =
	{
		{ gnet::UserEnter::PROTOCOL_TYPE, "UserEnter"},
		{ gnet::UserEnterResp::PROTOCOL_TYPE, "UserEnterResp"},
		{ gnet::UserWelcome::PROTOCOL_TYPE, "UserWelcome"},
		{ gnet::UserLeave::PROTOCOL_TYPE, "UserLeave"},
		{ gnet::SetMainShow::PROTOCOL_TYPE, "SetMainShow"},
		{ gnet::SwitchClassShow::PROTOCOL_TYPE, "SwitchClassShow"},
		{ gnet::CreateWhiteBoard::PROTOCOL_TYPE, "CreateWhiteBoard"},
		{ gnet::AddCourseWare::PROTOCOL_TYPE, "AddCourseWare"},
		{ gnet::CreateTalkGroup::PROTOCOL_TYPE, "CreateTalkGroup"},
		{ gnet::SetClassState::PROTOCOL_TYPE, "SetClassState"},
		{ gnet::SetClassMode::PROTOCOL_TYPE, "SetClassMode"},
		{ gnet::SendTextMsg::PROTOCOL_TYPE, "SendTextMsg"},
		{ gnet::ClassAction::PROTOCOL_TYPE, "ClassAction"},
		{ gnet::WhiteBoardEvent::PROTOCOL_TYPE, "WhiteBoardEvent"},
		{ gnet::Error_::PROTOCOL_TYPE, "Error_"},
		{ gnet::EvaluateClass::PROTOCOL_TYPE, "EvaluateClass"},
		{ gnet::ClassInfoRsp::PROTOCOL_TYPE, "ClassInfoRsp"},
		{ gnet::ReturnCourse::PROTOCOL_TYPE, "ReturnCourse"},
		{ gnet::ReturnCourse::PROTOCOL_TYPE, "ReturnCourse"},
		{ gnet::KickOut::PROTOCOL_TYPE, "KickOut"},
		{ gnet::MediaServerReq::PROTOCOL_TYPE, "MediaServerReq"},
		{ gnet::MediaServerResp::PROTOCOL_TYPE, "MediaServerResp"},
		{ gnet::MediaAddrNotify::PROTOCOL_TYPE, "MediaAddrNotify"},
		{ gnet::NotifyTalkGroup::PROTOCOL_TYPE, "NotifyTalkGroup"},
		{ gnet::NotifyTalkGroupResp::PROTOCOL_TYPE, "NotifyTalkGroupResp"},
		{ gnet::NotifyVideoList::PROTOCOL_TYPE, "NotifyVideoList"},
		{ gnet::QueryPreCWares::PROTOCOL_TYPE, "QueryPreCWares"},
		{ gnet::QueryPreCWares::PROTOCOL_TYPE, "QueryPreCWares"},
		{ gnet::QueryPreCWaresResp::PROTOCOL_TYPE, "QueryPreCWaresResp"},
		{ gnet::QueryPreCWaresResp::PROTOCOL_TYPE, "QueryPreCWaresResp"},
		{ gnet::SetTeacherVedio::PROTOCOL_TYPE, "SetTeacherVedio"},
		{ gnet::KeepAlive::PROTOCOL_TYPE, "KeepAlive"},
		{ gnet::RefreshVideoListReq::PROTOCOL_TYPE, "RefreshVideoListReq"},
		{ gnet::RefreshVideoListResp::PROTOCOL_TYPE, "RefreshVideoListResp"},
		{ gnet::MobileConnectClassReq::PROTOCOL_TYPE, "MobileConnectClassReq"},
		{ gnet::MobileConnectClassResp::PROTOCOL_TYPE, "MobileConnectClassResp"},
		{ gnet::UpdateCodeReq::PROTOCOL_TYPE, "UpdateCodeReq"},
		{ gnet::UpdateCodeResp::PROTOCOL_TYPE, "UpdateCodeResp"},
		{ gnet::ChooseMobile::PROTOCOL_TYPE, "ChooseMobile"},
		{ gnet::ChooseMobileResp::PROTOCOL_TYPE, "ChooseMobileResp"},
		{ gnet::Kick::PROTOCOL_TYPE, "Kick"},
		{ gnet::PromoteAsAssistant::PROTOCOL_TYPE, "PromoteAsAssistant"},
		{ gnet::CancelAssistant::PROTOCOL_TYPE, "CancelAssistant"},
		{ gnet::MesgReminder::PROTOCOL_TYPE, "MesgReminder"},
		{ gnet::UpdateCourseInfo::PROTOCOL_TYPE, "UpdateCourseInfo"},
		{ gnet::ClassGoOn::PROTOCOL_TYPE, "ClassGoOn"},
		{ gnet::ClassRecord::PROTOCOL_TYPE, "ClassRecord"},
		{ gnet::ClassRecord::PROTOCOL_TYPE, "ClassRecord"},
		{ gnet::ClassDelayTimeOut::PROTOCOL_TYPE, "ClassDelayTimeOut"},
		{ gnet::CommitCourseWares::PROTOCOL_TYPE, "CommitCourseWares"},
		{ gnet::Login::PROTOCOL_TYPE, "Login"},
		{ gnet::LoginRet::PROTOCOL_TYPE, "LoginRet"},
		{ gnet::LoginRet_DB::PROTOCOL_TYPE, "LoginRet_DB"},
		{ gnet::TokenValidate::PROTOCOL_TYPE, "TokenValidate"},
		{ gnet::TokenValidateResp::PROTOCOL_TYPE, "TokenValidateResp"},
		{ gnet::QueryUser::PROTOCOL_TYPE, "QueryUser"},
		{ gnet::ReturnUser::PROTOCOL_TYPE, "ReturnUser"},
		{ gnet::QueryUserList::PROTOCOL_TYPE, "QueryUserList"},
		{ gnet::QueryUserListResp::PROTOCOL_TYPE, "QueryUserListResp"},
		{ gnet::QueryUserEdu::PROTOCOL_TYPE, "QueryUserEdu"},
		{ gnet::ReturnUserEdu::PROTOCOL_TYPE, "ReturnUserEdu"},
		{ gnet::QueryCourse::PROTOCOL_TYPE, "QueryCourse"},
		{ gnet::QueryToken::PROTOCOL_TYPE, "QueryToken"},
		{ gnet::ReturnToken::PROTOCOL_TYPE, "ReturnToken"},
		{ gnet::FeedBack::PROTOCOL_TYPE, "FeedBack"},
		{ gnet::TranCursewave::PROTOCOL_TYPE, "TranCursewave"},
		{ gnet::RTranCursewave::PROTOCOL_TYPE, "RTranCursewave"},
		{ gnet::MesgReq::PROTOCOL_TYPE, "MesgReq"},
		{ gnet::MesgResp::PROTOCOL_TYPE, "MesgResp"},
		{ gnet::QueryAutoLoginToken::PROTOCOL_TYPE, "QueryAutoLoginToken"},
		{ gnet::AutoLoginTokenRsp::PROTOCOL_TYPE, "AutoLoginTokenRsp"},
		{ gnet::OnLineNotify::PROTOCOL_TYPE, "OnLineNotify"}
	};

	std::string FindProtocolName(unsigned int type)
	{
		int size = sizeof(nameList)/sizeof(*nameList);
		for (int i=0; i<size; i++)
		{
			if (nameList[i].type == type)
				return nameList[i].name;
		}
		return "";
	}
} 