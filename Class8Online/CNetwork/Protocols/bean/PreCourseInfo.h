#ifndef __GNET_PRECOURSEINFO_H
#define __GNET_PRECOURSEINFO_H

#include "rpcdefs.h"



namespace GNET
{
	class PreCourseInfo : public GNET::Rpc::Data
	{
	public:
		Octets		name;
		Octets		url;

		PreCourseInfo(){}

		PreCourseInfo(const PreCourseInfo &rhs)
			: name(rhs.name),
			url(rhs.url) { }

		Rpc::Data *Clone() const { return new PreCourseInfo(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const PreCourseInfo *r = dynamic_cast<const PreCourseInfo *>(&rhs);
			if (r && r != this)
			{
				name = r->name;
				url = r->url;
			}
			return *this;
		}

		PreCourseInfo& operator = (const PreCourseInfo &rhs)
		{
			const PreCourseInfo *r = &rhs;
			if (r && r != this)
			{
				name = r->name;
				url = r->url;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << name;
			os << url;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> name;
			os >> url;
			return os;
		}
	};
}

#endif