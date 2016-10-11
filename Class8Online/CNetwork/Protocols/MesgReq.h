#ifndef __GNET_MESGREQ_H
#define __GNET_MESGREQ_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class MesgReq : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 3004 };

		enum
		{
			System = 1,
			Personal = 2,
		};

		char		msgtype;
		int64_t		userid;

	public:
		MesgReq() { type = PROTOCOL_TYPE; }
		MesgReq(void*) : Protocol(PROTOCOL_TYPE) { }
		MesgReq (char	l_msgtype, int64_t	l_userid)
		: msgtype(l_msgtype),
		userid(l_userid)
		{
			type = PROTOCOL_TYPE;
		}

		MesgReq(const MesgReq &rhs)
			: Protocol(rhs),
			msgtype(rhs.msgtype),
			userid(rhs.userid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << msgtype;
			os << userid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> msgtype;
			os >> userid;
			return os;
		}

		virtual Protocol* Clone() const { return new MesgReq(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif