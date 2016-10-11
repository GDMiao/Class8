#ifndef SOURAUDIO_H
#define SOURAUDIO_H
#include "SourData.h"
#include <string>
using namespace std;

class CSourAudio: public ISourData
{
public:
	CSourAudio(string name);
	virtual ~CSourAudio();
public:
	virtual bool GetBuffer(unsigned char** pBuf,unsigned int& nBufSize);
	virtual bool SetSourType(int nSourType);
	virtual bool SourOpen(void* param);
	virtual bool SourClose();
    
    // Video Enhancements
    virtual bool AVE_SetID(int nMainValue, int nSubValue, int nParams[2]);
    virtual void ShowImage(unsigned char* pBuf,unsigned int nBufSize,int nVW,int nVH);
    
public:
    long GetDevMicCount();
    bool GetDevMicName(long nIndex,char szName[256]);
    bool GetActiveing();
	
};

#endif

