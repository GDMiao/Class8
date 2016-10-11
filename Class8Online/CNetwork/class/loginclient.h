//
//  loginclient.h
//  Client
//
//  Created by Andy on 14-7-31.
//  Copyright (c) 2014年 Perfect World (Beijing) Software Co.,Ltd. All rights reserved.
//

#ifndef __GNET__LOGINCLIENT
#define __GNET__LOGINCLIENT

#include "gnet.h"
#include "gnconf.h"
#include "AList2.h"
#include "AString.h"
#include "gnsecure.h"



namespace GNET
{
	class LoginClient: public Protocol::Manager, public Timer::Observer
	{
    private:
		static LoginClient instance;
        
		ASysThreadMutex* m_pLocker;
        Session::ID m_sid;
        int m_state;
        std::string hostaddr;
      
        //login info
        AString m_strUserName;
        AString m_strPassword;
        Octets  m_key;
        
        /**
         * 拓展
         * ip
         * port
         **/
        AString tcp_ip; //服务器ip
        int tcp_port;   //端口
        
        int     m_userid;
        bool    m_isLogin;
        bool    isKeepAlive;
	public:
        typedef int(* callback_t)(unsigned int sessionId, GNET::EVENT_VALUE event, GNET::Protocol* pData);
        enum STATE
		{
			STATE_CLOSED,
			STATE_CONNECTING,
			STATE_KEEPING,
		};
        
		
		LoginClient() : m_callback(NULL), m_state(STATE_CLOSED)
		{
            Timer::Attach(this);
			m_pLocker = AThreadFactory::CreateThreadMutex();
		}
        
		~LoginClient()
		{
			A_SAFEDELETE(m_pLocker);
		}
        
		static LoginClient& GetInstance()
		{
			return instance;
		}
        
        void SetLoginInfo(const char* name, const char* password)
        {
            m_strUserName = name;
            m_strPassword = password;
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
//            isKeepAlive = false;
            isKeepAlive  = isKeep;
        }
        void SetLoginNamePwd(AString strname, AString strpwd)
        {
            m_strUserName = strname;
            m_strPassword = strpwd;
        }
        
		bool InputPolicy(Protocol::Type type, size_t len) const { return true; }
		const Session::State *GetInitState() const { return &state_GLoginClient;}
		std::string Identification() const { static std::string str = ("LoginClient"); return str;}
    
		void Attach(callback_t funptr) { m_callback = funptr; }
		void Detach() { m_callback = NULL; }
        
		void OnAddSession(Session::ID sid);
		void OnDelSession(Session::ID sid);
		void OnAbortSession(Session::ID sid);
        
        Session::ID GetSessionID(){ return m_sid;}
        int  GetUserID(){return m_userid;}
        AString GetUserName(){return m_strUserName;}
    
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




#endif
