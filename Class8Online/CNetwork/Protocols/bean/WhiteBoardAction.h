#ifndef __GNET_WHITEBOARDACTION_H
#define __GNET_WHITEBOARDACTION_H

#include "rpcdefs.h"



namespace GNET
{
	class WhiteBoardAction : public GNET::Rpc::Data
	{
	public:
		int64_t		userid;
		int64_t		cid;
		int64_t		oweruid;
		int		pageId;
		int		paintId;
		char		paintype;
		Octets		arguments;

		WhiteBoardAction()
			: userid(0),
			cid(0),
			oweruid(0),
			pageId(0),
			paintId(0),
			paintype(0){}

		WhiteBoardAction(const WhiteBoardAction &rhs)
			: userid(rhs.userid),
			cid(rhs.cid),
			oweruid(rhs.oweruid),
			pageId(rhs.pageId),
			paintId(rhs.paintId),
			paintype(rhs.paintype),
			arguments(rhs.arguments) { }

		Rpc::Data *Clone() const { return new WhiteBoardAction(*this); }

		Rpc::Data& operator = (const Rpc::Data &rhs)
		{
			const WhiteBoardAction *r = dynamic_cast<const WhiteBoardAction *>(&rhs);
			if (r && r != this)
			{
				userid = r->userid;
				cid = r->cid;
				oweruid = r->oweruid;
				pageId = r->pageId;
				paintId = r->paintId;
				paintype = r->paintype;
				arguments = r->arguments;
			}
			return *this;
		}

		WhiteBoardAction& operator = (const WhiteBoardAction &rhs)
		{
			const WhiteBoardAction *r = &rhs;
			if (r && r != this)
			{
				userid = r->userid;
				cid = r->cid;
				oweruid = r->oweruid;
				pageId = r->pageId;
				paintId = r->paintId;
				paintype = r->paintype;
				arguments = r->arguments;
			}
			return *this;
		}


		OctetsStream& marshal(OctetsStream& os) const
		{
			os << userid;
			os << cid;
			os << oweruid;
			os << pageId;
			os << paintId;
			os << paintype;
			os << arguments;
			return os;
		}

		const OctetsStream& unmarshal(const OctetsStream& os)
		{
			os >> userid;
			os >> cid;
			os >> oweruid;
			os >> pageId;
			os >> paintId;
			os >> paintype;
			os >> arguments;
			return os;
		}
	};
}

#endif