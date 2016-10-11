#ifndef __GNET_TOKENVALIDATE_H
#define __GNET_TOKENVALIDATE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class TokenValidate : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 205 };

		enum
		{
			PC = 0,
			MOBILE = 1,
			WEB = 2,
		};

		int		linksid;
		int64_t		userid;
		int		devicetype;
		Octets		devicename;
		Octets		token;

	public:
		TokenValidate() { type = PROTOCOL_TYPE; }
		TokenValidate(void*) : Protocol(PROTOCOL_TYPE) { }
		TokenValidate (int	l_linksid, int64_t	l_userid, int	l_devicetype, const Octets& l_devicename, const Octets& l_token)
		: linksid(l_linksid),
		userid(l_userid),
		devicetype(l_devicetype),
		devicename(l_devicename),
		token(l_token)
		{
			type = PROTOCOL_TYPE;
		}

		TokenValidate(const TokenValidate &rhs)
			: Protocol(rhs),
			linksid(rhs.linksid),
			userid(rhs.userid),
			devicetype(rhs.devicetype),
			devicename(rhs.devicename),
			token(rhs.token){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << linksid;
			os << userid;
			os << devicetype;
			os << devicename;
			os << token;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> linksid;
			os >> userid;
			os >> devicetype;
			os >> devicename;
			os >> token;
			return os;
		}

		virtual Protocol* Clone() const { return new TokenValidate(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif