#ifndef __GNET_QUERYAUTOLOGINTOKEN_H
#define __GNET_QUERYAUTOLOGINTOKEN_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class QueryAutoLoginToken : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 3006 };

		int64_t		userid;
		int		devicetype;
		Octets		devicename;

	public:
		QueryAutoLoginToken() { type = PROTOCOL_TYPE; }
		QueryAutoLoginToken(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryAutoLoginToken (int64_t	l_userid, int	l_devicetype, const Octets& l_devicename)
		: userid(l_userid),
		devicetype(l_devicetype),
		devicename(l_devicename)
		{
			type = PROTOCOL_TYPE;
		}

		QueryAutoLoginToken(const QueryAutoLoginToken &rhs)
			: Protocol(rhs),
			userid(rhs.userid),
			devicetype(rhs.devicetype),
			devicename(rhs.devicename){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << devicetype;
			os << devicename;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> devicetype;
			os >> devicename;
			return os;
		}

		virtual Protocol* Clone() const { return new QueryAutoLoginToken(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif