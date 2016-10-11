#ifndef SOURCAMERA_H
#define SOURCAMERA_H
#include "SourData.h"
#include <string>
using namespace std;

class CSourCamera:public ISourData
{
public:
    CSourCamera(int nVideoWidth,int nVideoHeight,int fps,string sname);
    virtual ~CSourCamera();
public:
    virtual bool GetBuffer(unsigned char** pBuf,unsigned int& nBufSize);
    virtual void GetVideoWandH(int& nW,int& nH);
    virtual long GetVideoFps();
    virtual bool SetSourType(int nSourType);
    virtual bool SourClose();
    virtual bool SourOpen(void* param);
    
    // Video Enhancements
    virtual bool AVE_SetID(int nMainValue, int nSubValue, int nParams[2]);
    virtual void ShowImage(unsigned char* pBuf,unsigned int nBufSize,int nVW,int nVH);
    
public:
    long GetDevCameraCount();
    bool GetDevCameraName(long nIndex,char szName[260]);
    
    
    
};
#endif
