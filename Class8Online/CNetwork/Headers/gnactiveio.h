#ifndef __ACTIVEIO_H
#define __ACTIVEIO_H

#include "gnconf.h"
#include "gnpollio.h"
#include "gnnetio.h"
#include "NetTran.h"

namespace GNET
{
class ActiveIO : PollIO
{
	enum Type { STREAM, DGRAM, DGRAM_BROADCAST };
	enum Status { CONNECTING, CONNECTED, ABORTING };
	Type type;
	int closing;
	NetSession *assoc_session;
	SockAddr sa;

	int UpdateEvent()
	{
		return (closing!=CONNECTING) ? -1 : (POLL_STATE_OUT | POLL_STATE_ERR);
	}

	void PollOut()
	{
		Close(CONNECTED);
	}

	void PollErr()
	{
		Close(ABORTING);
	}

	ActiveIO(SOCKET x, const SockAddr &saddr, NetSession *s, Type t) :
		PollIO(x), type(t), closing(t == STREAM ? CONNECTING:CONNECTED), assoc_session(s), sa(saddr)
	{
		assoc_session->LoadConfig();
        int err = NetSys::GetNetError();
		if (type != DGRAM_BROADCAST)
        {
            int ret = 0;//NetSys::Connect(fd, sa, sa.GetLen());
            
            const sockaddr * s_addr = (const sockaddr *)sa;
            if(s_addr->sa_family == AF_INET)
            {
                ret = NetSys::Connect(fd, sa, sa.GetLen());
            }
            else
            {
                sockaddr_in6 addrServ;
                memset(&addrServ,0,sizeof(addrServ));
                addrServ.sin6_len = sizeof(sockaddr_in6);
                addrServ.sin6_family = AF_INET6;
                addrServ.sin6_port = ((const sockaddr_in6*)saddr)->sin6_port;
                
                memcpy(&addrServ.sin6_addr,&((const sockaddr_in6*)saddr)->sin6_addr,sizeof(in6_addr));
                
                ret = connect(fd,(struct sockaddr*)&addrServ,sizeof(addrServ));
            }
            
            err = NetSys::GetNetError();
        }
		PollIO::WakeUp();
	}
public:
	~ActiveIO()
	{
		if (type == STREAM)
		{
			if (closing==CONNECTED)
			{
				{
                    //FIX ME by linzihan
					//Thread::Mutex::Scoped l(PollIO::LockerNew());
                    ACSWrapper l(PollIO::LockerNew());
					new StreamIO(fd, assoc_session);
				}
				PollIO::WakeUp();
			}
			else
			{
				assoc_session->OnAbort();
				assoc_session->Destroy();
				NetSys::CloseSocket(fd);
			}
		}
		else
		{
            //FIX ME by linzihan
			//Thread::Mutex::Scoped l(PollIO::LockerNew());
            ACSWrapper l(PollIO::LockerNew());
			new DgramClientIO(fd, assoc_session, sa);
        }
	}

	const NetSession * GetSession() { return assoc_session; }

	void Close(int code) { closing = code; }
	SOCKET GetSocket() { return fd; }

	static ActiveIO *Open(NetSession *assoc_session) 
	{
		Conf *conf = Conf::GetInstance();
		Conf::section_type section = assoc_session->Identification();
		Conf::value_type type = conf->find(section, ("type"));
		SockAddr sa;

		SOCKET s;
		int optval = 1;
		Type t = STREAM;
        
        const char * host = conf->find(section, ("address")).c_str();
        const char * port = conf->find(section, ("port")).c_str();
        
        char szAddr[128]={0};
        
        bool isIp6 = getNetAddr(host,atoi(port),szAddr);
        if(isIp6)
        {
            struct sockaddr_in6 *addr = (sockaddr_in6*)sa;
            memset(addr, 0, sizeof(*addr));
            
            s = socket(AF_INET6,SOCK_STREAM,IPPROTO_TCP);
            
            addr->sin6_len = sizeof(sockaddr_in6);
            addr->sin6_family= AF_INET6;
            inet_pton(AF_INET6,szAddr,(void*)&addr->sin6_addr);
            addr->sin6_port = NetSys::Htons(atoi(port));
        }
        else
        {
            struct sockaddr_in *addr = (sockaddr_in*)sa;
            memset(addr, 0, sizeof(*addr));
            
            s = NetSys::Socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
            
            addr->sin_len = sizeof(sockaddr_in);
            addr->sin_family = AF_INET;
            addr->sin_addr.s_addr = NetSys::Inet_addr(host);
            addr->sin_port = NetSys::Htons(atoi(port));
        }
        
        assoc_session->OnCheckAddress(sa);
        
		if (!ASys::StrCmpNoCase(type.c_str(), ("tcp")))
		{
			t = STREAM;
            
            if(isIp6)
            {
                s=socket(AF_INET6,SOCK_STREAM,IPPROTO_TCP);
            }
            else
            {
                s = NetSys::Socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
            }
			
            NetSys::Setsockopt(s, SOL_SOCKET, SO_KEEPALIVE, (char*)&optval, sizeof(optval));

			optval = atoi(conf->find(section, ("so_sndbuf")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_SNDBUF, (char*)&optval, sizeof(optval));
			optval = atoi(conf->find(section, ("so_rcvbuf")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_RCVBUF, (char*)&optval, sizeof(optval));
			optval = atoi(conf->find(section, ("tcp_nodelay")).c_str());
			if (optval) NetSys::Setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char*)&optval, sizeof(optval));
		}
		else if (!ASys::StrCmpNoCase(type.c_str(), ("udp")))
		{
            if(isIp6)
            {
                s = socket(AF_INET6,SOCK_DGRAM,IPPROTO_UDP);
            }
            else
            {
                s = NetSys::Socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
            }
            
			optval = atoi(conf->find(section, ("so_broadcast")).c_str());
			if (optval)
			{
				NetSys::Setsockopt(s, SOL_SOCKET, SO_BROADCAST, (char*)&optval, sizeof(optval));
				t = DGRAM_BROADCAST;
			}
			else
				t = DGRAM;
			optval = atoi(conf->find(section, ("so_sndbuf")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_SNDBUF, (char*)&optval, sizeof(optval));
			optval = atoi(conf->find(section, ("so_rcvbuf")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_RCVBUF, (char*)&optval, sizeof(optval));
		}
		else
        {
            s = A_INVALID_SOCKET;
        }
        
        //FIX ME by linzihan
		//Thread::Mutex::Scoped l(PollIO::LockerNew());
        
        ACSWrapper l(PollIO::LockerNew());
		return s != A_INVALID_SOCKET ? new ActiveIO(s, sa, assoc_session, t) : NULL;
	}

	static ActiveIO *Open(NetSession *assoc_session, const char* host, unsigned short port) 
	{
		Conf *conf = Conf::GetInstance();
		Conf::section_type section = assoc_session->Identification();
		SockAddr sa;
        
        int err = NetSys::GetNetError();
        int ret = 0;
		
        SOCKET s;
		int optval = 1;
		Type t = STREAM;
        char szAddr[128]={0};
        
        bool isIp6 = getNetAddr(host,port,szAddr);
        if(isIp6)
        {
            struct sockaddr_in6 *addr = (sockaddr_in6 *)sa;
            memset(addr, 0, sizeof(*addr));
            addr->sin6_len = sizeof(sockaddr_in6);
            
            err = NetSys::GetNetError();
            s = socket(AF_INET6,SOCK_STREAM,IPPROTO_TCP);
            addr->sin6_family= AF_INET6;
            inet_pton(AF_INET6,szAddr,(void*)&addr->sin6_addr);
            addr->sin6_port = NetSys::Htons(port);
        }
        else
        {
            struct sockaddr_in *addr = (sockaddr_in *)sa;
            memset(addr, 0, sizeof(*addr));
            addr->sin_len = sizeof(sockaddr_in);
            
            err = NetSys::GetNetError();
            s = NetSys::Socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
            addr->sin_family = AF_INET;
            addr->sin_addr.s_addr = NetSys::Inet_addr(host);
            addr->sin_port = NetSys::Htons(port);
        }
        
		assoc_session->OnCheckAddress(sa);
        
        err = NetSys::GetNetError();
		ret = NetSys::Setsockopt(s, SOL_SOCKET, SO_KEEPALIVE, (char*)&optval, sizeof(optval));
        err = NetSys::GetNetError();
		
        //optval = atoi(conf->find(section, ("so_sndbuf")).c_str());
		//if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_SNDBUF, &optval, sizeof(optval));
		//if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_RCVBUF, &optval, sizeof(optval));
		//optval = atoi(conf->find(section, ("tcp_nodelay")).c_str());
		
        optval = 8192;
		ret = NetSys::Setsockopt(s, SOL_SOCKET, SO_SNDBUF, (char*)&optval, sizeof(optval));
		optval = 8192;
		ret = NetSys::Setsockopt(s, SOL_SOCKET, SO_RCVBUF, (char*)&optval, sizeof(optval));
		
        if (optval) NetSys::Setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char*)&optval, sizeof(optval));
        
        //FIX ME by linzihan
		//Thread::Mutex::Scoped l(PollIO::LockerNew());
        
        ACSWrapper l(PollIO::LockerNew());
		return s != A_INVALID_SOCKET ? new ActiveIO(s, sa, assoc_session, t) : NULL;
	}
};

};

#endif
