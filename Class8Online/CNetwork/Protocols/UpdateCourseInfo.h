#ifndef __GNET_UPDATECOURSEINFO_H
#define __GNET_UPDATECOURSEINFO_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class UpdateCourseInfo : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1047 };

		int64_t		courseid;
		int64_t		teacher;
		std::vector<int64_t>		students;
		int		max_members;

	public:
		UpdateCourseInfo() { type = PROTOCOL_TYPE; }
		UpdateCourseInfo(void*) : Protocol(PROTOCOL_TYPE) { }
		UpdateCourseInfo (int64_t	l_courseid, int64_t	l_teacher, const std::vector<int64_t>& l_students, int	l_max_members)
		: courseid(l_courseid),
		teacher(l_teacher),
		students(l_students),
		max_members(l_max_members)
		{
			type = PROTOCOL_TYPE;
		}

		UpdateCourseInfo(const UpdateCourseInfo &rhs)
			: Protocol(rhs),
			courseid(rhs.courseid),
			teacher(rhs.teacher),
			students(rhs.students),
			max_members(rhs.max_members){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << courseid;
			os << teacher;
			os << students;
			os << max_members;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> courseid;
			os >> teacher;
			os >> students;
			os >> max_members;
			return os;
		}

		virtual Protocol* Clone() const { return new UpdateCourseInfo(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  655350; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif