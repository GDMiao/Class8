#ifndef __GNET_SWITCHCLASSSHOW_H
#define __GNET_SWITCHCLASSSHOW_H

#include "rpcdefs.h"
#include "state.hxx"

#include "ShowInfo.h"


namespace GNET
{
	class SwitchClassShow : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1004 };

		int64_t		receiver;
		int64_t		userid;
		int64_t		cid;
		ShowInfo		currentshow;

	public:
		SwitchClassShow() { type = PROTOCOL_TYPE; }
		SwitchClassShow(void*) : Protocol(PROTOCOL_TYPE) { }
		SwitchClassShow (int64_t	l_receiver, int64_t	l_userid, int64_t	l_cid, const ShowInfo& l_currentshow)
		: receiver(l_receiver),
		userid(l_userid),
		cid(l_cid),
		currentshow(l_currentshow)
		{
			type = PROTOCOL_TYPE;
		}

		SwitchClassShow(const SwitchClassShow &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			userid(rhs.userid),
			cid(rhs.cid),
			currentshow(rhs.currentshow){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << userid;
			os << cid;
			os << currentshow;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> userid;
			os >> cid;
			os >> currentshow;
			return os;
		}

		virtual Protocol* Clone() const { return new SwitchClassShow(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif