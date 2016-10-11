#include "SourAudio.h"


CSourAudio::CSourAudio(string sname):ISourData(SOURCEDEVAUDIO,sname)
{
    
}

CSourAudio::~CSourAudio()
{
    
}

bool CSourAudio::GetBuffer(unsigned char** pBuf,unsigned int& nBufSize)
{
    return false;
}

bool CSourAudio::SetSourType(int nSourType)
{
    return false;
}

bool CSourAudio::SourOpen(void* param)
{
    return false;
}

bool CSourAudio::SourClose()
{
    return false;
}

// Video Enhancements
bool CSourAudio::AVE_SetID(int nMainValue, int nSubValue, int nParams[2])
{
    return false;
}

void CSourAudio::ShowImage(unsigned char* pBuf,unsigned int nBufSize,int nVW,int nVH)
{
    
}

long CSourAudio::GetDevMicCount()
{
    return 0;
}

bool CSourAudio::GetDevMicName(long nIndex,char szName[256])
{
    return false;
}

bool CSourAudio::GetActiveing()
{
    return false;
}