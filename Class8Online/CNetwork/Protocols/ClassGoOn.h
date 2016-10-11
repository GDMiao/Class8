#ifndef __GNET_CLASSGOON_H
#define __GNET_CLASSGOON_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class ClassGoOn : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1048 };

		int64_t		courseid;
		int64_t		classid;
		int64_t		teacher;

	public:
		ClassGoOn() { type = PROTOCOL_TYPE; }
		ClassGoOn(void*) : Protocol(PROTOCOL_TYPE) { }
		ClassGoOn (int64_t	l_courseid, int64_t	l_classid, int64_t	l_teacher)
		: courseid(l_courseid),
		classid(l_classid),
		teacher(l_teacher)
		{
			type = PROTOCOL_TYPE;
		}

		ClassGoOn(const ClassGoOn &rhs)
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

		virtual Protocol* Clone() const { return new ClassGoOn(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif