#ifndef __GNET_USEREDUINFO_H
#define __GNET_USEREDUINFO_H

#include "rpcdefs.h"



namespace GNET
{
	class UserEduInfo : public GNET::Rpc::Data
	{
	public:
		enum
		{
			NOT_VERIFYED = 0,
			VERIFY_CODE_SEND = 1,
			VERIFYED = 100,
			VERIFY_FAILED = 99,
		};

		Octets		university;
		Octets		college;
		Octets		grade;
		Octets		majorr;
		Octets		studentno;
		int		verifystatus;

		UserEduInfo()
			: verifystatus(0){}

		UserEduInfo(const UserEduInfo &rhs)
			: university(rhs.university),
			college(rhs.college),
			grade(rhs.grade),
			majorr(rhs.majorr),
			studentno(rhs.studentno),
			verifystatus(rhs.verifystatus) { }

		Rpc::Data *Clone() const { return new UserEduInfo(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const UserEduInfo *r = dynamic_cast<const UserEduInfo *>(&rhs);
			if (r && r != this)
			{
				university = r->university;
				college = r->college;
				grade = r->grade;
				majorr = r->majorr;
				studentno = r->studentno;
				verifystatus = r->verifystatus;
			}
			return *this;
		}

		UserEduInfo& operator = (const UserEduInfo &rhs)
		{
			const UserEduInfo *r = &rhs;
			if (r && r != this)
			{
				university = r->university;
				college = r->college;
				grade = r->grade;
				majorr = r->majorr;
				studentno = r->studentno;
				verifystatus = r->verifystatus;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << university;
			os << college;
			os << grade;
			os << majorr;
			os << studentno;
			os << verifystatus;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> university;
			os >> college;
			os >> grade;
			os >> majorr;
			os >> studentno;
			os >> verifystatus;
			return os;
		}
	};
}

#endif