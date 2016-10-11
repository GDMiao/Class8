#ifndef __GNET_KEEPALIVE_H
#define __GNET_KEEPALIVE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class KeepAlive : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1029 };

		int64_t		code;

	public:
		KeepAlive() { type = PROTOCOL_TYPE; }
		KeepAlive(void*) : Protocol(PROTOCOL_TYPE) { }
		KeepAlive (int64_t	l_code)
		: code(l_code)
		{
			type = PROTOCOL_TYPE;
		}

		KeepAlive(const KeepAlive &rhs)
			: Protocol(rhs),
			code(rhs.code){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << code;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> code;
			return os;
		}

		virtual Protocol* Clone() const { return new KeepAlive(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif