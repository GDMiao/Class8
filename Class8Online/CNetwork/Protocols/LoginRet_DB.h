#ifndef __GNET_LOGINRET_DB_H
#define __GNET_LOGINRET_DB_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class LoginRet_DB : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 203 };

		enum
		{
			OK = 0,
			INVALID_PARAM = -1,
			INVALID_USERNAME = -2,
			INVALID_PASSWORD = -3,
			INVALID_TOKEN = -4,
			UIDDEVICE_NOT_EXIST = -5,
			USER_FROZEN = -6,
			LOGIN_ERR_MUCH_OF_DAY = -7,
			SERVER_ERROR = -100,
		};

		int		sid;
		int		retcode;
		int64_t		userid;
		int		usertype;
		Octets		token;

	public:
		LoginRet_DB() { type = PROTOCOL_TYPE; }
		LoginRet_DB(void*) : Protocol(PROTOCOL_TYPE) { }
		LoginRet_DB (int	l_sid, int	l_retcode, int64_t	l_userid, int	l_usertype, const Octets& l_token)
		: sid(l_sid),
		retcode(l_retcode),
		userid(l_userid),
		usertype(l_usertype),
		token(l_token)
		{
			type = PROTOCOL_TYPE;
		}

		LoginRet_DB(const LoginRet_DB &rhs)
			: Protocol(rhs),
			sid(rhs.sid),
			retcode(rhs.retcode),
			userid(rhs.userid),
			usertype(rhs.usertype),
			token(rhs.token){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			os << retcode;
			os << userid;
			os << usertype;
			os << token;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			os >> retcode;
			os >> userid;
			os >> usertype;
			os >> token;
			return os;
		}

		virtual Protocol* Clone() const { return new LoginRet_DB(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif