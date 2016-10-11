//-------------------------------------------------------------------------------------------------
//FileName:ASysThreadCommon.h
//Created by miaoyu 2013,2,28
//-------------------------------------------------------------------------------------------------
#ifndef _A_SYSTHREADCOMMON_H_
#define _A_SYSTHREADCOMMON_H_

#include "ATypes.h"
#include "AMemBase.h"

class AThreadData : public AMemBase
{
public:
	enum eThreadNotify
	{
		T_NOTIFY_TERMINATED = 0,
		T_NOTIFY_WORKFINISHED,
		T_NOTIFY_SUSPENDED,
		T_NOTIFY_RESUMED,
	};

	virtual void Notify(eThreadNotify notify) {}
};

typedef aint32 (*A_LPFNATHREADPROC)(aint32 iEventIdx, AThreadData* pUserData);

enum AThreadPriority
{
	APRI_NORMAL,
	APRI_ABOVENORMAL,
	APRI_BELOWNORMAL,
};

//-------------------------------------------------------------------------------------------------
//	ASysThreadAtomic
//-------------------------------------------------------------------------------------------------

class ASysThreadAtomic : public AMemBase
{
public:
	virtual ~ASysThreadAtomic() {}

public:
	  virtual void Release() = 0;
	  virtual aint32 GetValue() const = 0;

	  virtual aint32 Fetch_Add(aint32 iAmount) = 0;
	  virtual aint32 Fetch_Set(aint32 iAmount) = 0;
	  virtual aint32 Fetch_CompareSet(aint32 iAmount, aint32 iComparand) = 0;

	  virtual aint32 Increment_Fetch() = 0;
	  virtual aint32 Decrement_Fetch() = 0;
};

//-------------------------------------------------------------------------------------------------
//	ASysThreadMutex
//-------------------------------------------------------------------------------------------------

class ASysThreadMutex : public AMemBase
{
public:
	virtual ~ASysThreadMutex() {}

public:
	virtual void Release() = 0;
	virtual void Lock() = 0;
	virtual void Unlock() = 0;

};

//-------------------------------------------------------------------------------------------------
//ASysThreadEvent 
//FIXME!! Created by liyi
//下面函数目前禁用
class IASysSync : public AMemBase
{
public:
	virtual			~IASysSync(){}
};

#define A_INFINITE 0xFFFFFFFF
class IASysThreadEvent : public IASysSync
{
public:
	virtual			~IASysThreadEvent() {};

	virtual	abool	Create(abool bManualReset = afalse, const achar* szName = NULL) = 0;
	virtual void	Trigger() = 0;
	virtual void	Reset() = 0;
	virtual abool	Wait(auint32 nWaitTime = A_INFINITE) = 0;
};

class IASysSyncFactory
{
public:
	virtual IASysThreadEvent*	CreateEvent(abool bManualReset = afalse, const achar* szName = NULL) = 0;

	virtual void				Destroy(IASysSync* pSync) = 0;
};

extern IASysSyncFactory* g_pASysSyncFactory;

#endif