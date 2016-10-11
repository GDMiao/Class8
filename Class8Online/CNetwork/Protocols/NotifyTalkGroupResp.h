#ifndef __GNET_NOTIFYTALKGROUPRESP_H
#define __GNET_NOTIFYTALKGROUPRESP_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class NotifyTalkGroupResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1020 };

		enum
		{
			START = 1,
			END = 2,
			ENTER_GROUP = 14,
			LEAVE_GROUP = 15,
		};

		char		actionytype;
		int64_t		cid;
		int		ret;
		int64_t		userid;
		int		membercount;
		Octets		topic;

	public:
		NotifyTalkGroupResp() { type = PROTOCOL_TYPE; }
		NotifyTalkGroupResp(void*) : Protocol(PROTOCOL_TYPE) { }
		NotifyTalkGroupResp (char	l_actionytype, int64_t	l_cid, int	l_ret, int64_t	l_userid, int	l_membercount, const Octets& l_topic)
		: actionytype(l_actionytype),
		cid(l_cid),
		ret(l_ret),
		userid(l_userid),
		membercount(l_membercount),
		topic(l_topic)
		{
			type = PROTOCOL_TYPE;
		}

		NotifyTalkGroupResp(const NotifyTalkGroupResp &rhs)
			: Protocol(rhs),
			actionytype(rhs.actionytype),
			cid(rhs.cid),
			ret(rhs.ret),
			userid(rhs.userid),
			membercount(rhs.membercount),
			topic(rhs.topic){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << actionytype;
			os << cid;
			os << ret;
			os << userid;
			os << membercount;
			os << topic;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> actionytype;
			os >> cid;
			os >> ret;
			os >> userid;
			os >> membercount;
			os >> topic;
			return os;
		}

		virtual Protocol* Clone() const { return new NotifyTalkGroupResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif