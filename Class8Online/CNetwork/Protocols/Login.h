#ifndef __GNET_LOGIN_H
#define __GNET_LOGIN_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class Login : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 201 };

		enum
		{
			PC = 0,
			IOS = 1,
			WEB = 2,
			ANDROID = 3,
			NAMEPASSWD = 3,
			TOKEN = 4,
		};

		int		sid;
		int		logintype;
		Octets		username;
		Octets		passwordmd5;
		int		devicetype;
		Octets		devicename;
		int64_t		userid;
		Octets		token;
		Octets		ip;

	public:
		Login() { type = PROTOCOL_TYPE; }
		Login(void*) : Protocol(PROTOCOL_TYPE) { }
		Login (int	l_sid, int	l_logintype, const Octets& l_username, const Octets& l_passwordmd5, int	l_devicetype, const Octets& l_devicename, int64_t	l_userid, const Octets& l_token, const Octets& l_ip)
		: sid(l_sid),
		logintype(l_logintype),
		username(l_username),
		passwordmd5(l_passwordmd5),
		devicetype(l_devicetype),
		devicename(l_devicename),
		userid(l_userid),
		token(l_token),
		ip(l_ip)
		{
			type = PROTOCOL_TYPE;
		}

		Login(const Login &rhs)
			: Protocol(rhs),
			sid(rhs.sid),
			logintype(rhs.logintype),
			username(rhs.username),
			passwordmd5(rhs.passwordmd5),
			devicetype(rhs.devicetype),
			devicename(rhs.devicename),
			userid(rhs.userid),
			token(rhs.token),
			ip(rhs.ip){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			os << logintype;
			os << username;
			os << passwordmd5;
			os << devicetype;
			os << devicename;
			os << userid;
			os << token;
			os << ip;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			os >> logintype;
			os >> username;
			os >> passwordmd5;
			os >> devicetype;
			os >> devicename;
			os >> userid;
			os >> token;
			os >> ip;
			return os;
		}

		virtual Protocol* Clone() const { return new Login(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif