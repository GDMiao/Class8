#ifndef __GNET_REFRESHVIDEOLISTRESP_H
#define __GNET_REFRESHVIDEOLISTRESP_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class RefreshVideoListResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1033 };

		int64_t		receiver;
		int64_t		cid;
		std::vector<int64_t>		topvideolist;

	public:
		RefreshVideoListResp() { type = PROTOCOL_TYPE; }
		RefreshVideoListResp(void*) : Protocol(PROTOCOL_TYPE) { }
		RefreshVideoListResp (int64_t	l_receiver, int64_t	l_cid, const std::vector<int64_t>& l_topvideolist)
		: receiver(l_receiver),
		cid(l_cid),
		topvideolist(l_topvideolist)
		{
			type = PROTOCOL_TYPE;
		}

		RefreshVideoListResp(const RefreshVideoListResp &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			cid(rhs.cid),
			topvideolist(rhs.topvideolist){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << cid;
			os << topvideolist;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> cid;
			os >> topvideolist;
			return os;
		}

		virtual Protocol* Clone() const { return new RefreshVideoListResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif