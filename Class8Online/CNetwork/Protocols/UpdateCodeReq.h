#ifndef __GNET_UPDATECODEREQ_H
#define __GNET_UPDATECODEREQ_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class UpdateCodeReq : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1036 };

		int64_t		tid;
		int64_t		cid;

	public:
		UpdateCodeReq() { type = PROTOCOL_TYPE; }
		UpdateCodeReq(void*) : Protocol(PROTOCOL_TYPE) { }
		UpdateCodeReq (int64_t	l_tid, int64_t	l_cid)
		: tid(l_tid),
		cid(l_cid)
		{
			type = PROTOCOL_TYPE;
		}

		UpdateCodeReq(const UpdateCodeReq &rhs)
			: Protocol(rhs),
			tid(rhs.tid),
			cid(rhs.cid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << tid;
			os << cid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> tid;
			os >> cid;
			return os;
		}

		virtual Protocol* Clone() const { return new UpdateCodeReq(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif