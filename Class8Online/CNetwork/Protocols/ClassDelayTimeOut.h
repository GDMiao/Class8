#ifndef __GNET_CLASSDELAYTIMEOUT_H
#define __GNET_CLASSDELAYTIMEOUT_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class ClassDelayTimeOut : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1050 };

		int64_t		courseid;
		int64_t		classid;
		int64_t		teacher;

	public:
		ClassDelayTimeOut() { type = PROTOCOL_TYPE; }
		ClassDelayTimeOut(void*) : Protocol(PROTOCOL_TYPE) { }
		ClassDelayTimeOut (int64_t	l_courseid, int64_t	l_classid, int64_t	l_teacher)
		: courseid(l_courseid),
		classid(l_classid),
		teacher(l_teacher)
		{
			type = PROTOCOL_TYPE;
		}

		ClassDelayTimeOut(const ClassDelayTimeOut &rhs)
			: Protocol(rhs),
			courseid(rhs.courseid),
			classid(rhs.classid),
			teacher(rhs.teacher){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << courseid;
			os << classid;
			os << teacher;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> courseid;
			os >> classid;
			os >> teacher;
			return os;
		}

		virtual Protocol* Clone() const { return new ClassDelayTimeOut(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif