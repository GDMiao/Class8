#ifndef __RPC_H
#define __RPC_H

#include <map>

#include "gnthread.h"
#include "gnproto.h"
#include "gntimer.h"

namespace GNET
{

class Rpc : public Protocol
{
public:
	struct Data : public Marshal
	{
		virtual ~Data() { }
		virtual Data *Clone() const = 0;
		virtual void Destroy() { delete this; }
		virtual Data& operator = (const Data &rhs) = 0;
	};
private:
	class XID : public Marshal
	{
		union
		{
			struct
			{
				unsigned int count:31;
				unsigned int is_request:1;
			};
			unsigned int id;
		};
		static unsigned int xid_count;
        //FIX ME by linzihan
		//static Thread::Mutex locker_xid;
        friend class PollIO;
        static ASysThreadMutex* m_pLocker_xid;
	public:
		XID() : id(0) {
//             if( m_pLocker_xid == NULL)
//                 m_pLocker_xid = AThreadFactory::CreateThreadMutex();
        }

		OctetsStream& marshal(OctetsStream &os) const { return os << id; }
		const OctetsStream& unmarshal(const OctetsStream &os) { return os >> id; }
		bool IsRequest() const { return is_request; }
		void ClrRequest() { is_request = 0; }
		void SetRequest()
		{
			is_request = 1;
            //FIX ME by linzihan
			//Thread::Mutex::Scoped l(locker_xid);
            ACSWrapper l(m_pLocker_xid);
			count = xid_count++;
		}
		XID& operator =(const XID &rhs) { if (&rhs != this) id = rhs.id; return *this; }
		bool operator < (const XID &rhs) const { return count < rhs.count; }
	};

	class HouseKeeper : public Timer::Observer
	{
	public:
		HouseKeeper() { Timer::Attach(this); }
		void Update()
		{
            //FIX ME by linzihan
			//Thread::RWLock::WRScoped l(locker_map);
            ACSWrapper l(m_pLocker_map);
			for(Map::iterator it = map.begin(); it != map.end();)
			{
				Rpc *rpc = (*it).second;
				if (!rpc->TimePolicy(rpc->timer.Elapse()))
				{
					rpc->OnTimeout();
					rpc->Destroy();
					Map::iterator tmpIt = it++;
					map.erase(tmpIt);
				}
				else
					++it;
			}

		}
	};
	typedef std::map<XID, Rpc*> Map;
    //FIX ME by linzihan
	//static Thread::RWLock locker_map;
    friend class PollIO;        
    static ASysThreadMutex* m_pLocker_map;
	static HouseKeeper housekeeper;
	static Map map;
	Data *argument;
	Data *result;
	XID  xid;
	Timer timer;
public:
	~Rpc ()
	{
		argument->Destroy();
		result->Destroy();
	}
	Rpc(Type type, Data *arg, Data *res) : Protocol(type), argument(arg), result(res) { }
	Rpc(const Rpc &rhs) : Protocol(rhs), argument(rhs.argument->Clone()), result(rhs.result->Clone()) { }
	OctetsStream& marshal(OctetsStream &os) const
	{
		return os << xid << (xid.IsRequest() ? *argument : *result); 
	}
	const OctetsStream& unmarshal(const OctetsStream &os)
	{
		os >> xid;
		if (xid.IsRequest()) return os >> *argument;
        //FIX ME by linzihan
		//Thread::RWLock::RDScoped l(locker_map);
        ACSWrapper l(m_pLocker_map);
        
		Map::iterator it = map.find(xid);
		return it == map.end() ? os : os >> *((*it).second->result);
	}

	void Notify(Manager *mgr, Manager::Session::ID sid)
	{
		if (!xid.IsRequest()){
			Rpc *rpc;
			{
                //FIX ME by linzihan
				//Thread::RWLock::WRScoped l(locker_map);
                ACSWrapper l(m_pLocker_map);
				Map::iterator it = map.find(xid);
				if (it == map.end()) return;
				rpc = (*it).second;
				map.erase(it);
			}
			mgr->OnRecvProtocol(sid, rpc);
			this->Destroy();
		}else{
			xid.ClrRequest();
			mgr->OnRecvProtocol(sid, this);
		}
		
		return;
	}

	virtual void Server(Data *argument, Data *result) { return; }
	virtual void Client(Data *argument, Data *result) { return; }
	virtual void OnTimeout(){};

	virtual bool TimePolicy(int timeout) const { return timeout < 5; }

	static Rpc *Call(Type type, const Data *arg)
	{
		Rpc *rpc = (Rpc *)Protocol::Create(type);
		rpc->xid.SetRequest();
		*rpc->argument = *arg;
		rpc->timer.Reset();
        //FIX ME by linzihan
		//Thread::RWLock::WRScoped l(locker_map);
        ACSWrapper l(m_pLocker_map);
		Map::iterator it = map.find(rpc->xid);
		if (it != map.end())
		{
			(*it).second->Destroy();
			(*it).second = rpc;
		}
		else
		{
			map.insert(std::make_pair(rpc->xid, rpc));
		}
		return rpc;
	}
    
	static Rpc *Call(Type type, const Data &arg)
    {
        return Call(type, &arg);
    }

	Data* GetArgument() const { return argument; }
	Data* GetResult() const { return result; }
	friend class HouseKeeper;   //VC6
};

};

#endif
