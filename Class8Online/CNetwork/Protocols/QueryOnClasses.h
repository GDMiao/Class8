#ifndef __GNET_QUERYONCLASSES_H
#define __GNET_QUERYONCLASSES_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class QueryOnClasses : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1030 };

		int		sid;

	public:
		QueryOnClasses() { type = PROTOCOL_TYPE; }
		QueryOnClasses(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryOnClasses (int	l_sid)
		: sid(l_sid)
		{
			type = PROTOCOL_TYPE;
		}

		QueryOnClasses(const QueryOnClasses &rhs)
			: Protocol(rhs),
			sid(rhs.sid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			return os;
		}

		virtual Protocol* Clone() const { return new QueryOnClasses(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif