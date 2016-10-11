#ifndef __GNET_MEDIAADDRNOTIFY_H
#define __GNET_MEDIAADDRNOTIFY_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class MediaAddrNotify : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1053 };

		enum
		{
			CLASS_BEGIN = 2,
			CLASS_END = 4,
			STUDENT = 30,
			TEACHER = 40,
		};

		int64_t		classid;
		int64_t		userid;
		Octets		pushaddr;
		Octets		pulladdr;
		char		classstate;
		char		authority;

	public:
		MediaAddrNotify() { type = PROTOCOL_TYPE; }
		MediaAddrNotify(void*) : Protocol(PROTOCOL_TYPE) { }
		MediaAddrNotify (int64_t	l_classid, int64_t	l_userid, const Octets& l_pushaddr, const Octets& l_pulladdr, char	l_classstate, char	l_authority)
		: classid(l_classid),
		userid(l_userid),
		pushaddr(l_pushaddr),
		pulladdr(l_pulladdr),
		classstate(l_classstate),
		authority(l_authority)
		{
			type = PROTOCOL_TYPE;
		}

		MediaAddrNotify(const MediaAddrNotify &rhs)
			: Protocol(rhs),
			classid(rhs.classid),
			userid(rhs.userid),
			pushaddr(rhs.pushaddr),
			pulladdr(rhs.pulladdr),
			classstate(rhs.classstate),
			authority(rhs.authority){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << classid;
			os << userid;
			os << pushaddr;
			os << pulladdr;
			os << classstate;
			os << authority;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> classid;
			os >> userid;
			os >> pushaddr;
			os >> pulladdr;
			os >> classstate;
			os >> authority;
			return os;
		}

		virtual Protocol* Clone() const { return new MediaAddrNotify(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  4098; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif