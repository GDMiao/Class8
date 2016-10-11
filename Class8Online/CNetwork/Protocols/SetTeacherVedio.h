#ifndef __GNET_SETTEACHERVEDIO_H
#define __GNET_SETTEACHERVEDIO_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class SetTeacherVedio : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1027 };

		int64_t		receiver;
		int64_t		userid;
		int64_t		cid;
		int		teachervedio;

	public:
		SetTeacherVedio() { type = PROTOCOL_TYPE; }
		SetTeacherVedio(void*) : Protocol(PROTOCOL_TYPE) { }
		SetTeacherVedio (int64_t	l_receiver, int64_t	l_userid, int64_t	l_cid, int	l_teachervedio)
		: receiver(l_receiver),
		userid(l_userid),
		cid(l_cid),
		teachervedio(l_teachervedio)
		{
			type = PROTOCOL_TYPE;
		}

		SetTeacherVedio(const SetTeacherVedio &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			userid(rhs.userid),
			cid(rhs.cid),
			teachervedio(rhs.teachervedio){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << userid;
			os << cid;
			os << teachervedio;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> userid;
			os >> cid;
			os >> teachervedio;
			return os;
		}

		virtual Protocol* Clone() const { return new SetTeacherVedio(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif