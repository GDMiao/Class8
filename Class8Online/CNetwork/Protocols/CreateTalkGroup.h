#ifndef __GNET_CREATETALKGROUP_H
#define __GNET_CREATETALKGROUP_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UIDList.h"


namespace GNET
{
	class CreateTalkGroup : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1007 };

		enum
		{
			START = 1,
			END = 2,
			PRECREATE = 3,
			CANCEL = 4,
		};

		int64_t		receiver;
		int		ret;
		char		actionytype;
		int64_t		userid;
		int64_t		cid;
		int		membercount;
		std::map<int, UIDList>		grouplist;
		Octets		topic;

	public:
		CreateTalkGroup() { type = PROTOCOL_TYPE; }
		CreateTalkGroup(void*) : Protocol(PROTOCOL_TYPE) { }
		CreateTalkGroup (int64_t	l_receiver, int	l_ret, char	l_actionytype, int64_t	l_userid, int64_t	l_cid, int	l_membercount, const std::map<int, UIDList>& l_grouplist, const Octets& l_topic)
		: receiver(l_receiver),
		ret(l_ret),
		actionytype(l_actionytype),
		userid(l_userid),
		cid(l_cid),
		membercount(l_membercount),
		grouplist(l_grouplist),
		topic(l_topic)
		{
			type = PROTOCOL_TYPE;
		}

		CreateTalkGroup(const CreateTalkGroup &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			ret(rhs.ret),
			actionytype(rhs.actionytype),
			userid(rhs.userid),
			cid(rhs.cid),
			membercount(rhs.membercount),
			grouplist(rhs.grouplist),
			topic(rhs.topic){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << ret;
			os << actionytype;
			os << userid;
			os << cid;
			os << membercount;
			os << grouplist;
			os << topic;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> ret;
			os >> actionytype;
			os >> userid;
			os >> cid;
			os >> membercount;
			os >> grouplist;
			os >> topic;
			return os;
		}

		virtual Protocol* Clone() const { return new CreateTalkGroup(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif