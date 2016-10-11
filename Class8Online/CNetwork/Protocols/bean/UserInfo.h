#ifndef __GNET_USERINFO_H
#define __GNET_USERINFO_H

#include "rpcdefs.h"



namespace GNET
{
	class UserInfo : public GNET::Rpc::Data
	{
	public:
		enum
		{
			VISITOR = 1,
			OBSERVER = 10,
			MONITOR = 20,
			STUDENT = 30,
			ASSISTANT = 31,
			TEACHER = 40,
			ASK_SPEAK = 1,
			SPEAK = 2,
			USE_VOICE = 4,
			USE_VIDEO = 8,
			MUTE = 16,
			UNKNOW_GENDER = 0,
			MALE = 1,
			FEMALE = 2,
		};

		int64_t		userid;
		int		authority;
		Octets		nickname;
		Octets		realname;
		Octets		signature;
		int		gender;
		Octets		pic;
		int		bantype;
		Octets		mobile;
		Octets		email;
		int		device;
		int		state;
		Octets		pushaddr;
		Octets		pulladdr;

		UserInfo()
			: userid(0),
			authority(0),
			gender(0),
			bantype(0),
			device(0),
			state(0){}

		UserInfo(const UserInfo &rhs)
			: userid(rhs.userid),
			authority(rhs.authority),
			nickname(rhs.nickname),
			realname(rhs.realname),
			signature(rhs.signature),
			gender(rhs.gender),
			pic(rhs.pic),
			bantype(rhs.bantype),
			mobile(rhs.mobile),
			email(rhs.email),
			device(rhs.device),
			state(rhs.state),
			pushaddr(rhs.pushaddr),
			pulladdr(rhs.pulladdr) { }

		Rpc::Data *Clone() const { return new UserInfo(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const UserInfo *r = dynamic_cast<const UserInfo *>(&rhs);
			if (r && r != this)
			{
				userid = r->userid;
				authority = r->authority;
				nickname = r->nickname;
				realname = r->realname;
				signature = r->signature;
				gender = r->gender;
				pic = r->pic;
				bantype = r->bantype;
				mobile = r->mobile;
				email = r->email;
				device = r->device;
				state = r->state;
				pushaddr = r->pushaddr;
				pulladdr = r->pulladdr;
			}
			return *this;
		}

		UserInfo& operator = (const UserInfo &rhs)
		{
			const UserInfo *r = &rhs;
			if (r && r != this)
			{
				userid = r->userid;
				authority = r->authority;
				nickname = r->nickname;
				realname = r->realname;
				signature = r->signature;
				gender = r->gender;
				pic = r->pic;
				bantype = r->bantype;
				mobile = r->mobile;
				email = r->email;
				device = r->device;
				state = r->state;
				pushaddr = r->pushaddr;
				pulladdr = r->pulladdr;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << authority;
			os << nickname;
			os << realname;
			os << signature;
			os << gender;
			os << pic;
			os << bantype;
			os << mobile;
			os << email;
			os << device;
			os << state;
			os << pushaddr;
			os << pulladdr;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> authority;
			os >> nickname;
			os >> realname;
			os >> signature;
			os >> gender;
			os >> pic;
			os >> bantype;
			os >> mobile;
			os >> email;
			os >> device;
			os >> state;
			os >> pushaddr;
			os >> pulladdr;
			return os;
		}
	};
}

#endif