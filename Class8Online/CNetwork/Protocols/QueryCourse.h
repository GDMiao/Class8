#ifndef __GNET_QUERYCOURSE_H
#define __GNET_QUERYCOURSE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class QueryCourse : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 2005 };

		int64_t		userid;
		int		device;
		Octets		token;
		char		netisp;
		int64_t		courseid;

	public:
		QueryCourse() { type = PROTOCOL_TYPE; }
		QueryCourse(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryCourse (int64_t	l_userid, int	l_device, const Octets& l_token, char	l_netisp, int64_t	l_courseid)
		: userid(l_userid),
		device(l_device),
		token(l_token),
		netisp(l_netisp),
		courseid(l_courseid)
		{
			type = PROTOCOL_TYPE;
		}

		QueryCourse(const QueryCourse &rhs)
			: Protocol(rhs),
			userid(rhs.userid),
			device(rhs.device),
			token(rhs.token),
			netisp(rhs.netisp),
			courseid(rhs.courseid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << device;
			os << token;
			os << netisp;
			os << courseid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> device;
			os >> token;
			os >> netisp;
			os >> courseid;
			return os;
		}

		virtual Protocol* Clone() const { return new QueryCourse(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif