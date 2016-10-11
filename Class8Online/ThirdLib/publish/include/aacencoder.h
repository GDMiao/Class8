#pragma once

#include "faac.h"

class CAACEncoder
{
public:
	CAACEncoder();
	~CAACEncoder();
	bool aac_EncodeInit(int nChannel,int nBitRate,int nAudioSamplerate,unsigned long &nAACInputSamplesSize);
	bool aac_EncodeUnInit();
	bool aac_copyHeaderParam(unsigned char* pBuf,int &nSize,bool bKaraoke);
	bool aac_Encode(unsigned char** pDestBuf,unsigned int& nDestBufSize,unsigned char* pSrcBuf,unsigned int pSrcBufSize);
	inline bool aac_GetStatus() {return m_bIsInit;}
private:
	faacEncHandle  m_hAACEncoder;
	unsigned long m_nAACInputSamples;
	unsigned long m_nAACMaxOutputBytes;
	unsigned char* m_pbPCMBuffer;
	unsigned char* m_pbAACBuffer;
	int   m_nChannel;
	int   m_nBitRate;
	int   nAudioSmpRateEn;
	bool  m_bIsInit;
};