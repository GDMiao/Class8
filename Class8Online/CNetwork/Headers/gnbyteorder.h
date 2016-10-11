#ifndef __BYTEORDER_H
#define __BYTEORDER_H

namespace GNET
{


#if defined BYTE_ORDER_BIG_ENDIAN
	#define byteorder_16(x)	(x)
	#define byteorder_32(x)	(x)
	#define byteorder_64(x)	(x)
#elif defined __GNUC__
	#include "ASys.h"
    #include "NetSys.h"
	inline auint16 byteorder_16(auint16 x)
	{
        return NetSys::Htons(x);
		
	}
	inline auint32 byteorder_32(auint32 x)
	{
        return NetSys::Htonl(x);
	}
	inline auint64 byteorder_64(auint64 x)
	{
		union
		{
			auint64 __ll;
			auint32 __l[2];
		} i, o;
		i.__ll = x;
		o.__l[0] = byteorder_32(i.__l[1]);
		o.__l[1] = byteorder_32(i.__l[0]);
		return o.__ll;
	}
#elif defined WIN32
	inline unsigned short byteorder_16(unsigned short x)
	{
		__asm ror x, 8
		return x;
	}
	inline unsigned int byteorder_32(unsigned int x)
	{
		__asm mov eax, x
		__asm bswap eax
		__asm mov x, eax
		return x;
	}
	inline unsigned __int64 byteorder_64(unsigned __int64 x)
	{
		union
		{
			unsigned __int64 __ll;
			unsigned int __l[2];
		} i, o;
		i.__ll = x;
		o.__l[0] = byteorder_32(i.__l[1]);
		o.__l[1] = byteorder_32(i.__l[0]);
		return o.__ll;
	}
#endif

};

#endif
