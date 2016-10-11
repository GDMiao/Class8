#ifndef __NETIO_H
#define __NETIO_H

#include <string>
#include <map>

#include "gnoctets.h"
#include "gnpollio.h"
#include "gnsecure.h"
#include "gnthread.h"
#include "gnconf.h"
//#include "EC_Utility.h"

namespace GNET
{

#define ERRSIZE 128
extern char errormsg[ERRSIZE];

class SockAddr
{
	Octets addr;
public:	
	SockAddr() {}
	template<typename T> SockAddr(const T &sa) : addr(&sa, sizeof(sa)) { }
	SockAddr(const SockAddr &rhs) : addr(rhs.addr) { }
	int GetLen() const { return addr.size(); }
	template<typename T> operator T* () { addr.resize(sizeof(T)); return (T *)addr.begin(); }
	template<typename T> operator const T* () const { return (const T *)addr.begin(); }
	operator const sockaddr * () const { return (const sockaddr *)addr.begin(); }
	operator const sockaddr_in * () const { return (const sockaddr_in *)addr.begin(); }
    operator const sockaddr_in6 * () const { return (const sockaddr_in6 *)addr.begin(); }
	operator sockaddr_in * () { addr.resize(sizeof(sockaddr_in)); return (sockaddr_in *)addr.begin(); }
    operator sockaddr_in6 * () { addr.resize(sizeof(sockaddr_in6)); return (sockaddr_in6 *)addr.begin(); }

};

class NetSession
{
	friend class NetIO;
	friend class StreamIO;
	friend class DgramServerIO;
	friend class DgramClientIO;
	enum { DEFAULTIOBUF = 8192 };
	bool    closing;
	Octets	ibuffer;
	Octets	obuffer;
	Octets  isecbuf;
	Security *isec;
	Security *osec;
protected:
	ASysThreadMutex* m_pLocker;
	virtual ~NetSession ()
	{
		isec->Destroy();
		osec->Destroy();
		A_SAFEDELETE(m_pLocker);
	}
	NetSession(const NetSession &rhs) : closing(false), ibuffer(rhs.ibuffer.capacity()), 
		obuffer(rhs.obuffer.capacity()), isec(rhs.isec->Clone()), osec(rhs.osec->Clone())
    {
        m_pLocker = AThreadFactory::CreateThreadMutex();
    }

	bool Output(Octets &data)
	{
		if (data.size() + obuffer.size() > obuffer.capacity()) return false;
		osec->Update(data);
		obuffer.insert(obuffer.end(), data.begin(), data.end());
		return true;
	}

	Octets& Input()
	{
		isec->Update(ibuffer);
		isecbuf.insert(isecbuf.end(), ibuffer.begin(), ibuffer.end());
		ibuffer.clear();
		return isecbuf;
	}

	void SetISecurity(Security::Type type, const Octets &key)
	{
        //FIX ME by linzihan
		//Thread::Mutex::Scoped l(locker);
        ACSWrapper l(m_pLocker);
		isec->Destroy();
		isec = Security::Create(type);
		isec->SetParameter(key);
	}
	
	void SetOSecurity(Security::Type type, const Octets &key)
	{
        //FIX ME by linzihan
		//Thread::Mutex::Scoped l(locker);
        ACSWrapper l(m_pLocker);
		osec->Destroy();
		osec = Security::Create(type);
		osec->SetParameter(key);
	}
public:
	NetSession() : closing(false), ibuffer(DEFAULTIOBUF), obuffer(DEFAULTIOBUF), 
		isec(Security::Create(NULLSECURITY)), osec(Security::Create(NULLSECURITY)){
        
            m_pLocker = AThreadFactory::CreateThreadMutex();
        }

