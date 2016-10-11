#ifndef __GNET_AUTOLOGINTOKENRSP_H
#define __GNET_AUTOLOGINTOKENRSP_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class AutoLoginTokenRsp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 3007 };

		int		retcode;
		int64_t		userid;
		Octets		token;

	public:
		AutoLoginTokenRsp() { type = PROTOCOL_TYPE; }
		AutoLoginTokenRsp(void*) : Protocol(PROTOCOL_TYPE) { }
		AutoLoginTokenRsp (int	l_retcode, int64_t	l_userid, const Octets& l_token)
		: retcode(l_retcode),
		userid(l_userid),
		token(l_token)
		{
			type = PROTOCOL_TYPE;
		}

		AutoLoginTokenRsp(const AutoLoginTokenRsp &rhs)
			: Protocol(rhs),
			retcode(rhs.retcode),
			userid(rhs.userid),
			token(rhs.token){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << retcode;
			os << userid;
			os << token;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> retcode;
			os >> userid;
			os >> token;
			return os;
		}

		virtual Protocol* Clone() const { return new AutoLoginTokenRsp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  2048; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif