#include "SourCamera.h"


CSourCamera::CSourCamera(int nVideoWidth,int nVideoHeight,int fps,string sname):ISourData(SOURCECAMERA,sname)
{
    
}

CSourCamera::~CSourCamera()
{
    
}


bool CSourCamera::GetBuffer(unsigned char** pBuf,unsigned int& nBufSize)
{
    return false;
}

void CSourCamera::GetVideoWandH(int& nW,int& nH)
{

}

long CSourCamera::GetVideoFps()
{
    return 0;
}

bool CSourCamera::SetSourType(int nSourType)
{
    return false;
}

bool CSourCamera::SourClose()
{
    return false;
}

bool CSourCamera::SourOpen(void* param)
{
    return false;
}


// Video Enhancements
bool CSourCamera::AVE_SetID(int nMainValue, int nSubValue, int nParams[2])
{
    return false;
}

void CSourCamera::ShowImage(unsigned char* pBuf,unsigned int nBufSize,int nVW,int nVH)
{
    
}

long CSourCamera::GetDevCameraCount()
{
    return 0;
}

bool CSourCamera::GetDevCameraName(long nIndex,char szName[260])
{
    return false;
}