	void LoadConfig()
	{
		Conf *conf = Conf::GetInstance();
		Conf::section_type section = Identification();
		auint32 size;
		if ((size = atoi(conf->find(section, ("ibuffermax")).c_str()))) ibuffer.reserve(size);
		if ((size = atoi(conf->find(section, ("obuffermax")).c_str()))) obuffer.reserve(size);
		if ((size = atoi(conf->find(section, ("isec")).c_str()))) 
		{
			Conf::value_type key = conf->find(section, ("iseckey"));
			SetISecurity(size, Octets(&key[0], key.size()));
		}
		if ((size = atoi(conf->find(section, ("osec")).c_str()))) 
		{
			Conf::value_type key = conf->find(section, ("oseckey"));
			SetOSecurity(size, Octets(&key[0], key.size()));
		}
	}

	void ResizeBuffer( auint32 bufsize)
	{
			ibuffer.reserve( bufsize);
			obuffer.reserve(bufsize);
	}

	virtual void Close() { closing = true; }

	virtual std::string Identification () const = 0;
	virtual void OnRecv() = 0;
	virtual bool NoMoreData() const = 0;
	virtual void OnSend() = 0;
	virtual void OnOpen() { }
	virtual void OnClose() { }
	virtual void OnAbort() { }
	virtual	NetSession* Clone() const = 0;
	virtual void Destroy() { delete this; }
	virtual void OnCheckAddress(SockAddr &) const { }
};

class NetIO : public PollIO
{
protected:
	NetSession *session;
	Octets	*ibuf;
	Octets	*obuf;
	~NetIO() { NetSys::CloseSocket(fd); }
	NetIO(int fd, NetSession *s) : PollIO(fd), session(s), ibuf(&s->ibuffer), obuf(&s->obuffer) { }
};

class StreamIO : public NetIO
{
	void PollIn()
	{		
		int recv_bytes;
		if ((recv_bytes = NetSys::Recv(fd, (char*)ibuf->end(), ibuf->capacity() - ibuf->size(), 0)) > 0)
		{
			ibuf->resize(ibuf->size() + recv_bytes);
			return;
		}
		int err = NetSys::GetNetError();
		if(recv_bytes!=A_SOCKET_ERROR || err!=A_OULDBLOCK)
		{
			obuf->clear();
			session->closing = true;
			AString errstr;
			NetSys::GetNetErrorString(err,errstr);
			//sprintf(errormsg, glb_GetString("RECEIVE_NET_ERROR_FORMAT"), (const char*)errstr);
		}
	}

	void PollOut()
	{
		int send_bytes;
		if ((send_bytes = NetSys::Send(fd,(const char*) obuf->begin(), obuf->size(), 0)) > 0)
		{
			obuf->erase(obuf->begin(), (char*)obuf->begin() + send_bytes);
			return;
		}
		int err = NetSys::GetNetError();
		if(send_bytes!=A_SOCKET_ERROR || err!=A_OULDBLOCK)
		{
			obuf->clear();
			AString errstr;
			NetSys::GetNetErrorString(err,errstr);
			//sprintf(errormsg, glb_GetString("SEND_NET_ERROR_FORMAT"), (const char*)errstr);
			session->closing = true;
		}
	}

	int UpdateEvent()
	{
		int event = 0;
		//FIX ME by linzihan
		//Thread::Mutex::Scoped l(session->locker);
        ACSWrapper l(session->m_pLocker);
        
        if (session->closing)
			return -1;
        
		if (ibuf->size())
			session->OnRecv();
		if (!session->closing)
			session->OnSend();
		if (obuf->size()||!(session->NoMoreData()))
			event = POLL_STATE_OUT;

		if (ibuf->size() < ibuf->capacity())
			event |= POLL_STATE_IN;
		return event;
	}
public:
	~StreamIO()
	{
		session->OnClose();
		session->Destroy();
	}

	StreamIO(SOCKET fd, NetSession *s) : NetIO(fd, s)
	{
		session->OnOpen();
	}
};

class DgramClientIO : public NetIO
{
	SockAddr peer;
	void PollIn()
	{
		int recv_bytes;
		if ((recv_bytes = NetSys::Recv(fd, (char*)ibuf->end(), ibuf->capacity() - ibuf->size(),0)) > 0)
		{
			ibuf->resize(ibuf->size() + recv_bytes);
			return;
		}

	}

	int UpdateEvent()
	{
        //FIX ME by linzihan
		//Thread::Mutex::Scoped l(session->locker);
        ACSWrapper l(session->m_pLocker);
		if (ibuf->size())
			session->OnRecv();
		session->OnSend();
		if (obuf->size())
		{
            NetSys::Sendto(fd, (const char*)obuf->begin(), obuf->size(), 0, peer, peer.GetLen());
			obuf->clear();
		}
		return session->closing ? -1 : POLL_STATE_IN;
	}
public:
	~DgramClientIO()
	{
		session->OnClose();
		session->Destroy();
	}

	DgramClientIO(SOCKET fd, NetSession *s, const SockAddr &sa) : NetIO(fd, s), peer(sa) 
	{
		session->OnOpen();
	}
};

class DgramServerIO : public NetIO
{
	struct compare_SockAddr
	{
		bool operator() (const SockAddr &sa1, const SockAddr &sa2) const
		{
			const struct sockaddr_in *s1 = sa1;
			const struct sockaddr_in *s2 = sa2;

			return s1->sin_addr.s_addr < s2->sin_addr.s_addr ||
				(s1->sin_addr.s_addr == s2->sin_addr.s_addr && s1->sin_port < s2->sin_port);
		}
	};
	typedef std::map<SockAddr, NetSession *, compare_SockAddr> Map;
	Map map;

	void PollIn()
	{
		struct sockaddr_in addr;
		auint32 len;
		int recv_bytes;
		while ((recv_bytes = NetSys::Recvfrom(fd, (char*)ibuf->begin(), ibuf->capacity(), 0, (struct sockaddr*)&addr, &len)) > 0)
		{
			Map::iterator it = map.find(addr);
			if (it == map.end())
			{
				NetSession *s = session->Clone();
				it = map.insert(std::make_pair(addr, s)).first;
				s->OnOpen();
			}
			Octets &i = (*it).second->ibuffer;
			if (i.size() + recv_bytes < i.capacity())
				i.insert(i.end(), ibuf->begin(), recv_bytes);
		}
	}

	int UpdateEvent()
	{
		for (Map::iterator it = map.begin(); it != map.end();)
		{
			const SockAddr &sa = (*it).first;
			NetSession *session = (*it).second;
			Octets *ibuf  = &session->ibuffer;
			Octets *obuf  = &session->obuffer;
            //FIX ME by linzihan
			//Thread::Mutex::Scoped l(session->locker);
            ACSWrapper l(session->m_pLocker);
			if (ibuf->size())
				session->OnRecv();
			session->OnSend();
			if (obuf->size())
			{
               
                NetSys::Sendto(fd, (const char*)obuf->begin(), obuf->size(), 0, (const struct sockaddr *)sa, sa.GetLen());
				obuf->clear();
			}

			if (session->closing)
			{
#if !defined(A_PLATFORM_ANDROID)
				Map::const_iterator tmpIt = it;
				it = map.erase(tmpIt);
#else
                Map::iterator tmpIt = it++;
				map.erase(tmpIt);
#endif
				session->OnClose();
				session->Destroy();
			}
			else
			{
				++it;
			}
		}
		session->OnSend();
		return session->closing ? -1 : POLL_STATE_IN;
	}
public:
	~DgramServerIO()
	{
		for (Map::iterator it = map.begin(); it != map.end(); ++it)
		{
			NetSession *session = (*it).second;
			session->OnClose();
			session->Destroy();
		}
		session->Destroy();
	}

	DgramServerIO(int fd, NetSession *s) : NetIO(fd, s)
	{
	}
};

};

#endif
