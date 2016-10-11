#ifndef __GNET_MOBILEOFF_H
#define __GNET_MOBILEOFF_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class MobileOff : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1057 };

		int64_t		userid;
		int64_t		classid;

	public:
		MobileOff() { type = PROTOCOL_TYPE; }
		MobileOff(void*) : Protocol(PROTOCOL_TYPE) { }
		MobileOff (int64_t	l_userid, int64_t	l_classid)
		: userid(l_userid),
		classid(l_classid)
		{
			type = PROTOCOL_TYPE;
		}

		MobileOff(const MobileOff &rhs)
			: Protocol(rhs),
			userid(rhs.userid),
			classid(rhs.classid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << classid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> classid;
			return os;
		}

		virtual Protocol* Clone() const { return new MobileOff(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif