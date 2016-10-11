#ifndef __GNET_SHOWINFO_H
#define __GNET_SHOWINFO_H

#include "rpcdefs.h"



namespace GNET
{
	class ShowInfo : public GNET::Rpc::Data
	{
	public:
		enum
		{
			BLANK = 0,
			COURSEWARE = 1,
			WHITEBOARD = 2,
		};

		char		showtype;
		Octets		name;
		int		page;

		ShowInfo()
			: showtype(0),
			page(0){}

		ShowInfo(const ShowInfo &rhs)
			: showtype(rhs.showtype),
			name(rhs.name),
			page(rhs.page) { }

		Rpc::Data *Clone() const { return new ShowInfo(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const ShowInfo *r = dynamic_cast<const ShowInfo *>(&rhs);
			if (r && r != this)
			{
				showtype = r->showtype;
				name = r->name;
				page = r->page;
			}
			return *this;
		}

		ShowInfo& operator = (const ShowInfo &rhs)
		{
			const ShowInfo *r = &rhs;
			if (r && r != this)
			{
				showtype = r->showtype;
				name = r->name;
				page = r->page;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << showtype;
			os << name;
			os << page;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> showtype;
			os >> name;
			os >> page;
			return os;
		}
	};
}

#endif