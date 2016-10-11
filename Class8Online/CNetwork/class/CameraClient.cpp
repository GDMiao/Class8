//
//  CameraClient.cpp
//  Class8Online
//
//  Created by chuliangliang on 16/1/26.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#include "CameraClient.h"
#include "AMemory.h"
#include "gnnetio.h"
#include "gnproto.h"

namespace GNET
{
    CameraClient CameraClient::instance;
    
//    Octets& MakePassword(Octets& username, Octets& password, Octets& key)
//    {
//        MD5Hash md5;
//        md5.Update(username);
//        md5.Update(password);
//        return md5.Final(key);
//    }
    
//    void GenerateKeyByPassword(Octets& identity, Octets& key, Octets& nonce, Octets& newkey)
//    {
//        HMAC_MD5Hash::HMAC_MD5Hash    hash;
//        hash.SetParameter(key);
//        hash.Update(identity);
//        hash.Update(nonce);
//        hash.Final(newkey);
//    }
    
#define SIZE_CHALLENGE 16
//    static Octets& RandomUpdate(Octets &o)
//    {
//        srand( (unsigned int)time( NULL));
//        for(unsigned int i=0;i<o.size();i++)
//        {
//            ((unsigned char*)o.begin())[i] = rand() & 255;
//        }
//        return o;
//    }
    
    
    void CameraClient::OnRecvProtocol(Session::ID sid, Protocol* pData)
    {
        //固定协议
        abool isSuccess = afalse;
        if(m_callback)
        {
            m_callback((unsigned int)m_sid, EVENT_LOAD_SUCCESS,pData);
        }
        
    }
    
    
    void CameraClient::Disconnect()
    {
        Close(m_sid);
        m_sid = -1;
        m_state = STATE_CLOSED;
    }
    
    void CameraClient::Update()
    {
        static int nCount = 0;
        
        //此timer 1秒钟回调来一次，间隔nCount秒发一次keepalive
        if(isKeepAlive && m_state != STATE_CLOSED)
        {
            nCount ++;
            if(nCount >= 60)
            {
                printf("CameraClient 保持连接\n");
                nCount= 0;
                KeepAlive keepalive;
                keepalive.code = (int)time(NULL);
                Send(m_sid, keepalive);
            }
        }
        else if( nCount != 0)
        {
            nCount = 0;
        }
    }
    
    
    int CameraClient::ConnectToServer()
    {
        AString strDefalutIP = tcp_ip;
        int iPort = tcp_port;
        
        return  Connect((const char*)strDefalutIP, iPort);
    }
    
    int CameraClient::Connect(const char* host, unsigned short port)
    {
        ACSWrapper l(m_pLocker);
        if(m_state!=STATE_CLOSED)
            Disconnect();
        m_state = STATE_CONNECTING;
        m_sid = -1;
        
        ConnectTo(host, port);
        ASys::OutputDebug("CameraClient::Connect");
        return m_sid;
    }
    
    
    void CameraClient::OnAddSession(Session::ID sid)
    {
        m_sid = sid;
        
        Session *session = GetSession(m_sid);
        if (session)
        {
            session->ResizeBuffer(1024 * 256);
        }
        
        ACSWrapper l(m_pLocker);
        m_state = STATE_KEEPING;
        
        if(m_callback&&m_sid!= -1)
            m_callback((unsigned int)m_sid, EVENT_ADDSESSION,NULL);
        
        ASys::OutputDebug("CameraClient::OnAddSession");
        
        
    }
    
    void CameraClient::OnDelSession(Session::ID sid)
    {
        ACSWrapper l(m_pLocker);
        m_state = STATE_CLOSED;
        if(m_callback && m_sid==sid)
        {
            m_callback(sid, EVENT_DISCONNECT, NULL);
        }
    }
    
    void CameraClient::OnAbortSession(Session::ID sid)
    {
        ACSWrapper l(m_pLocker);
        m_state = STATE_CLOSED;
        if(m_callback && m_sid==sid)
            m_callback(sid, EVENT_ABORTSESSION, NULL);
    }
    
    int CameraClient::ConnectTo(struct in_addr *host, unsigned short port)
    {
        //char szAddr[64]={0};
        //inet_ntop(AF_INET,(const void*)(struct in_addr *)(host),szAddr,sizeof(szAddr));
        //m_sid = Protocol::Client(this, szAddr, port);
        
        std::string hostaddr = inet_ntoa(*(struct in_addr *)(host));
        m_sid = Protocol::Client(this, hostaddr.c_str(), port);
        
        return m_sid;
    }
    int CameraClient::ConnectTo(const char* hostname, unsigned short port)
    {
        if(!hostname)
        {
            m_sid = Protocol::Client(this);
            return m_sid;
        }
        unsigned long   rst;
        int ret = NetSys::GetNetError();
        rst = NetSys::Inet_addr(hostname);
        if(rst == INADDR_NONE)
        {
            struct hostent * addr = NetSys::Gethostbyname(hostname);
            if(!addr)
            {
                m_sid = -1;
                hostaddr.clear();
                return m_sid;
            }
            
            char ** p;
            int n = 0;
            for(p=addr->h_addr_list;*p!=NULL;p++)
                n++;
            
            if(n<=0)
                return 0;
            n = rand() % n;
            hostaddr = NetSys::Inet_ntoa(*(struct in_addr *)(addr->h_addr_list[n]));
        }
        else
            hostaddr = hostname;
        
        ret = NetSys::GetNetError();
        
        m_sid = Protocol::Client(this, hostaddr.c_str(), port);
        return m_sid;
    }
    
}
