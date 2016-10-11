#ifndef __GNET_QUERYTOKEN_H
#define __GNET_QUERYTOKEN_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class QueryToken : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 2021 };

		int		sid;
		int64_t		userid;

	public:
		QueryToken() { type = PROTOCOL_TYPE; }
		QueryToken(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryToken (int	l_sid, int64_t	l_userid)
		: sid(l_sid),
		userid(l_userid)
		{
			type = PROTOCOL_TYPE;
		}

		QueryToken(const QueryToken &rhs)
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

		virtual Protocol* Clone() const { return new QueryToken(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif