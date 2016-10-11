#ifndef __GNET_QUERYPRECWARESRESP_H
#define __GNET_QUERYPRECWARESRESP_H

#include "rpcdefs.h"
#include "state.hxx"

#include "PreCourseInfo.h"


namespace GNET
{
	class QueryPreCWaresResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1024 };

		int64_t		tid;
		int64_t		cid;
		std::vector<PreCourseInfo>		courselist;

	public:
		QueryPreCWaresResp() { type = PROTOCOL_TYPE; }
		QueryPreCWaresResp(void*) : Protocol(PROTOCOL_TYPE) { }
		QueryPreCWaresResp (int64_t	l_tid, int64_t	l_cid, const std::vector<PreCourseInfo>& l_courselist)
		: tid(l_tid),
		cid(l_cid),
		courselist(l_courselist)
		{
			type = PROTOCOL_TYPE;
		}

		QueryPreCWaresResp(const QueryPreCWaresResp &rhs)
			: Protocol(rhs),
			tid(rhs.tid),
			cid(rhs.cid),
			courselist(rhs.courselist){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << tid;
			os << cid;
			os << courselist;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> tid;
			os >> cid;
			os >> courselist;
			return os;
		}

		virtual Protocol* Clone() const { return new QueryPreCWaresResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  65535; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif