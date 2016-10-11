#ifndef __GNET_REFRESHVIDEOLISTREQ_H
#define __GNET_REFRESHVIDEOLISTREQ_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class RefreshVideoListReq : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1032 };

		int64_t		cid;
		int64_t		teacherid;

	public:
		RefreshVideoListReq() { type = PROTOCOL_TYPE; }
		RefreshVideoListReq(void*) : Protocol(PROTOCOL_TYPE) { }
		RefreshVideoListReq (int64_t	l_cid, int64_t	l_teacherid)
		: cid(l_cid),
		teacherid(l_teacherid)
		{
			type = PROTOCOL_TYPE;
		}

		RefreshVideoListReq(const RefreshVideoListReq &rhs)
			: Protocol(rhs),
			cid(rhs.cid),
			teacherid(rhs.teacherid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << cid;
			os << teacherid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> cid;
			os >> teacherid;
			return os;
		}

		virtual Protocol* Clone() const { return new RefreshVideoListReq(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif