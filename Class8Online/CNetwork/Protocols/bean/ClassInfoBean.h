#ifndef __GNET_CLASSINFOBEAN_H
#define __GNET_CLASSINFOBEAN_H

#include "rpcdefs.h"



namespace GNET
{
	class ClassInfoBean : public GNET::Rpc::Data
	{
	public:
		enum
		{
			CLASS_WAIT_ON = 1,
			CLASS_ON_NOT_BEGIN = 2,
			CLASS_ON_AND_BEGIN = 4,
		};

		int64_t		courseid;
		int64_t		classid;
		Octets		classname;
		Octets		userheadurl;
		Octets		code;
		char		classstate;
		int		durationtime;
		int		record;

		ClassInfoBean()
			: courseid(0),
			classid(0),
			classstate(0),
			durationtime(0),
			record(0){}

		ClassInfoBean(const ClassInfoBean &rhs)
			: courseid(rhs.courseid),
			classid(rhs.classid),
			classname(rhs.classname),
			userheadurl(rhs.userheadurl),
			code(rhs.code),
			classstate(rhs.classstate),
			durationtime(rhs.durationtime),
			record(rhs.record) { }

		Rpc::Data *Clone() const { return new ClassInfoBean(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const ClassInfoBean *r = dynamic_cast<const ClassInfoBean *>(&rhs);
			if (r && r != this)
			{
				courseid = r->courseid;
				classid = r->classid;
				classname = r->classname;
				userheadurl = r->userheadurl;
				code = r->code;
				classstate = r->classstate;
				durationtime = r->durationtime;
				record = r->record;
			}
			return *this;
		}

		ClassInfoBean& operator = (const ClassInfoBean &rhs)
		{
			const ClassInfoBean *r = &rhs;
			if (r && r != this)
			{
				courseid = r->courseid;
				classid = r->classid;
				classname = r->classname;
				userheadurl = r->userheadurl;
				code = r->code;
				classstate = r->classstate;
				durationtime = r->durationtime;
				record = r->record;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << courseid;
			os << classid;
			os << classname;
			os << userheadurl;
			os << code;
			os << classstate;
			os << durationtime;
			os << record;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> courseid;
			os >> classid;
			os >> classname;
			os >> userheadurl;
			os >> code;
			os >> classstate;
			os >> durationtime;
			os >> record;
			return os;
		}
	};
}

#endif