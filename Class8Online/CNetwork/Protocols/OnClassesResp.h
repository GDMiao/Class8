#ifndef __GNET_ONCLASSESRESP_H
#define __GNET_ONCLASSESRESP_H

#include "rpcdefs.h"
#include "state.hxx"

#include "ClassInfoBean.h"


namespace GNET
{
	class OnClassesResp : public GNET::Protocol
	{
	public:
		enum { PROTOCOL_TYPE = 1031 };

		int		sid;
		std::vector<ClassInfoBean>		classlist;

	public:
		OnClassesResp() { type = PROTOCOL_TYPE; }
		OnClassesResp(void*) : Protocol(PROTOCOL_TYPE) { }
		OnClassesResp (int	l_sid, const std::vector<ClassInfoBean>& l_classlist)
		: sid(l_sid),
		classlist(l_classlist)
		{
			type = PROTOCOL_TYPE;
		}

		OnClassesResp(const OnClassesResp &rhs)
			: Protocol(rhs),
			sid(rhs.sid),
			classlist(rhs.classlist){ }


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << sid;
			os << classlist;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> sid;
			os >> classlist;
			return os;
		}

		virtual Protocol* Clone() const { return new OnClassesResp(*this); }

		int PriorPolicy( ) const { return  1; }

		bool SizePolicy(size_t size) const { return size <=  655350; }

		void Process(Manager *manager, Manager::Session::ID sid)
		{
			// TODO
		}
	};
}

#endif