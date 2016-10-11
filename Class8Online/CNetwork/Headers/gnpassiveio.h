#ifndef __PASSIVEIO_H
#define __PASSIVEIO_H
#include "NetSys.h"
#include <sys/types.h>

#include "gnconf.h"
#include "gnpollio.h"
#include "gnnetio.h"

namespace GNET
{

class PassiveIO : PollIO
{
	enum Type { STREAM, DGRAM };
	NetSession *assoc_session;
	Type type;
	bool closing;

	int UpdateEvent()
	{
		return closing ? -1 : POLL_STATE_IN;
	}

	void PollIn()
	{
		if (type == STREAM)
		{
			SOCKET s = NetSys::Accept(fd, 0, 0);
			if (s != A_INVALID_SOCKET)
			{
                //FIX ME by linzihan
				//Thread::Mutex::Scoped l(PollIO::LockerNew());
                ACSWrapper l(PollIO::LockerNew());
				new StreamIO(s, assoc_session->Clone());
			}
		}
		else Close();
	}

	PassiveIO (SOCKET x, NetSession *y, Type t) : 
		PollIO(x), assoc_session(y), type(t), closing(false)
	{
		assoc_session->LoadConfig();
	}
public:
	virtual ~PassiveIO ()
	{
		if (type == STREAM)
		{
			assoc_session->Destroy();
			NetSys::CloseSocket(fd);
		}
		else 
		{
			{
                //FIX ME by linzihan
				//Thread::Mutex::Scoped l(PollIO::LockerNew());
                ACSWrapper l(PollIO::LockerNew());
				new DgramServerIO(fd, assoc_session);
			}
			PollIO::WakeUp();
		}
	}

	void Close() { closing = true; }

	static PassiveIO *Open(NetSession *assoc_session)
	{
		Conf *conf = Conf::GetInstance();
		Conf::section_type section = assoc_session->Identification(); 
		Conf::value_type type = conf->find(section, ("type"));
		SockAddr sa;

		SOCKET s;
		char optval = 1;
		Type t = STREAM;
        
        
        const char * host = conf->find(section, ("address")).c_str();
        const char * port = conf->find(section, ("port")).c_str();
        
        char szAddr[128]={0};
        
        bool isIp6 = getNetAddr(host,atoi(port),szAddr);
        if(isIp6)
        {
            struct sockaddr_in6 *addr = sa;
            memset(addr, 0, sizeof(*addr));
            
            addr->sin6_len = sizeof(sockaddr_in6);
            addr->sin6_family= AF_INET6;
            inet_pton(AF_INET6,szAddr,&addr->sin6_addr);
            addr->sin6_port = NetSys::Htons(atoi(port));
        }
        else
        {
            struct sockaddr_in *addr = sa;
            memset(addr, 0, sizeof(*addr));
            
            addr->sin_len = sizeof(sockaddr_in);
            addr->sin_family = AF_INET;
            addr->sin_addr.s_addr = NetSys::Inet_addr(host);
            
            if(addr->sin_addr.s_addr == INADDR_NONE)
            {
                addr->sin_addr.s_addr = INADDR_ANY;
            }
            
            addr->sin_port = NetSys::Htons(atoi(port));
        }
        
        assoc_session->OnCheckAddress(sa);
        
		if (!ASys::StrCmpNoCase(type.c_str(), ("tcp")))
		{
			t = STREAM;
            
            if(isIp6)
            {
                s = socket(AF_INET6,SOCK_STREAM,IPPROTO_TCP);
            }
            else
            {
                s = NetSys::Socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
            }
			
			NetSys::Setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));
			NetSys::Setsockopt(s, SOL_SOCKET, SO_KEEPALIVE, &optval, sizeof(optval));

			optval = atoi(conf->find(section, ("so_sndbuf")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_SNDBUF, &optval, sizeof(optval));
			optval = atoi(conf->find(section, ("so_rcvbuf")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_RCVBUF, &optval, sizeof(optval));
			optval = atoi(conf->find(section, ("tcp_nodelay")).c_str());
			if (optval) NetSys::Setsockopt(s, IPPROTO_TCP, TCP_NODELAY, &optval, sizeof(optval));

            NetSys::Bind (s, sa, sa.GetLen());
			optval = atoi(conf->find(section, ("listen_backlog")).c_str());
            NetSys::Listen (s, optval ? optval : SOMAXCONN);
		}
		else if (!ASys::StrCmpNoCase(type.c_str(), ("udp")))
		{
			t = DGRAM;
            
            if(isIp6)
            {
                s = socket(AF_INET6,SOCK_DGRAM,IPPROTO_UDP);
            }
            else
            {
                s = NetSys::Socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
            }

			NetSys::Setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));

			optval = atoi(conf->find(section, ("so_broadcast")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_BROADCAST, &optval, sizeof(optval));
			optval = atoi(conf->find(section, ("so_sndbuf")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_SNDBUF, &optval, sizeof(optval));
			optval = atoi(conf->find(section, ("so_rcvbuf")).c_str());
			if (optval) NetSys::Setsockopt(s, SOL_SOCKET, SO_RCVBUF, &optval, sizeof(optval));

            NetSys::Bind (s, sa, sa.GetLen());
		}
		else
			s = A_INVALID_SOCKET;
        // FIX ME by linzihan
		//Thread::Mutex::Scoped l(PollIO::LockerNew());
        ACSWrapper l(PollIO::LockerNew());
		return s == A_INVALID_SOCKET ? NULL : new PassiveIO(s, assoc_session, t);
	}
};

};

#endif
