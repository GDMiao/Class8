#include "aacencoder.h"
#include "datautils.h"

CAACEncoder::CAACEncoder()
{
	m_hAACEncoder  = NULL;
	m_pbAACBuffer  = NULL;
	m_nAACInputSamples = 0;
	m_nAACMaxOutputBytes = 0;

#if (PW_OE_AUDIO_MODELS == AUDIO_PRO_LOW)
	m_nBitRate = 16000;
	nAudioSmpRateEn = 16000;	
	m_nChannel = 1;
#elif(PW_OE_AUDIO_MODELS == AUDIO_PRO_HIGH)
	m_nBitRate = 90000;
	nAudioSmpRateEn = 32000;
	m_nChannel = 2;
#else
	m_nBitRate = 64000;
	nAudioSmpRateEn = 32000;
	m_nChannel = 1;
#endif
	m_bIsInit = false;

}

CAACEncoder::~CAACEncoder()
{
	aac_EncodeUnInit();

}

bool CAACEncoder::aac_EncodeInit(int nChannel,int nBitRate,int nAudioSamplerate,unsigned long &nAACInputSamplesSize)
{
	m_nChannel = nChannel;
	m_nBitRate = nBitRate;
	nAudioSmpRateEn = nAudioSamplerate;
	m_hAACEncoder = faacEncOpen(nAudioSamplerate, nChannel, &m_nAACInputSamples, &m_nAACMaxOutputBytes);
	if(m_hAACEncoder)
	{
		faacEncConfigurationPtr pConfiguration = NULL;
		pConfiguration = faacEncGetCurrentConfiguration(m_hAACEncoder);
		pConfiguration->aacObjectType = LOW;
		pConfiguration->inputFormat = FAAC_INPUT_16BIT;
		pConfiguration->bitRate = nBitRate/nChannel;
		int nRet = faacEncSetConfiguration(m_hAACEncoder, pConfiguration);

		nAACInputSamplesSize = m_nAACInputSamples*16/8;
		m_pbAACBuffer = new unsigned char [m_nAACMaxOutputBytes];
		m_bIsInit = true;
		return true;
	}
	return false;
}

bool CAACEncoder::aac_copyHeaderParam(unsigned char* pBuf,int &nSize,bool bKaraoke)
{
	if(pBuf == NULL || !m_bIsInit)
		return false;

    char* szTmp = (char*)pBuf;
	//audio
	szTmp=put_amf_string( szTmp, "audiocodecid" );
	szTmp=put_amf_double( szTmp, 10.0);//AAC
	szTmp=put_amf_string( szTmp, "audiodatarate" );
	szTmp=put_amf_double( szTmp, 0.0);
	szTmp=put_amf_string( szTmp, "audiosamplerate" );
	szTmp=put_amf_double( szTmp, nAudioSmpRateEn); // 
	szTmp=put_amf_string( szTmp, "audiosamplesize" );
	szTmp=put_amf_double( szTmp, 16.0);
	szTmp=put_amf_string( szTmp, "stereo" );
	szTmp=put_amf_bool( szTmp, bKaraoke == true ? true : false);
	nSize = szTmp - (char*)pBuf;
	return true;
}



bool CAACEncoder::aac_Encode(unsigned char** pDestBuf,unsigned int& nDestBufSize,unsigned char* pSrcBuf,unsigned int pSrcBufSize)
{
	if(pDestBuf == NULL || pSrcBuf == NULL ||  pSrcBufSize <= 0 || !m_bIsInit)
	{
		return false;
	}
	int nLen = faacEncEncode(m_hAACEncoder, (int*) pSrcBuf, m_nAACInputSamples, m_pbAACBuffer, m_nAACMaxOutputBytes);
	*pDestBuf = m_pbAACBuffer;
	nDestBufSize = nLen;
    if(nDestBufSize > 13 )
        return true;
    return false;
}

bool CAACEncoder::aac_EncodeUnInit()
{
	m_bIsInit = false;

	if(m_hAACEncoder)
	{
		faacEncClose(m_hAACEncoder);
		m_hAACEncoder = NULL;
	}

	if(m_pbAACBuffer)
	{
		delete [] m_pbAACBuffer;
		m_pbAACBuffer = NULL;
	}
	return true;
}