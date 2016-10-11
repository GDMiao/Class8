//
//  AXOSTypes.h
//  Angelica
//
//  Created by jianming lin on 2/23/13.
//
//

#ifndef _A_XOS_TYPES_H_
#define _A_XOS_TYPES_H_

#ifdef DEBUG
#define A_DEBUG
#endif


#include <stdlib.h>
#include <math.h>
#include <float.h>
#include <assert.h>
//#include <malloc.h> // for _alloca
#include <stdio.h>
#include <time.h>
#include <stdarg.h>
//#include <io.h>
#include <string.h>
#include <new>
#include <sys/stat.h>
#include <wchar.h>
#include <unistd.h>
#include <sys/time.h>
//-------------------------------------------------------
//	base types
//-------------------------------------------------------

#include <stdint.h>
#include <wchar.h>
#include <stdarg.h>
#include <assert.h>
#include <alloca.h>
#include <locale.h>
#include <wctype.h>
#include <iconv.h>


//-------------------------------------------------------
//	base types
//-------------------------------------------------------
#define ANGELICA_IOS
typedef uint8_t				auint8;
typedef uint16_t			auint16;
typedef uint32_t			auint32;
typedef uint64_t			auint64;

typedef	int8_t				aint8;
typedef int16_t				aint16;
typedef int32_t 			aint32;
typedef int64_t				aint64;

typedef float				afloat32;
typedef double				afloat64;

typedef char				achar;
typedef uint16_t			auchar;
typedef uint8_t				abyte;
typedef auint32				abool;

#define atrue				1
#define afalse				0

#ifdef A_PLATFORM_64
typedef aint64				aptrint;
typedef auint64				auptrint;
#else
typedef aint32				aptrint;
typedef auint32				auptrint;
#endif

//	File handle
typedef FILE*				AFILEHANDLE;

#define AMEM /*: public AMemBase*/ //empty define AMEN

#define A_FORCEINLINE	inline __attribute__((always_inline))
#define A_INLINE		inline
#define A_ALIGN(n)		__attribute__((aligned(n)))

#define Assert			assert

#ifdef A_PLATFORM_64
#define AAlloca16( x )	((void *)((((aint64)alloca( (x)+15 )) + 15) & ~15))
#else
#define AAlloca16( x )	((void *)((((aint32)alloca( (x)+15 )) + 15) & ~15))
#endif


#define A_DLL_EXPORT	__attribute__((visibility("default")))
#define A_DLL_IMPORT
#define A_DLL_LOCAL		__attribute__((visibility("hidden")))

#define A_STDCALL

#if defined(__arm__)   // || defined(__arm64__)
#define ARM_NEON
#endif

#endif	//	_A_XOS_TYPES_H_
