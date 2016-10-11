#ifndef __GNET_CLASSINFORSP_H
#define __GNET_CLASSINFORSP_H

#include "rpcdefs.h"
#include "state.hxx"

#include "CourseInfo.h"


namespace GNET
{
	class ClassInfoRsp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1015 };

		CourseInfo		courseinfo;

	public:
		ClassInfoRsp() { type = PROTOCOL_TYPE; }
		ClassInfoRsp(void*) : Protocol(PROTOCOL_TYPE) { }
		ClassInfoRsp (const CourseInfo& l_courseinfo)
		: courseinfo(l_courseinfo)
		{
			type = PROTOCOL_TYPE;
		}

		ClassInfoRsp(const ClassInfoRsp &rhs)
			: Protocol(rhs),
			courseinfo(rhs.courseinfo){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << courseinfo;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> courseinfo;
			return os;
		}

		virtual Protocol* Clone() const { return new ClassInfoRsp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  65536; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif