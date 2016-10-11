#ifndef __GNET_CHOOSEMOBILE_H
#define __GNET_CHOOSEMOBILE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class ChooseMobile : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1038 };

		enum
		{
			STOP = 0,
			CHOOSE = 1,
		};

		int64_t		tid;
		int64_t		userid;
		char		actiontype;
		Octets		pushaddr;

	public:
		ChooseMobile() { type = PROTOCOL_TYPE; }
		ChooseMobile(void*) : Protocol(PROTOCOL_TYPE) { }
		ChooseMobile (int64_t	l_tid, int64_t	l_userid, char	l_actiontype, const Octets& l_pushaddr)
		: tid(l_tid),
		userid(l_userid),
		actiontype(l_actiontype),
		pushaddr(l_pushaddr)
		{
			type = PROTOCOL_TYPE;
		}

		ChooseMobile(const ChooseMobile &rhs)
			: Protocol(rhs),
			tid(rhs.tid),
			userid(rhs.userid),
			actiontype(rhs.actiontype),
			pushaddr(rhs.pushaddr){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << tid;
			os << userid;
			os << actiontype;
			os << pushaddr;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> tid;
			os >> userid;
			os >> actiontype;
			os >> pushaddr;
			return os;
		}

		virtual Protocol* Clone() const { return new ChooseMobile(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif