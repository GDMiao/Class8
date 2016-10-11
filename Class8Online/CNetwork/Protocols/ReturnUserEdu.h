#ifndef __GNET_RETURNUSEREDU_H
#define __GNET_RETURNUSEREDU_H

#include "rpcdefs.h"
#include "state.hxx"

#include "UserEduInfo.h"


namespace GNET
{
	class ReturnUserEdu : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 2004 };

		int		sid;
		int		retcode;
		int64_t		userid;
		std::vector<UserEduInfo>		eduinfolist;

	public:
		ReturnUserEdu() { type = PROTOCOL_TYPE; }
		ReturnUserEdu(void*) : Protocol(PROTOCOL_TYPE) { }
		ReturnUserEdu (int	l_sid, int	l_retcode, int64_t	l_userid, const std::vector<UserEduInfo>& l_eduinfolist)
		: sid(l_sid),
		retcode(l_retcode),
		userid(l_userid),
		eduinfolist(l_eduinfolist)
		{
			type = PROTOCOL_TYPE;
		}

		ReturnUserEdu(const ReturnUserEdu &rhs)
			: Protocol(rhs),
			sid(rhs.sid),
			retcode(rhs.retcode),
			userid(rhs.userid),
			eduinfolist(rhs.eduinfolist){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			os << retcode;
			os << userid;
			os << eduinfolist;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			os >> retcode;
			os >> userid;
			os >> eduinfolist;
			return os;
		}

		virtual Protocol* Clone() const { return new ReturnUserEdu(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  65535; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif