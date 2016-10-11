#ifndef __GNET_USERLEAVE_H
#define __GNET_USERLEAVE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class UserLeave : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1003 };

		int64_t		receiver;
		int64_t		userid;
		int64_t		cid;
		int64_t		intime;

	public:
		UserLeave() { type = PROTOCOL_TYPE; }
		UserLeave(void*) : Protocol(PROTOCOL_TYPE) { }
		UserLeave (int64_t	l_receiver, int64_t	l_userid, int64_t	l_cid, int64_t	l_intime)
		: receiver(l_receiver),
		userid(l_userid),
		cid(l_cid),
		intime(l_intime)
		{
			type = PROTOCOL_TYPE;
		}

		UserLeave(const UserLeave &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			userid(rhs.userid),
			cid(rhs.cid),
			intime(rhs.intime){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << userid;
			os << cid;
			os << intime;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> userid;
			os >> cid;
			os >> intime;
			return os;
		}

		virtual Protocol* Clone() const { return new UserLeave(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif