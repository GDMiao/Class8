#ifndef __GNET_QUERYUSERLISTRESP_H
#define __GNET_QUERYUSERLISTRESP_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UserInfo.h"


namespace GNET
{
	class QueryUserListResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1026 };

		int64_t		userid;
		int64_t		cid;
		std::vector<UserInfo>		userlist;

	public:
		QueryUserListResp() { type = PROTOCOL_TYPE; }
		QueryUserListResp(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryUserListResp (int64_t	l_userid, int64_t	l_cid, const std::vector<UserInfo>& l_userlist)
		: userid(l_userid),
		cid(l_cid),
		userlist(l_userlist)
		{
			type = PROTOCOL_TYPE;
		}

		QueryUserListResp(const QueryUserListResp &rhs)
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

		virtual Protocol* Clone() const { return new QueryUserListResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  655350; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif