//-------------------------------------------------------------------------------------------------
//FileName: ASysMainThread.h
//Created by miaoyu 2013,2,28
//-------------------------------------------------------------------------------------------------
#ifndef _A_SYSMAINTHREAD_H_
#define _A_SYSMAINTHREAD_H_

#include "ASysThreadCommon.h"
#include "AMemBase.h"

//-------------------------------------------------------------------------------------------------
//	ASysMainThread
//-------------------------------------------------------------------------------------------------

class ASysMainThread : public AMemBase
{
public:
	struct EVENT_DESC
	{
		abool bManualReset;
	};

	enum
	{
		MAX_USER_EVENT_NUM = 8,
	};

	virtual ~ASysMainThread() {}

public:
	virtual void Release() = 0;

	virtual abool Create(A_LPFNATHREADPROC lpfnWorkProc, EVENT_DESC* aEvents, aint32 iNumEvent, AThreadData* pUserData) = 0;
	virtual void Suspend() = 0;
	virtual void Resume() = 0;

	virtual abool IsSuspended() = 0;

	virtual abool SetPriority(AThreadPriority priority) = 0;
	virtual abool SetIdealProcessor(auint32 iProcessorIndex) = 0;

	virtual void TriggerEvent(aint32 iEventIdx) = 0;
	virtual void ResetEvent(aint32 iEventIdx) = 0;

	//  Run Once Per Update
	virtual aint32 RunOnce() = 0;
};


#endif