#ifndef __GNET_TRANCURSEWAVE_H
#define __GNET_TRANCURSEWAVE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class TranCursewave : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 3001 };

		Octets		srcurl;
		Octets		decurl;
		Octets		extern;

	public:
		TranCursewave() { type = PROTOCOL_TYPE; }
		TranCursewave(void*) : Protocol(PROTOCOL_TYPE) { }
		TranCursewave (const Octets& l_srcurl, const Octets& l_decurl, const Octets& l_extern)
		: srcurl(l_srcurl),
		decurl(l_decurl),
		extern(l_extern)
		{
			type = PROTOCOL_TYPE;
		}

		TranCursewave(const TranCursewave &rhs)
			: Protocol(rhs),
			srcurl(rhs.srcurl),
			decurl(rhs.decurl),
			extern(rhs.extern){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << srcurl;
			os << decurl;
			os << extern;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> srcurl;
			os >> decurl;
			os >> extern;
			return os;
		}

		virtual Protocol* Clone() const { return new TranCursewave(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif