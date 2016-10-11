#ifndef __GNET_QUERYUSERLIST_H
#define __GNET_QUERYUSERLIST_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class QueryUserList : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1025 };

		int64_t		userid;
		int64_t		cid;
		std::vector<int64_t>		userlist;

	public:
		QueryUserList() { type = PROTOCOL_TYPE; }
		QueryUserList(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryUserList (int64_t	l_userid, int64_t	l_cid, const std::vector<int64_t>& l_userlist)
		: userid(l_userid),
		cid(l_cid),
		userlist(l_userlist)
		{
			type = PROTOCOL_TYPE;
		}

		QueryUserList(const QueryUserList &rhs)
			: Protocol(rhs),
			userid(rhs.userid),
			cid(rhs.cid),
			userlist(rhs.userlist){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << cid;
			os << userlist;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> cid;
			os >> userlist;
			return os;
		}

		virtual Protocol* Clone() const { return new QueryUserList(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  102400; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif