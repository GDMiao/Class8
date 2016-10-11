#ifndef __GNET_CANCELASSISTANT_H
#define __GNET_CANCELASSISTANT_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class CancelAssistant : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1042 };

		int64_t		receiver;
		int64_t		tid;
		int64_t		userid;
		int64_t		cid;

	public:
		CancelAssistant() { type = PROTOCOL_TYPE; }
		CancelAssistant(void*) : Protocol(PROTOCOL_TYPE) { }
		CancelAssistant (int64_t	l_receiver, int64_t	l_tid, int64_t	l_userid, int64_t	l_cid)
		: receiver(l_receiver),
		tid(l_tid),
		userid(l_userid),
		cid(l_cid)
		{
			type = PROTOCOL_TYPE;
		}

		CancelAssistant(const CancelAssistant &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			tid(rhs.tid),
			userid(rhs.userid),
			cid(rhs.cid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << tid;
			os << userid;
			os << cid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> tid;
			os >> userid;
			os >> cid;
			return os;
		}

		virtual Protocol* Clone() const { return new CancelAssistant(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif