#ifndef __GNET_CLASSACTION_H
#define __GNET_CLASSACTION_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class ClassAction : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1011 };

		enum
		{
			ASK_SPEAK = 1,
			CANCEL_SPEAK = 2,
			ALLOW_SPEAK = 3,
			CLEAN_SPEAK = 4,
			KICKOUT = 5,
			ADD_STUDENT_VIDEO = 6,
			DEL_STUDENT_VIDEO = 7,
			OPEN_VOICE = 8,
			CLOSE_VOICE = 9,
			OPEN_VIDEO = 10,
			CLOSE_VIDEO = 11,
			MUTE = 12,
			UNMUTE = 13,
			ENTER_GROUP = 14,
			LEAVE_GROUP = 15,
			CALL_TEACHER = 16,
		};

		int64_t		receiver;
		char		actiontype;
		int64_t		userid;
		int64_t		cid;
		int64_t		teacheruid;

	public:
		ClassAction() { type = PROTOCOL_TYPE; }
		ClassAction(void*) : Protocol(PROTOCOL_TYPE) { }
		ClassAction (int64_t	l_receiver, char	l_actiontype, int64_t	l_userid, int64_t	l_cid, int64_t	l_teacheruid)
		: receiver(l_receiver),
		actiontype(l_actiontype),
		userid(l_userid),
		cid(l_cid),
		teacheruid(l_teacheruid)
		{
			type = PROTOCOL_TYPE;
		}

		ClassAction(const ClassAction &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			actiontype(rhs.actiontype),
			userid(rhs.userid),
			cid(rhs.cid),
			teacheruid(rhs.teacheruid){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << actiontype;
			os << userid;
			os << cid;
			os << teacheruid;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> actiontype;
			os >> userid;
			os >> cid;
			os >> teacheruid;
			return os;
		}

		virtual Protocol* Clone() const { return new ClassAction(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif