#ifndef __GNET_WHITEBOARDEVENT_H
#define __GNET_WHITEBOARDEVENT_H

#include "rpcdefs.h"
#include "state.hxx"

#include "WhiteBoardAction.h"


namespace GNET
{
	class WhiteBoardEvent : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1012 };

		enum
		{
			PEN = 1,
			ERASOR = 2,
			TXT = 3,
			LASER_POINT = 4,
			UNDO = 103,
		};

		int64_t		receiver;
		WhiteBoardAction		action;

	public:
		WhiteBoardEvent() { type = PROTOCOL_TYPE; }
		WhiteBoardEvent(void*) : Protocol(PROTOCOL_TYPE) { }
		WhiteBoardEvent (int64_t	l_receiver, const WhiteBoardAction& l_action)
		: receiver(l_receiver),
		action(l_action)
		{
			type = PROTOCOL_TYPE;
		}

		WhiteBoardEvent(const WhiteBoardEvent &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			action(rhs.action){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << action;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> action;
			return os;
		}

		virtual Protocol* Clone() const { return new WhiteBoardEvent(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  65536; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif