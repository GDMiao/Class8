#ifndef __GNET_TOKENVALIDATERESP_H
#define __GNET_TOKENVALIDATERESP_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class TokenValidateResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 206 };

		int		linksid;
		int		retcode;
		int64_t		userid;

	public:
		TokenValidateResp() { type = PROTOCOL_TYPE; }
		TokenValidateResp(void*) : Protocol(PROTOCOL_TYPE) { }
		TokenValidateResp (int	l_linksid, int	l_retcode, int64_t	l_userid)
		: linksid(l_linksid),
		retcode(l_retcode),
		userid(l_userid)
		{
			type = PROTOCOL_TYPE;
		}

		TokenValidateResp(const TokenValidateResp &rhs)
			: Protocol(rhs),
			linksid(rhs.linksid),
			retcode(rhs.retcode),
			userid(rhs.userid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << linksid;
			os << retcode;
			os << userid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> linksid;
			os >> retcode;
			os >> userid;
			return os;
		}

		virtual Protocol* Clone() const { return new TokenValidateResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif