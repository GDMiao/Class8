#ifndef __GNET_SETCLASSSTATE_H
#define __GNET_SETCLASSSTATE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class SetClassState : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1008 };

		enum
		{
			CLASS_BEGIN = 2,
			CLASS_END = 4,
		};

		int64_t		receiver;
		int		ret;
		int64_t		userid;
		int64_t		cid;
		int64_t		classid;
		char		classstate;

	public:
		SetClassState() { type = PROTOCOL_TYPE; }
		SetClassState(void*) : Protocol(PROTOCOL_TYPE) { }
		SetClassState (int64_t	l_receiver, int	l_ret, int64_t	l_userid, int64_t	l_cid, int64_t	l_classid, char	l_classstate)
		: receiver(l_receiver),
		ret(l_ret),
		userid(l_userid),
		cid(l_cid),
		classid(l_classid),
		classstate(l_classstate)
		{
			type = PROTOCOL_TYPE;
		}

		SetClassState(const SetClassState &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			ret(rhs.ret),
			userid(rhs.userid),
			cid(rhs.cid),
			classid(rhs.classid),
			classstate(rhs.classstate){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << ret;
			os << userid;
			os << cid;
			os << classid;
			os << classstate;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> ret;
			os >> userid;
			os >> cid;
			os >> classid;
			os >> classstate;
			return os;
		}

		virtual Protocol* Clone() const { return new SetClassState(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif