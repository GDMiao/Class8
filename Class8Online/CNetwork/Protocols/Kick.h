#ifndef __GNET_KICK_H
#define __GNET_KICK_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class Kick : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1040 };

		enum
		{
			DELETE_DEVICE = 0,
			CLASS_END = 1,
			MOBILE_OFF = 2,
			TEACHER_LEAVE = 3,
		};

		int64_t		tid;
		int64_t		userid;
		char		notifytype;

	public:
		Kick() { type = PROTOCOL_TYPE; }
		Kick(void*) : Protocol(PROTOCOL_TYPE) { }
		Kick (int64_t	l_tid, int64_t	l_userid, char	l_notifytype)
		: tid(l_tid),
		userid(l_userid),
		notifytype(l_notifytype)
		{
			type = PROTOCOL_TYPE;
		}

		Kick(const Kick &rhs)
			: Protocol(rhs),
			tid(rhs.tid),
			userid(rhs.userid),
			notifytype(rhs.notifytype){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << tid;
			os << userid;
			os << notifytype;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> tid;
			os >> userid;
			os >> notifytype;
			return os;
		}

		virtual Protocol* Clone() const { return new Kick(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif