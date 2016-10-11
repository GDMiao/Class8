/*
 * FILE: AMemory.h
 *
 * DESCRIPTION: Routines for memory allocating and freeing
 *
 * CREATED BY: duyuxin, 2003/6/4
 *
 * HISTORY:
 *
 * Copyright (c) 2001 Archosaur Studio, All Rights Reserved.
 */

#ifndef _AMEMORY_H_
#define _AMEMORY_H_

#include "ATypes.h"

#pragma once

///////////////////////////////////////////////////////////////////////////
//
//	Define and Macro
//
///////////////////////////////////////////////////////////////////////////

//	Enable below lines to forbid angelica's memory management and turn to
//	use standard memory operations
#ifndef _A_FORBID_MALLOC
//#define _A_FORBID_MALLOC
#endif

///////////////////////////////////////////////////////////////////////////
//
//	Types and Global variables
//
///////////////////////////////////////////////////////////////////////////

//	Memory general info
struct AMEMGENINFO
{
	aint32	iPeakSize;			//	Historic peak memory 
	aint32	iSmallSize;			//	Current allocated size of small memory
	aint32	iSmallRawSize;		//	Current allocated size of raw small memory
	aint32	iSmallPoolSize;		//	Current small memory pool size
	aint32	iLargeSize;			//	Current allocated size of large memory
	aint32	iLargeRawSize;		//	Current allocated size of raw large memory
	aint32	iLargeBlockCnt;		//	Current allocated large memory block counter

	aint32	iOversizeTempMem;	//	Counter of oversize temporary memory request
	aint32	iGlbAllocTempMem;	//	Counter of temporary memory request that turned to global malloc
	aint32	iMaxTempMemPool;	//	Maximum number of temporary memory pool
	aint32	iCurTempMemPool;	//	Current number of temporary memory pool
};

///////////////////////////////////////////////////////////////////////////
//
//	Declare of Global functions
//
///////////////////////////////////////////////////////////////////////////

void* a_malloc(size_t size);
void* a_realloc(void* pMem, size_t size);
void a_free(void *p);
void* a_malloctemp(size_t size);
void a_freetemp(void* p);
void* a_memcpy(void* pDest, const void* pSrc, size_t size);

#ifdef _DEBUG
	void _a_DumpMemoryBlocks(FILE* pFile, FILE* pAddiInfoFile);
	void _a_EnableMemoryHistoryLog(FILE * pMemHisFile);
#endif

//	Get memory info
void a_GetMemInfo(AMEMGENINFO& info);
//	Garbage collect
void a_MemGarbageCollect();

///////////////////////////////////////////////////////////////////////////
//
//	Inline functions
//
///////////////////////////////////////////////////////////////////////////

template <class T>
T* a_MallocArray(auint32 uCount)
{
	//	Allocate 4 more bytes for storing counter number
	void* p = a_malloc(sizeof (T) * uCount + sizeof (auint32));

	if (p)
	{
		//	Write count at header
		auint32* pCnt = (auint32*)p;
		*pCnt++ = uCount;
		p = (void*)pCnt;

		T* pCurItem = (T*)p;
		for (auint32 i=0; i < uCount; i++)
		{
			new ((void*)&*pCurItem++) T;
		}
	}

	return (T*)p;
}

template <class T>
void a_FreeArray(T* p)
{
	if (p)
	{
		//	Read count at header
		auint32* pCnt = (auint32*)p - 1;
		auint32 uCount = *pCnt;

		T* pCurItem = (T*)p;
		for (auint32 i=0; i < uCount; i++)
			pCurItem++->~T();

		p = (T*)pCnt;
	}

	a_free(p);
}

#endif	//	_AMEMORY_H_
