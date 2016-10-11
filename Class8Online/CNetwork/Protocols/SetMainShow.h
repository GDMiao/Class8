#ifndef __GNET_SETMAINSHOW_H
#define __GNET_SETMAINSHOW_H

#include "rpcdefs.h"
#include "state.hxx"



namespace GNET
{
	class SetMainShow : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1052 };

		enum
		{
			CW_WB = 1,
			VEDIO = 2,
		};

		int64_t		receiver;
		int64_t		teacher;
		int64_t		classid;
		char		showtype;

	public:
		SetMainShow() { type = PROTOCOL_TYPE; }
		SetMainShow(void*) : Protocol(PROTOCOL_TYPE) { }
		SetMainShow (int64_t	l_receiver, int64_t	l_teacher, int64_t	l_classid, char	l_showtype)
		: receiver(l_receiver),
		teacher(l_teacher),
		classid(l_classid),
		showtype(l_showtype)
		{
			type = PROTOCOL_TYPE;
		}

		SetMainShow(const SetMainShow &rhs)
			: Protocol(rhs),
			receiver(rhs.receiver),
			teacher(rhs.teacher),
			classid(rhs.classid),
			showtype(rhs.showtype){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << receiver;
			os << teacher;
			os << classid;
			os << showtype;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> receiver;
			os >> teacher;
			os >> classid;
			os >> showtype;
			return os;
		}

		virtual Protocol* Clone() const { return new SetMainShow(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  1024; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif