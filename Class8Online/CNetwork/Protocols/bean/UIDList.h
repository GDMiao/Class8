#ifndef __GNET_UIDLIST_H
#define __GNET_UIDLIST_H

#include "rpcdefs.h"



namespace GNET
{
	class UIDList : public GNET::Rpc::Data
	{
	public:
		std::vector<int64_t>		uidlist;

		UIDList(){}

		UIDList(const UIDList &rhs)
			: uidlist(rhs.uidlist) { }

		Rpc::Data *Clone() const { return new UIDList(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const UIDList *r = dynamic_cast<const UIDList *>(&rhs);
			if (r && r != this)
			{
				uidlist = r->uidlist;
			}
			return *this;
		}

		UIDList& operator = (const UIDList &rhs)
		{
			const UIDList *r = &rhs;
			if (r && r != this)
			{
				uidlist = r->uidlist;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << uidlist;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> uidlist;
			return os;
		}
	};
}

#endif