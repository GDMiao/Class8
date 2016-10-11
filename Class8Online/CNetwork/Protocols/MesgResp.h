#ifndef __GNET_MESGRESP_H
#define __GNET_MESGRESP_H

#include "rpcdefs.h"
#include "state.hxx"

#include "NfcMessage.h"


namespace GNET
{
	class MesgResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 3005 };

		char		msgtype;
		int64_t		userid;
		std::vector<NfcMessage>		message;

	public:
		MesgResp() { type = PROTOCOL_TYPE; }
		MesgResp(void*) : Protocol(PROTOCOL_TYPE) { }
		MesgResp (char	l_msgtype, int64_t	l_userid, const std::vector<NfcMessage>& l_message)
		: msgtype(l_msgtype),
		userid(l_userid),
		message(l_message)
		{
			type = PROTOCOL_TYPE;
		}

		MesgResp(const MesgResp &rhs)
			: Protocol(rhs),
			msgtype(rhs.msgtype),
			userid(rhs.userid),
			message(rhs.message){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << msgtype;
			os << userid;
			os << message;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> msgtype;
			os >> userid;
			os >> message;
			return os;
		}

		virtual Protocol* Clone() const { return new MesgResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  65535; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif