#ifndef __GNET_CLASSRECORD_H
#define __GNET_CLASSRECORD_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class ClassRecord : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1049 };

		int64_t		courseid;
		int64_t		classid;
		Octets		url;

	public:
		ClassRecord() { type = PROTOCOL_TYPE; }
		ClassRecord(void*) : Protocol(PROTOCOL_TYPE) { }
		ClassRecord (int64_t	l_courseid, int64_t	l_classid, const Octets& l_url)
		: courseid(l_courseid),
		classid(l_classid),
		url(l_url)
		{
			type = PROTOCOL_TYPE;
		}

		ClassRecord(const ClassRecord &rhs)
			: Protocol(rhs),
			courseid(rhs.courseid),
			classid(rhs.classid),
			url(rhs.url){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << courseid;
			os << classid;
			os << url;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> courseid;
			os >> classid;
			os >> url;
			return os;
		}

		virtual Protocol* Clone() const { return new ClassRecord(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif