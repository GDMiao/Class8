#ifndef __GNET_FEEDBACK_H
#define __GNET_FEEDBACK_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class FeedBack : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 2023 };

		int64_t		userid;
		int		fbtype;
		Octets		title;
		Octets		content;
		Octets		mobile;

	public:
		FeedBack() { type = PROTOCOL_TYPE; }
		FeedBack(void*) : Protocol(PROTOCOL_TYPE) { }
		FeedBack (int64_t	l_userid, int	l_fbtype, const Octets& l_title, const Octets& l_content, const Octets& l_mobile)
		: userid(l_userid),
		fbtype(l_fbtype),
		title(l_title),
		content(l_content),
		mobile(l_mobile)
		{
			type = PROTOCOL_TYPE;
		}

		FeedBack(const FeedBack &rhs)
			: Protocol(rhs),
			userid(rhs.userid),
			fbtype(rhs.fbtype),
			title(rhs.title),
			content(rhs.content),
			mobile(rhs.mobile){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << fbtype;
			os << title;
			os << content;
			os << mobile;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> fbtype;
			os >> title;
			os >> content;
			os >> mobile;
			return os;
		}

		virtual Protocol* Clone() const { return new FeedBack(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif