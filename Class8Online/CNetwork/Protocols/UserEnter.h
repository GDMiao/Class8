#ifndef __GNET_USERENTER_H
#define __GNET_USERENTER_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UserInfo.h"


namespace GNET
{
	class UserEnter : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1001 };

		int64_t		receiver;
		int64_t		cid;
		int64_t		classid;
		int		device;
		char		netisp;
		UserInfo		userinfo;

	public:
		UserEnter() { type = PROTOCOL_TYPE; }
		UserEnter(void*) : Protocol(PROTOCOL_TYPE) { }
		UserEnter (int64_t	l_receiver, int64_t	l_cid, int64_t	l_classid, int	l_device, char	l_netisp, const UserInfo& l_userinfo)
		: receiver(l_receiver),
		cid(l_cid),
		classid(l_classid),
		device(l_device),
		netisp(l_netisp),
		userinfo(l_userinfo)
		{
			type = PROTOCOL_TYPE;
		}

		UserEnter(const UserEnter &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			cid(rhs.cid),
			classid(rhs.classid),
			device(rhs.device),
			netisp(rhs.netisp),
			userinfo(rhs.userinfo){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << cid;
			os << classid;
			os << device;
			os << netisp;
			os << userinfo;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> cid;
			os >> classid;
			os >> device;
			os >> netisp;
			os >> userinfo;
			return os;
		}

		virtual Protocol* Clone() const { return new UserEnter(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif