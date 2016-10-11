#ifndef __GNET_QUERYPRECWARES_H
#define __GNET_QUERYPRECWARES_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class QueryPreCWares : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1023 };

		int64_t		tid;
		int64_t		cid;

	public:
		QueryPreCWares() { type = PROTOCOL_TYPE; }
		QueryPreCWares(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryPreCWares (int64_t	l_tid, int64_t	l_cid)
		: tid(l_tid),
		cid(l_cid)
		{
			type = PROTOCOL_TYPE;
		}

		QueryPreCWares(const QueryPreCWares &rhs)
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

		virtual Protocol* Clone() const { return new QueryPreCWares(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif