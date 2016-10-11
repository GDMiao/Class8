#ifndef __GNET_ONLINENOTIFY_H
#define __GNET_ONLINENOTIFY_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class OnLineNotify : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 3008 };

		int64_t		courseid;
		int		number;

	public:
		OnLineNotify() { type = PROTOCOL_TYPE; }
		OnLineNotify(void*) : Protocol(PROTOCOL_TYPE) { }
		OnLineNotify (int64_t	l_courseid, int	l_number)
		: courseid(l_courseid),
		number(l_number)
		{
			type = PROTOCOL_TYPE;
		}

		OnLineNotify(const OnLineNotify &rhs)
			: Protocol(rhs),
			courseid(rhs.courseid),
			number(rhs.number){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << courseid;
			os << number;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> courseid;
			os >> number;
			return os;
		}

		virtual Protocol* Clone() const { return new OnLineNotify(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif