#ifndef __GNET_COURSEINFO_H
#define __GNET_COURSEINFO_H

#include "rpcdefs.h"



namespace GNET
{
	class CourseInfo : public GNET::Rpc::Data
	{
	public:
		int64_t		courseid;
		Octets		name;
		Octets		description;
		Octets		userheadurl;
		Octets		coverurl;
		Octets		snapshoturl;
		int		compulsorytype;
		int		coursecredit;
		int64_t		teacherid;
		Octets		hostuniversity;
		Octets		hostcollege;
		Octets		hostmajor;
		Octets		schoolyear;
		Octets		schoolterm;
		int		onlinetype;
		int		opentype;
		Octets		offline_classroomaddress;
		int		asidetype;
		int		max_asidecount;
		int		guesttype;
		int		max_aguestcount;
		std::vector<int64_t>		studentsid;
		std::vector<int64_t>		superadmins;
		Octets		code;
		int		max_members;

		CourseInfo()
			: courseid(0),
			compulsorytype(0),
			coursecredit(0),
			teacherid(0),
			onlinetype(0),
			opentype(0),
			asidetype(0),
			max_asidecount(0),
			guesttype(0),
			max_aguestcount(0),
			max_members(0){}

		CourseInfo(const CourseInfo &rhs)
			: courseid(rhs.courseid),
			name(rhs.name),
			description(rhs.description),
			userheadurl(rhs.userheadurl),
			coverurl(rhs.coverurl),
			snapshoturl(rhs.snapshoturl),
			compulsorytype(rhs.compulsorytype),
			coursecredit(rhs.coursecredit),
			teacherid(rhs.teacherid),
			hostuniversity(rhs.hostuniversity),
			hostcollege(rhs.hostcollege),
			hostmajor(rhs.hostmajor),
			schoolyear(rhs.schoolyear),
			schoolterm(rhs.schoolterm),
			onlinetype(rhs.onlinetype),
			opentype(rhs.opentype),
			offline_classroomaddress(rhs.offline_classroomaddress),
			asidetype(rhs.asidetype),
			max_asidecount(rhs.max_asidecount),
			guesttype(rhs.guesttype),
			max_aguestcount(rhs.max_aguestcount),
			studentsid(rhs.studentsid),
			superadmins(rhs.superadmins),
			code(rhs.code),
			max_members(rhs.max_members) { }

		Rpc::Data *Clone() const { return new CourseInfo(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const CourseInfo *r = dynamic_cast<const CourseInfo *>(&rhs);
			if (r && r != this)
			{
				courseid = r->courseid;
				name = r->name;
				description = r->description;
				userheadurl = r->userheadurl;
				coverurl = r->coverurl;
				snapshoturl = r->snapshoturl;
				compulsorytype = r->compulsorytype;
				coursecredit = r->coursecredit;
				teacherid = r->teacherid;
				hostuniversity = r->hostuniversity;
				hostcollege = r->hostcollege;
				hostmajor = r->hostmajor;
				schoolyear = r->schoolyear;
				schoolterm = r->schoolterm;
				onlinetype = r->onlinetype;
				opentype = r->opentype;
				offline_classroomaddress = r->offline_classroomaddress;
				asidetype = r->asidetype;
				max_asidecount = r->max_asidecount;
				guesttype = r->guesttype;
				max_aguestcount = r->max_aguestcount;
				studentsid = r->studentsid;
				superadmins = r->superadmins;
				code = r->code;
				max_members = r->max_members;
			}
			return *this;
		}

		CourseInfo& operator = (const CourseInfo &rhs)
		{
			const CourseInfo *r = &rhs;
			if (r && r != this)
			{
				courseid = r->courseid;
				name = r->name;
				description = r->description;
				userheadurl = r->userheadurl;
				coverurl = r->coverurl;
				snapshoturl = r->snapshoturl;
				compulsorytype = r->compulsorytype;
				coursecredit = r->coursecredit;
				teacherid = r->teacherid;
				hostuniversity = r->hostuniversity;
				hostcollege = r->hostcollege;
				hostmajor = r->hostmajor;
				schoolyear = r->schoolyear;
				schoolterm = r->schoolterm;
				onlinetype = r->onlinetype;
				opentype = r->opentype;
				offline_classroomaddress = r->offline_classroomaddress;
				asidetype = r->asidetype;
				max_asidecount = r->max_asidecount;
				guesttype = r->guesttype;
				max_aguestcount = r->max_aguestcount;
				studentsid = r->studentsid;
				superadmins = r->superadmins;
				code = r->code;
				max_members = r->max_members;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << courseid;
			os << name;
			os << description;
			os << userheadurl;
			os << coverurl;
			os << snapshoturl;
			os << compulsorytype;
			os << coursecredit;
			os << teacherid;
			os << hostuniversity;
			os << hostcollege;
			os << hostmajor;
			os << schoolyear;
			os << schoolterm;
			os << onlinetype;
			os << opentype;
			os << offline_classroomaddress;
			os << asidetype;
			os << max_asidecount;
			os << guesttype;
			os << max_aguestcount;
			os << studentsid;
			os << superadmins;
			os << code;
			os << max_members;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> courseid;
			os >> name;
			os >> description;
			os >> userheadurl;
			os >> coverurl;
			os >> snapshoturl;
			os >> compulsorytype;
			os >> coursecredit;
			os >> teacherid;
			os >> hostuniversity;
			os >> hostcollege;
			os >> hostmajor;
			os >> schoolyear;
			os >> schoolterm;
			os >> onlinetype;
			os >> opentype;
			os >> offline_classroomaddress;
			os >> asidetype;
			os >> max_asidecount;
			os >> guesttype;
			os >> max_aguestcount;
			os >> studentsid;
			os >> superadmins;
			os >> code;
			os >> max_members;
			return os;
		}
	};
}

#endif