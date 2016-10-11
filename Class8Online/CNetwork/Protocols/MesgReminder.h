#ifndef __GNET_MESGREMINDER_H
#define __GNET_MESGREMINDER_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class MesgReminder : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1046 };

		enum
		{
			SIGN = 1,
			CLASS_ON = 2,
			CLASS_DELAY = 3,
			CLASS_END = 4,
		};

		int64_t		receiver;
		char		msgtype;
		int64_t		courseid;
		int64_t		classid;
		Octets		cname;
		int		record;

	public:
		MesgReminder() { type = PROTOCOL_TYPE; }
		MesgReminder(void*) : Protocol(PROTOCOL_TYPE) { }
		MesgReminder (int64_t	l_receiver, char	l_msgtype, int64_t	l_courseid, int64_t	l_classid, const Octets& l_cname, int	l_record)
		: receiver(l_receiver),
		msgtype(l_msgtype),
		courseid(l_courseid),
		classid(l_classid),
		cname(l_cname),
		record(l_record)
		{
			type = PROTOCOL_TYPE;
		}

		MesgReminder(const MesgReminder &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			msgtype(rhs.msgtype),
			courseid(rhs.courseid),
			classid(rhs.classid),
			cname(rhs.cname),
			record(rhs.record){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << msgtype;
			os << courseid;
			os << classid;
			os << cname;
			os << record;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> msgtype;
			os >> courseid;
			os >> classid;
			os >> cname;
			os >> record;
			return os;
		}

		virtual Protocol* Clone() const { return new MesgReminder(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif