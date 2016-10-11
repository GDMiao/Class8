#ifndef __GNET_RETURNUSER_H
#define __GNET_RETURNUSER_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UserInfo.h"


namespace GNET
{
	class ReturnUser : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 2002 };

		int		sid;
		int		retcode;
		UserInfo		userinfo;

	public:
		ReturnUser() { type = PROTOCOL_TYPE; }
		ReturnUser(void*) : Protocol(PROTOCOL_TYPE) { }
		ReturnUser (int	l_sid, int	l_retcode, const UserInfo& l_userinfo)
		: sid(l_sid),
		retcode(l_retcode),
		userinfo(l_userinfo)
		{
			type = PROTOCOL_TYPE;
		}

		ReturnUser(const ReturnUser &rhs)
			: Protocol(rhs),
			sid(rhs.sid),
			retcode(rhs.retcode),
			userinfo(rhs.userinfo){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			os << retcode;
			os << userinfo;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			os >> retcode;
			os >> userinfo;
			return os;
		}

		virtual Protocol* Clone() const { return new ReturnUser(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif