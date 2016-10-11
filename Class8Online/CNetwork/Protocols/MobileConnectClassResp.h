#ifndef __GNET_MOBILECONNECTCLASSRESP_H
#define __GNET_MOBILECONNECTCLASSRESP_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class MobileConnectClassResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1035 };

		enum
		{
			OK = 0,
			CODE_INVALID = 1,
			TEACHER_NOT_EXIST = 2,
			CONNECTION_OUT_OF_RANGE = 3,
		};

		int64_t		receiver;
		int		ret;
		int64_t		userid;
		int64_t		tid;
		Octets		devicename;
		int64_t		cid;

	public:
		MobileConnectClassResp() { type = PROTOCOL_TYPE; }
		MobileConnectClassResp(void*) : Protocol(PROTOCOL_TYPE) { }
		MobileConnectClassResp (int64_t	l_receiver, int	l_ret, int64_t	l_userid, int64_t	l_tid, const Octets& l_devicename, int64_t	l_cid)
		: receiver(l_receiver),
		ret(l_ret),
		userid(l_userid),
		tid(l_tid),
		devicename(l_devicename),
		cid(l_cid)
		{
			type = PROTOCOL_TYPE;
		}

		MobileConnectClassResp(const MobileConnectClassResp &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			ret(rhs.ret),
			userid(rhs.userid),
			tid(rhs.tid),
			devicename(rhs.devicename),
			cid(rhs.cid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << ret;
			os << userid;
			os << tid;
			os << devicename;
			os << cid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> ret;
			os >> userid;
			os >> tid;
			os >> devicename;
			os >> cid;
			return os;
		}

		virtual Protocol* Clone() const { return new MobileConnectClassResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif