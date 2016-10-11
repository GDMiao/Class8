#ifndef __GNET_USERENTERRESP_H
#define __GNET_USERENTERRESP_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UserInfo.h"


namespace GNET
{
	class UserEnterResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1051 };

		enum
		{
			SUCCESS = 0,
			ENTERTIME_NOT_COME = 1,
			CLASS_END = 2,
			AUTHORITY_ERR = 3,
		};

		int64_t		receiver;
		int		ret;
		int64_t		cid;
		int64_t		classid;
		Octets		cname;
		int		feedback;
		int		device;
		char		netisp;
		UserInfo		userinfo;

	public:
		UserEnterResp() { type = PROTOCOL_TYPE; }
		UserEnterResp(void*) : Protocol(PROTOCOL_TYPE) { }
		UserEnterResp (int64_t	l_receiver, int	l_ret, int64_t	l_cid, int64_t	l_classid, const Octets& l_cname, int	l_feedback, int	l_device, char	l_netisp, const UserInfo& l_userinfo)
		: receiver(l_receiver),
		ret(l_ret),
		cid(l_cid),
		classid(l_classid),
		cname(l_cname),
		feedback(l_feedback),
		device(l_device),
		netisp(l_netisp),
		userinfo(l_userinfo)
		{
			type = PROTOCOL_TYPE;
		}

		UserEnterResp(const UserEnterResp &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			ret(rhs.ret),
			cid(rhs.cid),
			classid(rhs.classid),
			cname(rhs.cname),
			feedback(rhs.feedback),
			device(rhs.device),
			netisp(rhs.netisp),
			userinfo(rhs.userinfo){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << ret;
			os << cid;
			os << classid;
			os << cname;
			os << feedback;
			os << device;
			os << netisp;
			os << userinfo;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> ret;
			os >> cid;
			os >> classid;
			os >> cname;
			os >> feedback;
			os >> device;
			os >> netisp;
			os >> userinfo;
			return os;
		}

		virtual Protocol* Clone() const { return new UserEnterResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  2048; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif