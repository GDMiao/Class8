#ifndef __GNET_KICKOUT_H
#define __GNET_KICKOUT_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class KickOut : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1016 };

		int64_t		userid;

	public:
		KickOut() { type = PROTOCOL_TYPE; }
		KickOut(void*) : Protocol(PROTOCOL_TYPE) { }
		KickOut (int64_t	l_userid)
		: userid(l_userid)
		{
			type = PROTOCOL_TYPE;
		}

		KickOut(const KickOut &rhs)
			: Protocol(rhs),
			userid(rhs.userid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			return os;
		}

		virtual Protocol* Clone() const { return new KickOut(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif