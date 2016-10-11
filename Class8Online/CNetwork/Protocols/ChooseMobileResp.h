#ifndef __GNET_CHOOSEMOBILERESP_H
#define __GNET_CHOOSEMOBILERESP_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class ChooseMobileResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1039 };

		int		ret;
		int64_t		tid;
		int64_t		userid;
		char		actiontype;

	public:
		ChooseMobileResp() { type = PROTOCOL_TYPE; }
		ChooseMobileResp(void*) : Protocol(PROTOCOL_TYPE) { }
		ChooseMobileResp (int	l_ret, int64_t	l_tid, int64_t	l_userid, char	l_actiontype)
		: ret(l_ret),
		tid(l_tid),
		userid(l_userid),
		actiontype(l_actiontype)
		{
			type = PROTOCOL_TYPE;
		}

		ChooseMobileResp(const ChooseMobileResp &rhs)
			: Protocol(rhs),
			ret(rhs.ret),
			tid(rhs.tid),
			userid(rhs.userid),
			actiontype(rhs.actiontype){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << ret;
			os << tid;
			os << userid;
			os << actiontype;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> ret;
			os >> tid;
			os >> userid;
			os >> actiontype;
			return os;
		}

		virtual Protocol* Clone() const { return new ChooseMobileResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif