#ifndef SOURDATAMANAGER_H
#define SOURDATAMANAGER_H
#include "SourHeader.h"
#include <list>
using namespace std;

class CSourDataManager
{
public:
	CSourDataManager();
	~CSourDataManager();
public:
	long GetDevCameraCount();
	bool GetDevCameraName(long nIndex,char szName[256]);
	long   GetDevMicCount();
    bool   GetDevMicName(int nMicID,char szName[256]);
	ISourData* getSourData(int nMediaType,int nIndex);

private:
	bool InitDevSourManager();
	bool UninitDevSourManager();
	void clearSour();
private:
	list<SourceNode>  m_listSour;
};

#endif