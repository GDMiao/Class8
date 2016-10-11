#ifndef __GNET_SENDTEXTMSG_H
#define __GNET_SENDTEXTMSG_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class SendTextMsg : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1010 };

		enum
		{
			CLASS = 1,
			GROUP = 2,
			USER = 3,
		};

		int64_t		receiver;
		char		recvtype;
		int64_t		userid;
		int64_t		recvid;
		int64_t		cid;
		int		recvgroupid;
		Octets		message;
		int64_t		time;

	public:
		SendTextMsg() { type = PROTOCOL_TYPE; }
		SendTextMsg(void*) : Protocol(PROTOCOL_TYPE) { }
		SendTextMsg (int64_t	l_receiver, char	l_recvtype, int64_t	l_userid, int64_t	l_recvid, int64_t	l_cid, int	l_recvgroupid, const Octets& l_message, int64_t	l_time)
		: receiver(l_receiver),
		recvtype(l_recvtype),
		userid(l_userid),
		recvid(l_recvid),
		cid(l_cid),
		recvgroupid(l_recvgroupid),
		message(l_message),
		time(l_time)
		{
			type = PROTOCOL_TYPE;
		}

		SendTextMsg(const SendTextMsg &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			recvtype(rhs.recvtype),
			userid(rhs.userid),
			recvid(rhs.recvid),
			cid(rhs.cid),
			recvgroupid(rhs.recvgroupid),
			message(rhs.message),
			time(rhs.time){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << recvtype;
			os << userid;
			os << recvid;
			os << cid;
			os << recvgroupid;
			os << message;
			os << time;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> recvtype;
			os >> userid;
			os >> recvid;
			os >> cid;
			os >> recvgroupid;
			os >> message;
			os >> time;
			return os;
		}

		virtual Protocol* Clone() const { return new SendTextMsg(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  65536; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif