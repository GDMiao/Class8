//
//  CameraClient.hpp
//  Class8Online
//
//  Created by chuliangliang on 16/1/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//


/**
 * 此类用来维护小助手TCP 连接使用 for 2016/1/26 之后版本
 **/
#ifndef __GNET__CameraClient
#define __GNET__CameraClient


#include "gnet.h"
#include "gnconf.h"
#include "AList2.h"
#include "AString.h"
#include "gnsecure.h"

namespace GNET
{
    class CameraClient: public Protocol::Manager, public Timer::Observer
    {
    private:
        static CameraClient instance;
        
        ASysThreadMutex* m_pLocker;
        Session::ID m_sid;
        int m_state;
        std::string hostaddr;
        
        
        AString tcp_ip; //服务器ip
        int tcp_port;   //端口
        
        bool    isKeepAlive;
    public:
        typedef int(* callback_t)(unsigned int sessionId, GNET::EVENT_VALUE event, GNET::Protocol* pData);
        enum STATE
        {
            STATE_CLOSED,
            STATE_CONNECTING,
            STATE_KEEPING,
        };
        
        
        CameraClient() : m_callback(NULL), m_state(STATE_CLOSED)
        {
            Timer::Attach(this);
            m_pLocker = AThreadFactory::CreateThreadMutex();
        }
        
        ~CameraClient()
        {
            A_SAFEDELETE(m_pLocker);
        }
        
        static CameraClient& GetInstance()
        {
            return instance;
        }
        
        void setTcpIPAndPort(const char *ipString, int portNum)
        {
            tcp_ip = ipString;
            tcp_port = portNum;
        }
        /*拓展获取当前连接的ip*/
        const char *getTcpIp ()
        {
            return tcp_ip;
        }
        /*获取当前连接的端口*/
        int getTcpPort ()
        {
            return tcp_port;
        }
        void setKeelOnline(bool isKeep) {
            isKeepAlive  = isKeep;
        }
        
        bool InputPolicy(Protocol::Type type, size_t len) const { return true; }
        const Session::State *GetInitState() const { return &state_GLoginClient;}
        std::string Identification() const { static std::string str = ("CameraClient"); return str;}
        
        void Attach(callback_t funptr) { m_callback = funptr; }
        void Detach() { m_callback = NULL; }
        
        void OnAddSession(Session::ID sid);
        void OnDelSession(Session::ID sid);
        void OnAbortSession(Session::ID sid);
        
        Session::ID GetSessionID(){ return m_sid;}
        
        int ConnectToServer();
        
        void Disconnect();
        void Update();
        
        void OnRecvProtocol(Session::ID sid, Protocol* pdata);
        
        
    protected:
        
        callback_t m_callback;
        int ConnectTo(struct in_addr *host, unsigned short port);
        int ConnectTo(const char* hostname, unsigned short port);
        int Connect(const char* host, unsigned short port);
    };
};



#endif /* CameraClient_hpp */
