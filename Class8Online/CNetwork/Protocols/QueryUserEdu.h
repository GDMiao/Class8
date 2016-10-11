#ifndef __GNET_QUERYUSEREDU_H
#define __GNET_QUERYUSEREDU_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class QueryUserEdu : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 2003 };

		int		sid;
		int64_t		userid;

	public:
		QueryUserEdu() { type = PROTOCOL_TYPE; }
		QueryUserEdu(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryUserEdu (int	l_sid, int64_t	l_userid)
		: sid(l_sid),
		userid(l_userid)
		{
			type = PROTOCOL_TYPE;
		}

		QueryUserEdu(const QueryUserEdu &rhs)
			: Protocol(rhs),
			sid(rhs.sid),
			userid(rhs.userid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			os << userid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			os >> userid;
			return os;
		}

		virtual Protocol* Clone() const { return new QueryUserEdu(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif