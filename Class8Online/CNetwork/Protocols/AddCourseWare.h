#ifndef __GNET_ADDCOURSEWARE_H
#define __GNET_ADDCOURSEWARE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class AddCourseWare : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1006 };

		enum
		{
			ADD = 1,
			DEL = 2,
			CLOSE = 3,
			CLIENT = 1,
			WEBSERVER = 2,
		};

		int64_t		receiver;
		char		actiontype;
		char		sender;
		int64_t		userid;
		int64_t		cid;
		Octets		cwtype;
		Octets		cwname;

	public:
		AddCourseWare() { type = PROTOCOL_TYPE; }
		AddCourseWare(void*) : Protocol(PROTOCOL_TYPE) { }
		AddCourseWare (int64_t	l_receiver, char	l_actiontype, char	l_sender, int64_t	l_userid, int64_t	l_cid, const Octets& l_cwtype, const Octets& l_cwname)
		: receiver(l_receiver),
		actiontype(l_actiontype),
		sender(l_sender),
		userid(l_userid),
		cid(l_cid),
		cwtype(l_cwtype),
		cwname(l_cwname)
		{
			type = PROTOCOL_TYPE;
		}

		AddCourseWare(const AddCourseWare &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			actiontype(rhs.actiontype),
			sender(rhs.sender),
			userid(rhs.userid),
			cid(rhs.cid),
			cwtype(rhs.cwtype),
			cwname(rhs.cwname){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << actiontype;
			os << sender;
			os << userid;
			os << cid;
			os << cwtype;
			os << cwname;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> actiontype;
			os >> sender;
			os >> userid;
			os >> cid;
			os >> cwtype;
			os >> cwname;
			return os;
		}

		virtual Protocol* Clone() const { return new AddCourseWare(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif