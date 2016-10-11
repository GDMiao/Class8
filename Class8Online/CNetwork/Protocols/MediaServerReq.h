#ifndef __GNET_MEDIASERVERREQ_H
#define __GNET_MEDIASERVERREQ_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UserInfo.h"


namespace GNET
{
	class MediaServerReq : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1017 };

		enum
		{
			STUDENT = 30,
			TEACHER = 40,
			CNC = 0,
			CT = 1,
			CNCANDCT = 2,
			OTHER = 3,
		};

		int64_t		cid;
		char		netisp;
		int		device;
		int		stu2vip;
		UserInfo		userinfo;

	public:
		MediaServerReq() { type = PROTOCOL_TYPE; }
		MediaServerReq(void*) : Protocol(PROTOCOL_TYPE) { }
		MediaServerReq (int64_t	l_cid, char	l_netisp, int	l_device, int	l_stu2vip, const UserInfo& l_userinfo)
		: cid(l_cid),
		netisp(l_netisp),
		device(l_device),
		stu2vip(l_stu2vip),
		userinfo(l_userinfo)
		{
			type = PROTOCOL_TYPE;
		}

		MediaServerReq(const MediaServerReq &rhs)
			: Protocol(rhs),
			cid(rhs.cid),
			netisp(rhs.netisp),
			device(rhs.device),
			stu2vip(rhs.stu2vip),
			userinfo(rhs.userinfo){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << cid;
			os << netisp;
			os << device;
			os << stu2vip;
			os << userinfo;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> cid;
			os >> netisp;
			os >> device;
			os >> stu2vip;
			os >> userinfo;
			return os;
		}

		virtual Protocol* Clone() const { return new MediaServerReq(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif