#ifndef __GNET_CREATEWHITEBOARD_H
#define __GNET_CREATEWHITEBOARD_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class CreateWhiteBoard : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1005 };

		enum
		{
			ADD = 1,
			DEL = 2,
			MODIFY = 3,
		};

		int64_t		receiver;
		char		actionytype;
		int64_t		userid;
		int64_t		cid;
		int		wbid;
		Octets		wbname;

	public:
		CreateWhiteBoard() { type = PROTOCOL_TYPE; }
		CreateWhiteBoard(void*) : Protocol(PROTOCOL_TYPE) { }
		CreateWhiteBoard (int64_t	l_receiver, char	l_actionytype, int64_t	l_userid, int64_t	l_cid, int	l_wbid, const Octets& l_wbname)
		: receiver(l_receiver),
		actionytype(l_actionytype),
		userid(l_userid),
		cid(l_cid),
		wbid(l_wbid),
		wbname(l_wbname)
		{
			type = PROTOCOL_TYPE;
		}

		CreateWhiteBoard(const CreateWhiteBoard &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			actionytype(rhs.actionytype),
			userid(rhs.userid),
			cid(rhs.cid),
			wbid(rhs.wbid),
			wbname(rhs.wbname){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << actionytype;
			os << userid;
			os << cid;
			os << wbid;
			os << wbname;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> actionytype;
			os >> userid;
			os >> cid;
			os >> wbid;
			os >> wbname;
			return os;
		}

		virtual Protocol* Clone() const { return new CreateWhiteBoard(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif