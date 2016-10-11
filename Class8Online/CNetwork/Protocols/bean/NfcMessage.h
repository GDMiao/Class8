#ifndef __GNET_NFCMESSAGE_H
#define __GNET_NFCMESSAGE_H

#include "rpcdefs.h"



namespace GNET
{
	class NfcMessage : public GNET::Rpc::Data
	{
	public:
		Octets		title;
		Octets		content;
		Octets		url;

		NfcMessage(){}

		NfcMessage(const NfcMessage &rhs)
			: title(rhs.title),
			content(rhs.content),
			url(rhs.url) { }

		Rpc::Data *Clone() const { return new NfcMessage(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const NfcMessage *r = dynamic_cast<const NfcMessage *>(&rhs);
			if (r && r != this)
			{
				title = r->title;
				content = r->content;
				url = r->url;
			}
			return *this;
		}

		NfcMessage& operator = (const NfcMessage &rhs)
		{
			const NfcMessage *r = &rhs;
			if (r && r != this)
			{
				title = r->title;
				content = r->content;
				url = r->url;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << title;
			os << content;
			os << url;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> title;
			os >> content;
			os >> url;
			return os;
		}
	};
}

#endif