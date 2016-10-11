#ifndef __GNET_MOBILECONNECTCLASSREQ_H
#define __GNET_MOBILECONNECTCLASSREQ_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class MobileConnectClassReq : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1034 };

		int64_t		userid;
		Octets		devicename;
		Octets		code;

	public:
		MobileConnectClassReq() { type = PROTOCOL_TYPE; }
		MobileConnectClassReq(void*) : Protocol(PROTOCOL_TYPE) { }
		MobileConnectClassReq (int64_t	l_userid, const Octets& l_devicename, const Octets& l_code)
		: userid(l_userid),
		devicename(l_devicename),
		code(l_code)
		{
			type = PROTOCOL_TYPE;
		}

		MobileConnectClassReq(const MobileConnectClassReq &rhs)
			: Protocol(rhs),
			userid(rhs.userid),
			devicename(rhs.devicename),
			code(rhs.code){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << devicename;
			os << code;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> devicename;
			os >> code;
			return os;
		}

		virtual Protocol* Clone() const { return new MobileConnectClassReq(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif