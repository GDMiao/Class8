#ifndef __GNET_NOTIFYTALKGROUP_H
#define __GNET_NOTIFYTALKGROUP_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UIDList.h"


namespace GNET
{
	class NotifyTalkGroup : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1019 };

		enum
		{
			START = 1,
			END = 2,
			ENTER_GROUP = 14,
			LEAVE_GROUP = 15,
		};

		char		actionytype;
		int64_t		cid;
		std::map<int, UIDList>		grouplist;
		int64_t		userid;
		int		membercount;
		Octets		topic;
		int		groupid;

	public:
		NotifyTalkGroup() { type = PROTOCOL_TYPE; }
		NotifyTalkGroup(void*) : Protocol(PROTOCOL_TYPE) { }
		NotifyTalkGroup (char	l_actionytype, int64_t	l_cid, const std::map<int, UIDList>& l_grouplist, int64_t	l_userid, int	l_membercount, const Octets& l_topic, int	l_groupid)
		: actionytype(l_actionytype),
		cid(l_cid),
		grouplist(l_grouplist),
		userid(l_userid),
		membercount(l_membercount),
		topic(l_topic),
		groupid(l_groupid)
		{
			type = PROTOCOL_TYPE;
		}

		NotifyTalkGroup(const NotifyTalkGroup &rhs)
			: Protocol(rhs),
			actionytype(rhs.actionytype),
			cid(rhs.cid),
			grouplist(rhs.grouplist),
			userid(rhs.userid),
			membercount(rhs.membercount),
			topic(rhs.topic),
			groupid(rhs.groupid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << actionytype;
			os << cid;
			os << grouplist;
			os << userid;
			os << membercount;
			os << topic;
			os << groupid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> actionytype;
			os >> cid;
			os >> grouplist;
			os >> userid;
			os >> membercount;
			os >> topic;
			os >> groupid;
			return os;
		}

		virtual Protocol* Clone() const { return new NotifyTalkGroup(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif