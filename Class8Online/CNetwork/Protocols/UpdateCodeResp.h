#ifndef __GNET_UPDATECODERESP_H
#define __GNET_UPDATECODERESP_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class UpdateCodeResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1037 };

		int64_t		tid;
		int64_t		cid;
		Octets		code;

	public:
		UpdateCodeResp() { type = PROTOCOL_TYPE; }
		UpdateCodeResp(void*) : Protocol(PROTOCOL_TYPE) { }
		UpdateCodeResp (int64_t	l_tid, int64_t	l_cid, const Octets& l_code)
		: tid(l_tid),
		cid(l_cid),
		code(l_code)
		{
			type = PROTOCOL_TYPE;
		}

		UpdateCodeResp(const UpdateCodeResp &rhs)
			: Protocol(rhs),
			tid(rhs.tid),
			cid(rhs.cid),
			code(rhs.code){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << tid;
			os << cid;
			os << code;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> tid;
			os >> cid;
			os >> code;
			return os;
		}

		virtual Protocol* Clone() const { return new UpdateCodeResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif