#ifndef __IOSNETSYS_H
#define __IOSNETSYS_H
#define _EA(a)   a
#define _EW(a)   a

#ifdef UNICODE
	#define _ET _EW	
#else
	#define _ET _EA 
#endif


#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/tcp.h>
#include <netdb.h>

#define SOCKET aint32
#define A_INVALID_SOCKET -1 //or (~0)
#define A_SOCKET_ERROR  -1
#define A_OULDBLOCK   EWOULDBLOCK
//or #define A_EWOULDBLOCK EINPROGRESS



#endif