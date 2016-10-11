#ifndef __GNET_PROMOTEASASSISTANT_H
#define __GNET_PROMOTEASASSISTANT_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class PromoteAsAssistant : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1041 };

		enum
		{
			SUCCESS = 1,
			ASSISTANT_EXISTED = 2,
		};

		int64_t		receiver;
		int		ret;
		int64_t		tid;
		int64_t		userid;
		int64_t		cid;

	public:
		PromoteAsAssistant() { type = PROTOCOL_TYPE; }
		PromoteAsAssistant(void*) : Protocol(PROTOCOL_TYPE) { }
		PromoteAsAssistant (int64_t	l_receiver, int	l_ret, int64_t	l_tid, int64_t	l_userid, int64_t	l_cid)
		: receiver(l_receiver),
		ret(l_ret),
		tid(l_tid),
		userid(l_userid),
		cid(l_cid)
		{
			type = PROTOCOL_TYPE;
		}

		PromoteAsAssistant(const PromoteAsAssistant &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			ret(rhs.ret),
			tid(rhs.tid),
			userid(rhs.userid),
			cid(rhs.cid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << ret;
			os << tid;
			os << userid;
			os << cid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> ret;
			os >> tid;
			os >> userid;
			os >> cid;
			return os;
		}

		virtual Protocol* Clone() const { return new PromoteAsAssistant(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif