#ifndef __NETSYS_H
#define __NETSYS_H
#include "ATypes.h"
#include "AString.h"


#include "ASys.h"
#include "ACSWrapper.h"
#include "AThreadPool.h"
#include "AThreadFactory.h"


#if defined(A_PLATFORM_XOS)
#include "iosNetSys.h"
#elif defined(A_PLATFORM_WIN_DESKTOP)
#include "WinNetSys.h"
#elif defined(A_PLATFORM_ANDROID)
#include "androidNetSys.h"
#endif


class NetSys
{
    
	NetSys();
	~NetSys();
public:
	static aint32 Socket_open(void);
	static aint32 Socket_close(void);
	static aint32	Accept(SOCKET s, struct sockaddr* pAdr, auint32 * slen);
    static aint32	Bind(SOCKET s, const struct sockaddr* pAdr, auint32  slen);
    static aint32	Connect(SOCKET s, const struct sockaddr* pAdr, auint32  slen);
    static aint32	Getpeername(SOCKET s, struct sockaddr * pAdr, auint32 * slen);
    static aint32	Getsockname(SOCKET s, struct sockaddr * pAdr, auint32 * slen);
    static aint32	Getsockopt(SOCKET s, int level, int optname, void* optval, auint32 * slen);
    static aint32	Listen(SOCKET s, int backlog);
    static aint32	Recv(SOCKET s, void* buf, size_t len, aint32 flags);
    static aint32	Recvfrom(SOCKET s, void* buf, size_t len, aint32 flags, struct sockaddr* pAdr,auint32 * slen);
    static aint32	Send(SOCKET s, const void* buf, size_t len, aint32 flags);
    static aint32	Sendto(SOCKET s, const void* buf, size_t len,aint32 flags, const struct sockaddr* pAdr, auint32 slen);
    static aint32	Setsockopt(SOCKET s, aint32 level, aint32 optname, const void* optval, auint32 slen);
    static aint32	Shutdown(SOCKET s, aint32 how);
    static aint32	Socket(aint32 af, aint32 type, aint32 protocol);
    static aint32   Select( int nfds, fd_set* readfds,fd_set* writefds,fd_set* exceptfds, struct timeval* timeout);
    static hostent* Gethostbyname(const char* name);
    
    static aint32   Htonl(auint32 hostlong);
    static auint16  Htons(auint16 hostshort);
    static auint32  Inet_addr( const achar* cp);
    static char*    Inet_ntoa( in_addr in);
    
    static aint32   GetNetError();
	static void		GetNetErrorString( aint32 errid,AString& errstr);	
    static void     CloseSocket(SOCKET s);
    static void     SetNonBlockMode(SOCKET s, abool bBlock);
    static abool    GetMacAddress(char pMac[6]);
    
};


#endif