//-------------------------------------------------------------------------------------------------
//FileName: ASysThread.h
//Created by miaoyu 2013,2,28
//-------------------------------------------------------------------------------------------------
#ifndef _A_SYSTHREAD_H_
#define _A_SYSTHREAD_H_

#include "ASysThreadCommon.h"
#include "AMemBase.h"

class ASysThread : public AMemBase
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

	virtual ~ASysThread() {}

public:
	virtual void Release() = 0;
	virtual abool Create(A_LPFNATHREADPROC lpfnWorkProc, EVENT_DESC* aEvents, aint32 iNumEvent, AThreadData* pUserData, abool bMainThread=afalse) = 0;
	virtual aint32 RunMainThread() = 0;
	virtual void Terminate() = 0;
	virtual void Suspend() = 0;
	virtual void Resume() = 0;

	virtual abool IsRunning() = 0;
	virtual abool IsSuspended()  = 0;

	virtual abool SetPriority(AThreadPriority priority) = 0;
	virtual abool SetIdealProcessor(auint32 iProcessorIndex) = 0;

	virtual void TriggerEvent(aint32 iEventIdx) = 0;
	virtual void ResetEvent(aint32 iEventIdx) = 0;

};


#endif