#ifndef __GNET_EVALUATECLASS_H
#define __GNET_EVALUATECLASS_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class EvaluateClass : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1014 };

		int64_t		userid;
		int64_t		cid;
		int		rank;
		Octets		description;

	public:
		EvaluateClass() { type = PROTOCOL_TYPE; }
		EvaluateClass(void*) : Protocol(PROTOCOL_TYPE) { }
		EvaluateClass (int64_t	l_userid, int64_t	l_cid, int	l_rank, const Octets& l_description)
		: userid(l_userid),
		cid(l_cid),
		rank(l_rank),
		description(l_description)
		{
			type = PROTOCOL_TYPE;
		}

		EvaluateClass(const EvaluateClass &rhs)
			: Protocol(rhs),
			userid(rhs.userid),
			cid(rhs.cid),
			rank(rhs.rank),
			description(rhs.description){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << cid;
			os << rank;
			os << description;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> cid;
			os >> rank;
			os >> description;
			return os;
		}

		virtual Protocol* Clone() const { return new EvaluateClass(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif