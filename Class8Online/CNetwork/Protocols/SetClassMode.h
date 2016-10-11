#ifndef __GNET_SETCLASSMODE_H
#define __GNET_SETCLASSMODE_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class SetClassMode : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1009 };

		enum
		{
			UNSPEAKABLE = 0,
			SPEAKABLE = 1,
			TEXTABLE = 2,
			UTEXTABLE = 3,
			ASIDEABLE = 4,
			UNASIDEABLE = 5,
			SEND_PIC = 8,
			UNSEND_PIC = 9,
			LOCK = 16,
			UNLOCK = 17,
		};

		int64_t		receiver;
		int64_t		userid;
		int64_t		cid;
		char		classmode;

	public:
		SetClassMode() { type = PROTOCOL_TYPE; }
		SetClassMode(void*) : Protocol(PROTOCOL_TYPE) { }
		SetClassMode (int64_t	l_receiver, int64_t	l_userid, int64_t	l_cid, char	l_classmode)
		: receiver(l_receiver),
		userid(l_userid),
		cid(l_cid),
		classmode(l_classmode)
		{
			type = PROTOCOL_TYPE;
		}

		SetClassMode(const SetClassMode &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			userid(rhs.userid),
			cid(rhs.cid),
			classmode(rhs.classmode){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << userid;
			os << cid;
			os << classmode;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> userid;
			os >> cid;
			os >> classmode;
			return os;
		}

		virtual Protocol* Clone() const { return new SetClassMode(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif