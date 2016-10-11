//-------------------------------------------------------------------------------------------------
//FileName: AThreadPool.h
//Created by miaoyu 2013,3,3
//-------------------------------------------------------------------------------------------------
#ifndef _A_THREADPOOL_H_
#define _A_THREADPOOL_H_

#include "ASys.h"
#include "ASysThreadCommon.h"
#include "ASysThread.h"
#include "AList2.h"
#include "AArray.h"
#include "AMemBase.h"

//-------------------------------------------------------------------------------------------------
//	AThreadTask
//-------------------------------------------------------------------------------------------------
enum
{
	A_THREAD_TERRAIN = ABit(1),
    A_THREAD_WORLD_OBJ = ABit(2),
	A_THREAD_MTL_MODEL = ABit(3), // For Client.
	A_THREAD_ALL_TASK = 0xFFFFFFFF
};

class AThreadTask : public AMemBase
{
public:

	AThreadTask(aint32 nMask, abool bAutoDestroy = atrue);

	virtual ~AThreadTask();

	//	Do task.
	virtual void DoTask() = 0;
	//	Destroy task object. This function isn't ensured to be called in main thread.
	virtual void Destroy() = 0;

	//	Get task mask
	aint32 GetMask() const { return m_nMask; }

		
	abool	IsAutoDestory() { return m_bAutoDestroy;}
	void	WaitForCompletion();

	//just for thread pool
	void	SetDone();

protected:

	aint32	m_nMask;	//	Task mask, should be non-zero value

	//IASysThreadEvent*	m_pEventDone;
	volatile abool		m_bAutoDestroy;
};


//-------------------------------------------------------------------------------------------------
//	AThreadPool
//-------------------------------------------------------------------------------------------------

class AThreadPool : public AMemBase
{
public:

	enum
	{
		MAX_TASKPRIORITY = 2,	//	Highest task priority
		NUM_TASKSEP = MAX_TASKPRIORITY + 1,		//	Number of task separator
	};

	friend aint32 _ThreadTaskProc(aint32 iEventIdx, AThreadData* pUserData);

	void Release();

public:

	//	Note: AddTask() method is thread safe and it can be called from multi-threads, but
	//		all other methods like Tick(), Pause(), Continue(), CancelAllTasks() are not
	//		thread-safe. So ensure they are called just from the thread in which this
	//		thread pool was created and will be released.

	//	Add task
	abool AddTask(AThreadTask* pTask, aint32 iPriority=0);
	//	Pause. This function only stop task processing, but not destroy task objects.
	//	This function return previous pause state before this function is called.
	abool Pause();
	//	Continue. This function continue task processing that was paused by Pause().
	//	This function return previous pause state before this function is called.
	abool Continue();
	//	Cancel all tasks in waiting list. Note: If a new task is added by AddTask() in another
	//	thread at the same time when CancelTasks() is called, the new added task's state is
	//	undefined !! It may be canceled too or it may not, if not, it will continue to go after
	//	CancelTasks() finished.
	void CancelTasks(aint32 nMask);

private:

	class TASK_THREAD : public AThreadData
	{
	public:

		//	If a polymorphic object doesn't has virtual destructor, some compiler
		//	gives a warnning when delete the object.
		virtual ~TASK_THREAD() {}

		AThreadPool*	pPool;
		ASysThread*		pThread;
		AThreadTask*	pTask;
	};

	aint32	m_iMaxThread;		//	Maximum thread number
	aint32	m_iThreadCnt;		//	Current thread counter
	aint32	m_iIdelProcessor;	//	Ideal processor index
	abool	m_bPaused;			//	Paused flag

	AList2<TASK_THREAD*>	m_IdleThreadList;	//	Idle thread list
	AList2<AThreadTask*>	m_TaskList;			//	Waiting tasks
	ASysThreadMutex*		m_pMutex;			//	Lock for m_TaskList
	ALISTPOSITION			m_aTaskSeps[NUM_TASKSEP];	//	Task separators positions

private:

	//	Create thread pool through AThreadSys
	friend class AThreadFactory;

	AThreadPool();
	virtual ~AThreadPool();
	//	Create thread pool.
	//	iThreadNum: maximum number of thread
	//	iProcessorIndex: ideal process index. -1 means use default value.
	abool Create(auint32 iThreadNum, aint32 iProcessorIndex);
	//	Create a thread
	TASK_THREAD* CreateThread();
	//	Task process function
	aint32 TaskProc(aint32 iEventIdx, TASK_THREAD* pTaskThread);
	//	Try to dispatch a task to idle thread
	//	Return true if task was dispatched.
	abool DispatchTask(AThreadTask* pTask);
};

//Just for IO
//1 thread
extern AThreadPool* g_pAIOThreadPool;

//for parallel jobs
extern AThreadPool* g_pAThreadPool;

#endif