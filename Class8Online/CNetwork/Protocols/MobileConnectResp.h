#ifndef __GNET_MOBILECONNECTRESP_H
#define __GNET_MOBILECONNECTRESP_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class MobileConnectResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1056 };

		int		sid;
		int		ret;
		int64_t		userid;
		Octets		link;

	public:
		MobileConnectResp() { type = PROTOCOL_TYPE; }
		MobileConnectResp(void*) : Protocol(PROTOCOL_TYPE) { }
		MobileConnectResp (int	l_sid, int	l_ret, int64_t	l_userid, const Octets& l_link)
		: sid(l_sid),
		ret(l_ret),
		userid(l_userid),
		link(l_link)
		{
			type = PROTOCOL_TYPE;
		}

		MobileConnectResp(const MobileConnectResp &rhs)
			: Protocol(rhs),
			sid(rhs.sid),
			ret(rhs.ret),
			userid(rhs.userid),
			link(rhs.link){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			os << ret;
			os << userid;
			os << link;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			os >> ret;
			os >> userid;
			os >> link;
			return os;
		}

		virtual Protocol* Clone() const { return new MobileConnectResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif