#ifndef __GNET_ERROR__H
#define __GNET_ERROR__H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class Error_ : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1013 };

		enum
		{
			CLASS_SERVER_DISCONNECT = 1,
			CLASS_NOT_SAVE = 2,
			CLASS_NOT_EXIST = 3,
		};

		int		errtype;
		int64_t		userid;
		int64_t		cid;
		int		device;
		Octets		token;
		char		netisp;

	public:
		Error_() { type = PROTOCOL_TYPE; }
		Error_(void*) : Protocol(PROTOCOL_TYPE) { }
		Error_ (int	l_errtype, int64_t	l_userid, int64_t	l_cid, int	l_device, const Octets& l_token, char	l_netisp)
		: errtype(l_errtype),
		userid(l_userid),
		cid(l_cid),
		device(l_device),
		token(l_token),
		netisp(l_netisp)
		{
			type = PROTOCOL_TYPE;
		}

		Error_(const Error_ &rhs)
			: Protocol(rhs),
			errtype(rhs.errtype),
			userid(rhs.userid),
			cid(rhs.cid),
			device(rhs.device),
			token(rhs.token),
			netisp(rhs.netisp){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << errtype;
			os << userid;
			os << cid;
			os << device;
			os << token;
			os << netisp;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> errtype;
			os >> userid;
			os >> cid;
			os >> device;
			os >> token;
			os >> netisp;
			return os;
		}

		virtual Protocol* Clone() const { return new Error_(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif