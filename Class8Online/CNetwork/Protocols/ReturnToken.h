#ifndef __GNET_RETURNTOKEN_H
#define __GNET_RETURNTOKEN_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class ReturnToken : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 2022 };

		int		sid;
		int64_t		userid;
		int		retcode;
		Octets		token;
		int		validatetime;

	public:
		ReturnToken() { type = PROTOCOL_TYPE; }
		ReturnToken(void*) : Protocol(PROTOCOL_TYPE) { }
		ReturnToken (int	l_sid, int64_t	l_userid, int	l_retcode, const Octets& l_token, int	l_validatetime)
		: sid(l_sid),
		userid(l_userid),
		retcode(l_retcode),
		token(l_token),
		validatetime(l_validatetime)
		{
			type = PROTOCOL_TYPE;
		}

		ReturnToken(const ReturnToken &rhs)
			: Protocol(rhs),
			sid(rhs.sid),
			userid(rhs.userid),
			retcode(rhs.retcode),
			token(rhs.token),
			validatetime(rhs.validatetime){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			os << userid;
			os << retcode;
			os << token;
			os << validatetime;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			os >> userid;
			os >> retcode;
			os >> token;
			os >> validatetime;
			return os;
		}

		virtual Protocol* Clone() const { return new ReturnToken(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif