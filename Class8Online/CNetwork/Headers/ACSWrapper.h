﻿/*
 * FILE: ACSWrapper.h
 *
 * DESCRIPTION: Critical section wrapper
 *
 * CREATED BY: Hedi, 2005/5/23
 *
 * HISTORY:
 *
 * Copyright (c) 2001 Archosaur Studio, All Rights Reserved.	
 */

#ifndef _ACSWRAPPER_H_
#define _ACSWRAPPER_H_

#include "ATypes.h"
#include "ASys.h"
#include "ASysThreadCommon.h"
#include "AMemBase.h"

class ACSWrapper : public AMemBase
{
public:
	
	ACSWrapper(ASysThreadMutex* mutex)
	{
		ASSERT(mutex);
		m_pMutex = mutex;
		m_pMutex->Lock();
		m_iRefCnt = 1;
	}

	~ACSWrapper()
	{
		ACSWrapper::Detach();
	}

	void EnterCriticalSection()
	{
		ASSERT(m_pMutex && m_iRefCnt >= 0);
		m_pMutex->Lock();
		m_iRefCnt++;
	}

	void LeaveCriticalSection()
	{ 
		ASSERT(m_pMutex && m_iRefCnt > 0);
		m_iRefCnt--;
		m_pMutex->Unlock();
	}	

	void Attach(ASysThreadMutex* mutex)
	{
		//	Ensure not attach two cs at same time
		ASSERT(!m_pMutex && mutex && !m_iRefCnt);
		m_pMutex = mutex;
		m_pMutex->Lock();
		m_iRefCnt = 1;
	}

	void Detach()
	{
		if (m_pMutex)
		{
			ASSERT(m_iRefCnt == 1 || m_iRefCnt == 0);
			if (m_iRefCnt == 1)
				m_pMutex->Unlock();
		}

		m_pMutex = NULL;
		m_iRefCnt = 0;
	}

protected:

	ASysThreadMutex*	m_pMutex;
	aint32				m_iRefCnt;
};


#endif	//	_ACSWRAPPER_H_

