#ifndef __GNET_USERWELCOME_H
#define __GNET_USERWELCOME_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UserInfo.h"
#include "WhiteBoardAction.h"
#include "ShowInfo.h"


namespace GNET
{
	class UserWelcome : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1002 };

		enum
		{
			SPEAKABLE = 1,
			TEXTABLE = 2,
			ASIDEABLE = 4,
			CLASS_NOT_ON = 0,
			CLASS_WAIT_ON = 1,
			CLASS_ON_NOT_BEGIN = 2,
			CLASS_ON_AND_BEGIN = 4,
			CHAT_ALLOW = 1,
			SendIMAGE = 2,
			SUCCESS = 0,
			ENTERTIME_NOT_COME = 1,
			CLASS_END = 2,
			AUTHORITY_ERR = 3,
			BLACKLIST = 4,
			CLASSROOM_LOCKED = 5,
		};

		int64_t		receiver;
		int		ret;
		int64_t		cid;
		int64_t		classid;
		Octets		cname;
		Octets		userheadurl;
		int		feedback;
		std::vector<UserInfo>		userlist;
		std::vector<int64_t>		topvideolist;
		std::vector<Octets>		cousewarelist;
		std::vector<WhiteBoardAction>		whiteboard;
		char		mainshow;
		ShowInfo		currentshow;
		char		classstate;
		char		classmode;
		int		timebeforeclass;
		int		durationtime;
		int		teachervedio;
		Octets		code;

	public:
		UserWelcome() { type = PROTOCOL_TYPE; }
		UserWelcome(void*) : Protocol(PROTOCOL_TYPE) { }
		UserWelcome (int64_t	l_receiver, int	l_ret, int64_t	l_cid, int64_t	l_classid, const Octets& l_cname, const Octets& l_userheadurl, int	l_feedback, const std::vector<UserInfo>& l_userlist, const std::vector<int64_t>& l_topvideolist, const std::vector<Octets>& l_cousewarelist, const std::vector<WhiteBoardAction>& l_whiteboard, char	l_mainshow, const ShowInfo& l_currentshow, char	l_classstate, char	l_classmode, int	l_timebeforeclass, int	l_durationtime, int	l_teachervedio, const Octets& l_code)
		: receiver(l_receiver),
		ret(l_ret),
		cid(l_cid),
		classid(l_classid),
		cname(l_cname),
		userheadurl(l_userheadurl),
		feedback(l_feedback),
		userlist(l_userlist),
		topvideolist(l_topvideolist),
		cousewarelist(l_cousewarelist),
		whiteboard(l_whiteboard),
		mainshow(l_mainshow),
		currentshow(l_currentshow),
		classstate(l_classstate),
		classmode(l_classmode),
		timebeforeclass(l_timebeforeclass),
		durationtime(l_durationtime),
		teachervedio(l_teachervedio),
		code(l_code)
		{
			type = PROTOCOL_TYPE;
		}

		UserWelcome(const UserWelcome &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			ret(rhs.ret),
			cid(rhs.cid),
			classid(rhs.classid),
			cname(rhs.cname),
			userheadurl(rhs.userheadurl),
			feedback(rhs.feedback),
			userlist(rhs.userlist),
			topvideolist(rhs.topvideolist),
			cousewarelist(rhs.cousewarelist),
			whiteboard(rhs.whiteboard),
			mainshow(rhs.mainshow),
			currentshow(rhs.currentshow),
			classstate(rhs.classstate),
			classmode(rhs.classmode),
			timebeforeclass(rhs.timebeforeclass),
			durationtime(rhs.durationtime),
			teachervedio(rhs.teachervedio),
			code(rhs.code){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << ret;
			os << cid;
			os << classid;
			os << cname;
			os << userheadurl;
			os << feedback;
			os << userlist;
			os << topvideolist;
			os << cousewarelist;
			os << whiteboard;
			os << mainshow;
			os << currentshow;
			os << classstate;
			os << classmode;
			os << timebeforeclass;
			os << durationtime;
			os << teachervedio;
			os << code;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> ret;
			os >> cid;
			os >> classid;
			os >> cname;
			os >> userheadurl;
			os >> feedback;
			os >> userlist;
			os >> topvideolist;
			os >> cousewarelist;
			os >> whiteboard;
			os >> mainshow;
			os >> currentshow;
			os >> classstate;
			os >> classmode;
			os >> timebeforeclass;
			os >> durationtime;
			os >> teachervedio;
			os >> code;
			return os;
		}

		virtual Protocol* Clone() const { return new UserWelcome(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  655350; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif