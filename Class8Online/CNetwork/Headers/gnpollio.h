#ifndef __POLLIO_H
#define __POLLIO_H

#include <map>
#include <vector>
#include <algorithm>
#include <functional>

#include "gnthread.h"
#include "gntimer.h"
#include "NetSys.h"
#include "AAssist.h"
#include "NetTran.h"

namespace GNET
{
    extern AThreadPool* g_pThreadPool;
    enum POLL_STATE
    {
        
        POLL_STATE_IN  = 0x1,
        POLL_STATE_OUT = 0x4,
        POLL_STATE_ERR = 0x8,
    };

class PollIO
{
	typedef std::map<SOCKET, PollIO*> IOMap;
	typedef std::vector<PollIO *> FDSet;
	static fd_set rfds, wfds, efds;

	static IOMap iomap;
	static FDSet fdset;
	static IOMap ionew;
    
    //FIX ME by linzihan
	//static Thread::Mutex locker_ionew;
	//static Thread::Mutex locker_poll;
    static ASysThreadMutex* m_pLocker_ionew;
    static ASysThreadMutex* m_pLocker_poll;
	static bool wakeup_scope;
	static bool wakeup_flag;
    static SOCKET  i_maxSocket;


	virtual int UpdateEvent() = 0;
	virtual void PollIn()  { }
	virtual void PollOut() { }
	virtual void PollErr() { }

	static void UpdateEvent(const IOMap::value_type iopair)
	{
		PollIO *io = iopair.second;

		if (io == NULL)
			return;

		int event = io->UpdateEvent();

		if (event == -1)
		{
			iomap[io->fd] = NULL;
			delete io;
			return;
		}

		if (event)
		{
			if (event & POLL_STATE_IN ) FD_SET(io->fd, &rfds);
			if (event & POLL_STATE_OUT) FD_SET(io->fd, &wfds);
			if (event & POLL_STATE_ERR) FD_SET(io->fd, &efds);
			fdset.push_back(io);
		}
	}

	static void TriggerEvent(PollIO *io)
	{
		if (FD_ISSET(io->fd, &rfds))
			io->PollIn();
		if (FD_ISSET(io->fd, &wfds))
			io->PollOut();
		if (FD_ISSET(io->fd, &efds))
			io->PollErr();

	}

protected:
	SOCKET fd;

	virtual ~PollIO() { }

	PollIO(SOCKET x) : fd(x)
	{
        //FIX ME by linzihan
		//unsigned long n = 1;
		//ioctlsocket(fd, FIONBIO , &n);
        NetSys::SetNonBlockMode(fd,atrue);
		ionew[fd] = this;
        i_maxSocket = a_Max(x, i_maxSocket);
        
        ASSERT(m_pLocker_ionew);
        ASSERT(m_pLocker_poll);
	}

public:	
	static void Init();
	static void Close();
    static void ReConnectPollControl();
	static void ShutDown();
    static void StopNetworkThreadTask();
    static void ContinueNetworkThreadTask();

	static void Poll(int timeout)
	{
//      FIX ME by linzihan
//		Thread::Mutex::Scoped l(locker_poll);
//		{
//			Thread::Mutex::Scoped l(locker_ionew);
//			
//			for(IOMap::const_iterator i = ionew.begin(); i != ionew.end(); ++i)
//				iomap[(*i).first] = (*i).second;
//			ionew.clear();
//
//		}
        
 		ACSWrapper l(m_pLocker_poll);
		{
			ACSWrapper l(m_pLocker_ionew);
			
			for(IOMap::const_iterator i = ionew.begin(); i != ionew.end(); ++i)
				iomap[(*i).first] = (*i).second;
			ionew.clear();
            
		}
        
        
		fdset.clear();
		wakeup_flag  = false;
		for(std::map<SOCKET, PollIO*>::iterator it=iomap.begin(); it!=iomap.end(); ++it)
			UpdateEvent(*it);
		wakeup_scope = true;
		if (wakeup_flag)
		{
			wakeup_scope = false;
			wakeup_flag  = false;
			timeout = 0;
		}
		int nevents;		
		if (timeout < 0)
		{
			nevents = NetSys::Select(i_maxSocket+1, &rfds, &wfds, &efds, NULL);
		}
		else
		{
			struct timeval tv;
			tv.tv_sec = timeout / 1000;
			tv.tv_usec = (timeout - (tv.tv_sec * 1000)) * 1000;
			nevents = NetSys::Select(i_maxSocket+1, &rfds, &wfds, &efds, &tv);
		}
		wakeup_scope = false;
		if (nevents > 0)
			std::for_each(fdset.begin(), fdset.end(), std::ptr_fun(&TriggerEvent));
		FD_ZERO(&rfds); 
		FD_ZERO(&wfds);
		FD_ZERO(&efds);
	}
// FIX ME by linzihan
//	class Task : public Thread::Runnable
//	{
//		Task() { }
//		void Run()
//		{
//			PollIO::Poll(1000);
//			Timer::Update();
//			if(!Thread::Pool::AddTask(this))
//			{
//				PollIO::ShutDown();
//			}
//		}
//	public:
//		static Task *GetInstance();
//	};
    class Task : public AThreadTask
    {
    	Task():AThreadTask(1){ };
        
        virtual void DoTask()
        {
            PollIO::Poll(1000);
            Timer::Update();
            if(!g_pThreadPool->AddTask(this))
            {
                PollIO::ShutDown();
            }
        }
        //	Destroy task object. This function isn't ensured to be called in main thread.
        virtual void Destroy()
        {
        }
        
//FIX ME by linzihan
//    	void Run()
//    	{
//    		PollIO::Poll(1000);
//    		Timer::Update();
//    		if(!Thread::Pool::AddTask(this))
//    		{
//    			PollIO::ShutDown();
//    		}
//    	}
    public:
    	static Task *GetInstance();
    };
    
	static void WakeUp();
    //FIX ME by linzihan
	//static Thread::Mutex& LockerNew() { return locker_ionew; }
    static ASysThreadMutex* LockerNew() { return m_pLocker_ionew; }
};

class PollControl : public PollIO
{
	friend class PollIO;
	static SOCKET writer;
    static PollControl* m_PollControl;
    bool   m_bCloseing;


	int UpdateEvent() { return m_bCloseing ? -1 : POLL_STATE_IN; }
	void PollIn()  
	{ 
		for(char buff[256]; NetSys::Recv(fd, buff, 256, 0)==256; );
	}
	PollControl(int r ) : PollIO(r)
    {
        writer = r;
        m_bCloseing = false;
    }
    void Close()
    {
        m_bCloseing = true;
    }

	~PollControl()
	{
        NetSys::CloseSocket(fd);
	}

	static void WakeUp() {
		NetSys::Send(writer, (""), 1, 0); 
	}

	static void Init()
	{
		//unsigned long n = 1;
        
        char szAddr[128]={0};
        bool isIp6 = getNetAddr("127.0.0.1",0,szAddr);
        SOCKET s = NULL;
        
        if(isIp6)
        {
            s = socket(AF_INET6,SOCK_DGRAM,0);
            
            struct sockaddr_in6 sin;
            memset(&sin,0,sizeof(sin));
            sin.sin6_family = AF_INET6;
            sin.sin6_len = sizeof(sockaddr_in6);
            
            inet_pton(AF_INET6, "127.0.0.1", (void*)&sin.sin6_addr);
            sin.sin6_port = NetSys::Htons(0);
            
            NetSys::Bind(s,(const sockaddr*)&sin,sizeof(sin));

            struct sockaddr addr;
            memset(&addr,0,sizeof(addr));
            auint32 len = sizeof(struct sockaddr);
            NetSys::Getsockname(s,&addr, &len);
            
            NetSys::Connect(s, &addr, len);
        }
        else
        {
            s = NetSys::Socket(AF_INET,SOCK_DGRAM,0);
            
            struct sockaddr_in sin;
            memset(&sin,0,sizeof(sin));
            sin.sin_family = AF_INET;
            sin.sin_addr.s_addr = NetSys::Inet_addr(("127.0.0.1"));
            sin.sin_port = NetSys::Htons(0);
            sin.sin_len = sizeof(sockaddr_in);
            
            NetSys::Bind(s,(const sockaddr*)&sin,sizeof(sin));
            
            struct sockaddr addr;
            memset(&addr,0,sizeof(addr));
            auint32 len = sizeof(struct sockaddr);
            NetSys::Getsockname(s,&addr, &len);
            
            NetSys::Connect(s, &addr, len);
        }
        
        //FIXME
		//ioctlsocket(s, FIONBIO , &n);
        NetSys::SetNonBlockMode(s,atrue);
		m_PollControl = new PollControl(s);
	}
    
    static void Release()
    {
        //A_SAFEDELETE(m_PollControl);
    }
    
    static void ReConnect()
    {
        if(m_PollControl)
            m_PollControl->Close();
        PollControl::Init();
    }
};

inline void PollIO::WakeUp() 
{ 
	if (wakeup_scope)
		PollControl::WakeUp(); 
	else
		wakeup_flag = true;
}
    
    

};

#endif
