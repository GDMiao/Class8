#ifndef __GNET_RTRANCURSEWAVE_H
#define __GNET_RTRANCURSEWAVE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class RTranCursewave : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 3002 };

		enum
		{
			TOK = 0,
			TFAILED = 1,
		};

		char		rcode;
		Octets		srcurl;
		Octets		decurl;
		Octets		extern;

	public:
		RTranCursewave() { type = PROTOCOL_TYPE; }
		RTranCursewave(void*) : Protocol(PROTOCOL_TYPE) { }
		RTranCursewave (char	l_rcode, const Octets& l_srcurl, const Octets& l_decurl, const Octets& l_extern)
		: rcode(l_rcode),
		srcurl(l_srcurl),
		decurl(l_decurl),
		extern(l_extern)
		{
			type = PROTOCOL_TYPE;
		}

		RTranCursewave(const RTranCursewave &rhs)
			: Protocol(rhs),
			rcode(rhs.rcode),
			srcurl(rhs.srcurl),
			decurl(rhs.decurl),
			extern(rhs.extern){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << rcode;
			os << srcurl;
			os << decurl;
			os << extern;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> rcode;
			os >> srcurl;
			os >> decurl;
			os >> extern;
			return os;
		}

		virtual Protocol* Clone() const { return new RTranCursewave(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif