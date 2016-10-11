#ifndef __GNET_COMMITCOURSEWARES_H
#define __GNET_COMMITCOURSEWARES_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class CommitCourseWares : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1054 };

		int64_t		teacherid;
		int64_t		classid;
		std::vector<Octets>		courselist;

	public:
		CommitCourseWares() { type = PROTOCOL_TYPE; }
		CommitCourseWares(void*) : Protocol(PROTOCOL_TYPE) { }
		CommitCourseWares (int64_t	l_teacherid, int64_t	l_classid, const std::vector<Octets>& l_courselist)
		: teacherid(l_teacherid),
		classid(l_classid),
		courselist(l_courselist)
		{
			type = PROTOCOL_TYPE;
		}

		CommitCourseWares(const CommitCourseWares &rhs)
			: Protocol(rhs),
			teacherid(rhs.teacherid),
			classid(rhs.classid),
			courselist(rhs.courselist){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << teacherid;
			os << classid;
			os << courselist;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> teacherid;
			os >> classid;
			os >> courselist;
			return os;
		}

		virtual Protocol* Clone() const { return new CommitCourseWares(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  2048; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif