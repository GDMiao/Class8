#ifndef __GNET_RETURNCOURSE_H
#define __GNET_RETURNCOURSE_H

#include "rpcdefs.h"
#include "state.hxx"

#include "CourseInfo.h"


namespace GNET
{
	class ReturnCourse : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 2006 };

		enum
		{
			OK = 0,
			COURSE_ERROR = -1,
		};

		int64_t		userid;
		int		device;
		Octets		token;
		char		netisp;
		int		retcode;
		CourseInfo		course;

	public:
		ReturnCourse() { type = PROTOCOL_TYPE; }
		ReturnCourse(void*) : Protocol(PROTOCOL_TYPE) { }
		ReturnCourse (int64_t	l_userid, int	l_device, const Octets& l_token, char	l_netisp, int	l_retcode, const CourseInfo& l_course)
		: userid(l_userid),
		device(l_device),
		token(l_token),
		netisp(l_netisp),
		retcode(l_retcode),
		course(l_course)
		{
			type = PROTOCOL_TYPE;
		}

		ReturnCourse(const ReturnCourse &rhs)
			: Protocol(rhs),
			userid(rhs.userid),
			device(rhs.device),
			token(rhs.token),
			netisp(rhs.netisp),
			retcode(rhs.retcode),
			course(rhs.course){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << device;
			os << token;
			os << netisp;
			os << retcode;
			os << course;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> device;
			os >> token;
			os >> netisp;
			os >> retcode;
			os >> course;
			return os;
		}

		virtual Protocol* Clone() const { return new ReturnCourse(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  655350; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif