
// ScreenRecoderDlg.cpp : 实现文件
//

#include "rtmppublish.h"
#include <sys/time.h>
#include "SourMedia.h"

SourMedia * g_Media = NULL;
extern CRTMPPublish* g_rtmpPublish;

void * CALLBACK _ProAudioThread(void* pUser)
{
    if(pUser)
    {
        CRTMPPublish* pu = (CRTMPPublish*)pUser;
        pu->AuidoThread();
    }
    return NULL;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
void ReadVideoCallBack(UInt8 * videoBuffer, size_t vWidth, size_t vHeight)
{
    if(g_rtmpPublish)
    {
         g_rtmpPublish->OnVideoTimer(videoBuffer,vWidth,vHeight);
    }
}

void ReadAudioCallBack(SInt16 * audioBuffer ,UInt32 len)
{
    if(g_rtmpPublish)
    {
        g_rtmpPublish->OnAudioTimer((unsigned char*)audioBuffer,len);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CRTMPPublish::CRTMPPublish( HWND hShowHwnd,int nFps,int nSampleRate)
{

	RTMPPacket_Reset(&m_packetVideo);
	m_packetVideo.m_body = NULL;
	RTMPPacket_Reset(&m_packetAudio);
	m_packetAudio.m_body = NULL;

	m_szPlayFileName[0] = '\0';

	m_pEventCallBack = NULL;
	m_EventpUser = NULL;	
	m_listPublish.clear();

	m_InitImpl = NULL;
	m_iStartTime.tv_sec  = 0;
    m_iStartTime.tv_usec = 0;
    
	m_audioPublish = NULL;
	m_bIsPreview = false;
	if(m_packetVideo.m_body == NULL)
	{
		RTMPPacket_Alloc(&m_packetVideo,DATA_SIZE);
	}
	if(m_packetAudio.m_body == NULL)
	{
		RTMPPacket_Alloc(&m_packetAudio,DATA_SIZE);
	}

	if(m_InitImpl == NULL)
	{
		m_InitImpl= RTMP_Alloc();  
		RTMP_Init(m_InitImpl);
	}
	m_nMicVolum = 0;
    m_nVideoW = 0;
    m_nVideoH = 0;
    m_hShowHwnd = hShowHwnd;
    m_nFps = nFps;
    m_nSampeleRate = nSampleRate;
    
    m_szAudioBuf = NULL;
    m_nAduioMaxSize = 1024 * 512;
    m_nDataSize = 0;
    m_nReadPos = 0;
    m_szAudioBuf = new unsigned char[m_nAduioMaxSize];
    
    m_audioThread.Begin(_ProAudioThread, this);
   
    if(g_Media == nil)
    {
        g_Media = [[SourMedia alloc]init];
        [g_Media initSourMedia: m_nFps sampleRate: m_nSampeleRate channel:1 handle :m_hShowHwnd];
        
        
        if(g_Media)
        {
            [g_Media MediaStart:^(UInt8 * videoBuffer, size_t vWidth, size_t vHeight){ReadVideoCallBack(videoBuffer,vWidth,vHeight);
                /*free(videoBuffer);videoBuffer = NULL;*/} audioCallback:^(SInt16 * audioBuffer ,UInt32 len){ReadAudioCallBack(audioBuffer,len);}];
        }
    }
    
	OnInit();
}

bool CRTMPPublish::InitMediaDevice(int nFps,int nSampleRate)
{
    if(m_nFps != nFps || m_nSampeleRate != nSampleRate)
    {
        m_nFps = nFps;
        m_nSampeleRate = nSampleRate;
        
        if(g_Media)
        {
            [g_Media MeidaEnd];
            g_Media = nil;
        }
        
        if(g_Media == nil)
        {
            g_Media = [[SourMedia alloc]init];
            [g_Media initSourMedia: nFps sampleRate:nSampleRate channel:1 handle :m_hShowHwnd];
        }
        
        if(g_Media)
        {
            [g_Media MediaStart:^(UInt8 * videoBuffer, size_t vWidth, size_t vHeight){ReadVideoCallBack(videoBuffer,vWidth,vHeight);
                /*free(videoBuffer);videoBuffer = NULL;*/} audioCallback:^(SInt16 * audioBuffer ,UInt32 len){ReadAudioCallBack(audioBuffer,len);}];
        }
    }
    return true;
}

void * CRTMPPublish::getMediaMediaCollection()
{
    if(g_Media)
    {
        return (__bridge void*)[g_Media getMediaCollection];
    }
    return NULL;
}

CRTMPPublish::~CRTMPPublish()
{
    if(g_Media)
    {
        [g_Media MeidaEnd];
        g_Media = NULL;
    }
    m_audioThread.End();
    
	OnUnInit();
	if(m_InitImpl)
	{
		RTMP_Free(m_InitImpl);
 		m_InitImpl = NULL;
	}

	list <CPublishUnit*>::iterator piter;
	m_vLock.Lock();
	for(piter = m_listPublish.begin();piter != m_listPublish.end();piter++)
	{
		CPublishUnit* pu = (*piter);
		if(pu)
		{
			m_aLock.Lock();
			if(pu == m_audioPublish)
			{
				m_audioPublish = NULL;
			}
			m_aLock.Unlock();
			pu->PublishEnd();
			delete pu;
			pu = NULL;
		}
	}
	m_listPublish.clear();
	m_vLock.Unlock();

	m_aLock.Lock();
	if(m_audioPublish)
	{
		delete m_audioPublish;
		m_audioPublish = NULL;
	}
	m_aLock.Unlock();



	if(m_packetVideo.m_body != NULL)
	{
		RTMPPacket_Free(&m_packetVideo);
		m_packetVideo.m_body = NULL;
	}
	if(m_packetAudio.m_body != NULL)
	{
		RTMPPacket_Free(&m_packetAudio);
		m_packetAudio.m_body = NULL;
	}
}


bool CRTMPPublish::OnInit()
{
	return TRUE;
}


void CRTMPPublish::OnUnInit()
{
    
}

long   CRTMPPublish::GetDevCameraCount()
{
	return m_sdManager.GetDevCameraCount();;
}


bool  CRTMPPublish::GetDevCameraName(long nIndex,char szName[256])
{
	return m_sdManager.GetDevCameraName(nIndex,szName);
}


long   CRTMPPublish::GetDevMicCount()
{
	return m_sdManager.GetDevMicCount();
}

bool CRTMPPublish::GetDevMicName(int nMicID,char szName[256])
{
	return m_sdManager.GetDevMicName(nMicID,szName);
}

CPublishUnit* CRTMPPublish::FindPU(const char* szURL)
{
	CPublishUnit* pu = NULL;
	if(m_listPublish.size() > 0)
	{
		list <CPublishUnit*>::iterator piter;
		for(piter = m_listPublish.begin();piter != m_listPublish.end();piter++)
		{
		    pu = (*piter);
			if(strcmp(pu->getPublishAddr(),szURL) == 0)
			{
				break;
			}
			pu = NULL;
		}
	}
	return pu;
}

CPublishUnit* CRTMPPublish::FindPUAndRemove(const char* szURL)
{
	CPublishUnit* pu = NULL;
	if(m_listPublish.size() > 0)
	{
		m_vLock.Lock();
		list <CPublishUnit*>::iterator piter;
		for(piter = m_listPublish.begin();piter != m_listPublish.end();piter++)
		{
		    pu = (*piter);
			if(strcmp(pu->getPublishAddr(),szURL) == 0)
			{
				m_listPublish.erase(piter);
				break;
			}
			pu = NULL;
		}
		m_vLock.Unlock();
	}
	return pu;
}

bool CRTMPPublish::PushStart(const char* szUrl,int nStreamType,StreamParam& param)
{
	bool bIsExist = true;
    param.arrDParam[param.DecoderParamML].nVideoW = m_nVideoW;
    param.arrDParam[param.DecoderParamML].nVideoH = m_nVideoH;
	CPublishUnit* pu = FindPU(szUrl);
	if(pu == NULL)
	{
		pu = new CPublishUnit(&m_sdManager);
		bIsExist = false;
	
	}

	if(!pu->PublishStart(szUrl,nStreamType,param))
	{
		delete pu;
		return false;
	}

	if(param.bIsPublish)
	{
		m_vLock.Lock();
		SendMediaHeader(pu,true);
		m_vLock.Unlock();
	}

	if(!bIsExist)
	{
		int nType = VIDEOTYPE;
		if(pu->bIsExistMediaType(nType))
		{
			m_vLock.Lock();
			m_listPublish.push_back(pu);
			m_vLock.Unlock();
		}
		nType = AUDIOTYPE;
		if(pu->bIsExistMediaType(nType))
		{
			m_aLock.Lock();
			m_audioPublish = pu;
			m_aLock.Unlock();
		}
	}


	return true;
}

bool CRTMPPublish::PushStartEx(const char* szVideoUrl,const char* szAudioUrl,int nStreamType,StreamParam& param)
{
    param.arrDParam[param.DecoderParamML].nVideoW = m_nVideoW;
    param.arrDParam[param.DecoderParamML].nVideoH = m_nVideoH;
	bool bIsVideoExist = true;
	bool bIsAudioExist = true;
	CPublishUnit* pvu = FindPU(szVideoUrl);
	CPublishUnit* pau = NULL;
	int nTempType = 0;
	if(pvu == NULL)
	{
		pvu = new CPublishUnit(&m_sdManager);
		bIsVideoExist = false;
	}

	nTempType = nStreamType & (SOURCECAMERA | SOURCESCREEN);
	if(!pvu->PublishStart(szVideoUrl,nTempType,param))
	{
		delete pvu;
		return false;
	}
	
	nTempType = nStreamType & (SOURCEDEVAUDIO | SOURCEDEMUSIC);
	if(strcmp(szAudioUrl,"") != 0)
	{
		if((nTempType & AUDIOTYPE) == AUDIOTYPE )
		{
			if(pau == NULL)
			{
				pau = new CPublishUnit(&m_sdManager);
				bIsAudioExist = false;
			}

			if(!pau->PublishStart(szAudioUrl,nTempType,param))
			{
				delete pvu;
				delete pau;
				return false;
			}

			m_aLock.Lock();
			m_audioPublish = pau;
			m_aLock.Unlock();
		}
	}
	else
	{
		if((nTempType & AUDIOTYPE) == AUDIOTYPE )
		{
			m_aLock.Lock();
			m_audioPublish = pvu;
			m_aLock.Unlock();
		}
	}

	m_vLock.Lock();
	if(param.bIsPublish)
	{
		SendMediaHeader(pvu,true);

		if(pau && pau != pvu)
		{
			SendMediaHeader(pau,true);
		}
	}

	if(!bIsVideoExist)
	{
		m_listPublish.push_back(pvu);
	}
	m_vLock.Unlock();
	return true;
}


bool CRTMPPublish::PushChangeEx(const char* szVideoUrl,const char* szAudioUrl,int nStreamType,StreamParam& param)
{

    param.arrDParam[param.DecoderParamML].nVideoW = m_nVideoW;
    param.arrDParam[param.DecoderParamML].nVideoH = m_nVideoH;
    
	CPublishUnit* pvu = FindPU(szVideoUrl);

	if(pvu)
	{
		m_vLock.Lock();
		int nTempType = nStreamType & (SOURCECAMERA | SOURCESCREEN);
		if(!pvu->PublishChanage(szVideoUrl,nTempType,param))
		{
			m_vLock.Unlock();
			return false;
		}
		else
		{
			SendMediaHeader(pvu);
		}
		m_vLock.Unlock();
	}

	bool bIsAudioChange = false;
	int nAudioType = nStreamType & (SOURCEDEVAUDIO | SOURCEDEMUSIC);
	if((nAudioType & AUDIOTYPE) == AUDIOTYPE)
	{
		if(m_audioPublish  == NULL)
		{
			m_aLock.Lock();
			int nTempType = nStreamType & (SOURCEDEVAUDIO | SOURCEDEMUSIC);
			m_audioPublish  = new CPublishUnit(&m_sdManager);
			if(!m_audioPublish->PublishStart(szAudioUrl,nTempType,param))
			{
				m_aLock.Unlock();
				return false;
			}
			SendMediaHeader(m_audioPublish,true);
			m_aLock.Unlock();
		}
		else
		{
			if(strcmp(m_audioPublish->getPublishAddr(),szAudioUrl) != 0)
			{
				return false;
			}
			else
			{
				m_aLock.Lock();
				int nType = AUDIOTYPE;
				int nTempType = nStreamType & (SOURCEDEVAUDIO | SOURCEDEMUSIC);
				if(!m_audioPublish->bIsExistMediaType(nType))
				{
					if(!m_audioPublish->PublishStart(szAudioUrl,nTempType,param))
					{
						m_aLock.Unlock();
						return false;
					}
				}
				else
				{
					
					if(!m_audioPublish->PublishChanage(szAudioUrl,nTempType,param))
					{
						m_aLock.Unlock();
						return false;
					}
					else
					{
						SendMediaHeader(m_audioPublish);
					}
				}
				m_aLock.Unlock();
			}
		}
	}
	else
	{
		m_aLock.Lock();
		if(m_audioPublish)
		{
			
			m_audioPublish->PublishEnd();
			m_audioPublish = NULL;
		}
		m_aLock.Unlock();
	}
	
	return false;
}

bool  CRTMPPublish::PushChangeML(const char* szRtmpPushUrl,int ml)
{
    CPublishUnit* pu = FindPU(szRtmpPushUrl);
    if(pu)
    {
        pu->PushChangeML(ml);
        return true;
    }
    return false;
}

bool   CRTMPPublish::moveImageShowRect(const char* szRtmpPushUrl,int nIndex,int nStreamType,ScRect showRect)
{
	CPublishUnit* pu = FindPU(szRtmpPushUrl);
	if(pu)
	{
		return pu->setShowRect(nIndex,nStreamType,showRect);
	}
	return false;
}

bool CRTMPPublish::PushChange(const char* szUrl,int nStreamType,StreamParam& param)
{
    param.arrDParam[param.DecoderParamML].nVideoW = m_nVideoW;
    param.arrDParam[param.DecoderParamML].nVideoH = m_nVideoH;
	CPublishUnit* pu = FindPU(szUrl);
	if(pu)
	{
		m_vLock.Lock();
		if(pu->PublishChanage(szUrl,nStreamType,param))
		{
			SendMediaHeader(pu);
			m_vLock.Unlock();
            
            bool bAudio = pu->bIsExistMediaType(AUDIOTYPE);
            m_aLock.Lock();
            m_audioPublish = bAudio ? pu : NULL;
            m_aLock.Unlock();
			return true;
		}
		m_vLock.Unlock();
	}

	m_aLock.Lock();
	if(m_audioPublish && strcmp(m_audioPublish->getPublishAddr(),szUrl) == 0)
	{
		if(m_audioPublish->PublishChanage(szUrl,nStreamType,param))
		{
			SendMediaHeader(m_audioPublish);
			m_aLock.Unlock();
			return true;
		}
	}
	m_aLock.Unlock();
	return false;
}


bool CRTMPPublish::PushEnd(const char* szUrl)
{
	CPublishUnit* pu = FindPUAndRemove(szUrl);
	bool bIsOK = false;
	if(pu)
	{

		if(m_audioPublish == pu)
		{
			m_aLock.Lock();
			m_audioPublish = NULL;
			m_aLock.Unlock();
		}
		bIsOK = pu->PublishEnd();
	}

	if(m_audioPublish && strcmp(m_audioPublish->getPublishAddr(),szUrl) == 0)
	{
		m_aLock.Lock();
		m_audioPublish->PublishEnd();
		m_audioPublish = NULL;
		m_aLock.Unlock();
	}
	return true;
}

void CRTMPPublish::SendMediaHeader(CPublishUnit *pu,bool bIsSend)
{
	if(pu)
	{
		pu->clearSendList();

		if(pu->getMediaMsgHeader(m_packetVideo,bIsSend))
		{
				RTMP_SendPacket_Ex(pu,&m_packetVideo,0,0);
		}
		if(pu->getVideoHeader(m_packetVideo,bIsSend))
		{
				RTMP_SendPacket_Ex(pu,&m_packetVideo,0,0);
		}
		if(pu->getAudioHeader(m_packetVideo,bIsSend))
		{
				RTMP_SendPacket_Ex(pu,&m_packetVideo,0,0);
		}
	}
}

bool   CRTMPPublish::TakePhotos(const char* szUrl)
{
	list <CPublishUnit*>::iterator piter;
	for(piter = m_listPublish.begin();piter != m_listPublish.end();piter++)
	{
		CPublishUnit *pu = (*piter);
		if(strcmp(pu->getPublishAddr(),szUrl) == 0)
		{
			if(m_pEventCallBack)
			{
				pu->SetEventCallback(m_pEventCallBack,m_EventpUser);
				pu->TakePhotos();
				return true;
			}
			break;
		}
	}
	return false;
}

void CRTMPPublish::OnVideoTimer(unsigned char* videoBuffer, int vWidth, int vHeight)
{
    m_nVideoW = vWidth;
    m_nVideoH = vHeight;
//    printf("%d  %d \n",m_nVideoW ,m_nVideoH);
	if(m_listPublish.size() > 0)
	{
		list <CPublishUnit*>::iterator piter;
		m_vLock.Lock();
		for(piter = m_listPublish.begin();piter != m_listPublish.end();piter++)
		{
			CPublishUnit *pu = (*piter);
            pu->PublishChanageEx(m_nVideoW, m_nVideoH);
			int nType = VIDEOTYPE;
			if(pu && pu->bIsExistMediaType(nType) && m_packetVideo.m_body)
			{

				if(pu->getVideoData(m_packetVideo,videoBuffer,vWidth,vHeight))
				{
                    if(!pu->getbIsSendSucessVideoHeader())
                    {
                        SendMediaHeader(pu);
                    }
                    if(pu->getbIsSendSucessVideoHeader())
                        RTMP_SendPacket_Ex(pu,&m_packetVideo,0,0);
				}
			}
		}
		m_vLock.Unlock();
	}
}

void CRTMPPublish::OnAudioTimer(unsigned char* audioBuffer ,int len)
{
    if(audioBuffer == NULL || len <= 0)
        return;
    m_AudioLock.Lock();
    int nBusySize = m_nDataSize - m_nReadPos > 0 ? m_nDataSize - m_nReadPos : 0;
    if(nBusySize + len > m_nAduioMaxSize)
    {
        m_nAduioMaxSize = (nBusySize + len)*2;
        unsigned char* pBuf = new unsigned char[m_nAduioMaxSize];
      
        memcpy(pBuf,m_szAudioBuf+m_nReadPos,nBusySize);
        memcpy(pBuf + nBusySize,audioBuffer,len);
        m_nDataSize = nBusySize + len;
        free(m_szAudioBuf);
        m_szAudioBuf = pBuf;
        m_nReadPos = 0;
    }
    else
    {
        if(nBusySize > 0)
        {
            memcpy(m_szAudioBuf, m_szAudioBuf+m_nReadPos, nBusySize);
            memcpy(m_szAudioBuf+nBusySize,audioBuffer,len);
        }
        else
        {
            memcpy(m_szAudioBuf,audioBuffer,len);
        }
        m_nDataSize = nBusySize + len;
        m_nReadPos = 0;
    }
    m_AudioLock.Unlock();
	//PreviewSoundEx();
}

void CRTMPPublish::AuidoThread()
{
    unsigned char* audioBuffer = new unsigned char[2048];
    
    while(!m_audioThread.GetStop())
    {
        int nType = AUDIOTYPE;
        int len = 0;
        m_AudioLock.Lock();
        if(m_nDataSize - m_nReadPos > 2048)
        {
            memcpy(audioBuffer,m_szAudioBuf+m_nReadPos,2048);
            m_nReadPos += 2048;
            len = 2048;
        }
        m_AudioLock.Unlock();
        
        m_aLock.Lock();
        if(len > 0 && m_audioPublish && m_audioPublish->bIsExistMediaType(AUDIOTYPE) && m_packetAudio.m_body)
        {
            if(m_audioPublish->getAudioData(m_packetAudio,audioBuffer,len))
            {
                if(m_audioPublish->getNetType() == RTMPTYPE)
                {
                    RTMP_SendPacket_Ex(m_audioPublish,&m_packetAudio,0,0,false);
                }
                else if(m_audioPublish->getNetType() == UDPTYPE)
                {
                   // printf("encoder aac data size %d  %d\n",m_packetAudio.m_nBodySize,len);
                    int nRe = UDP_SendPacket_Ex(m_audioPublish,(unsigned char*)m_packetAudio.m_body,m_packetAudio.m_nBodySize);
                }
            }
        }
        m_aLock.Unlock();
        usleep(5000);
    }
}

int CRTMPPublish::CalculateMicVolum(unsigned char* pBuf,unsigned int nBufSize)
{
	int nVol = 0;

	for(int i = 0; i<nBufSize>>5; i++)
		nVol += abs((short)(pBuf[i*32] + (pBuf[32*i+1]<<8))); // every one sample each 32 sample pcm is 16bits

	nVol = (nVol/nBufSize)<<1; // nMicVolum*4/(nBufSize>>1)/256
	nVol = nVol>0?nVol:0;
	nVol = nVol<128?nVol:128;

	return nVol;
}

void CRTMPPublish::PreviewSoundEx()
{
/*	if(m_bIsPreview)
	{
		CSourAudio * pAudio = NULL;
		pAudio = (CSourAudio *)m_sdManager.getSourData(MEDIAMICAUDIO,0);
		if(pAudio)
		{
			static unsigned char* pBuf = NULL;
			if(pBuf == NULL)
			{
				pBuf = new unsigned char[5120];
			}
			unsigned int nBufsize = 5120;
			unsigned int  nSample;
			unsigned int nChannel;
			if(pAudio->GetPreviewBufferEx(&pBuf,nBufsize,nSample,nChannel) && pBuf)
			{
				if(m_playAudio == NULL)
					m_playAudio = new CPlayAudio();

				m_nMicVolum = CalculateMicVolum(pBuf,nBufsize);
				m_playAudio->PlaySoundByDS(pBuf,nBufsize,1,nSample);
			}
		}
	}
	else
	{
		if(m_playAudio)
		{
			m_playAudio->StopSound();
			delete m_playAudio;
			m_playAudio = NULL;
		}
	}*/
}

int CRTMPPublish::UDP_SendPacket_Ex(CPublishUnit *pu,unsigned char* pBuf,unsigned nBufSize)
{
    
    m_timelock.Lock();
	if(m_iStartTime.tv_sec == 0 && m_iStartTime.tv_usec ==0)
	{
        gettimeofday(&m_iStartTime,NULL);
	}
    struct timeval curTime;
    gettimeofday(&curTime,NULL);
    
    unsigned int nTimeStamp =(curTime.tv_sec - m_iStartTime.tv_sec) * 1000 + (curTime.tv_usec - m_iStartTime.tv_usec)/1000;

    m_timelock.Unlock();
	if(pu)
	{
		return pu->UDP_SendPacket(pBuf,nBufSize,nTimeStamp);
	}

	return 0;
}

int CRTMPPublish::RTMP_SendPacket_Ex(CPublishUnit *pu, RTMPPacket *packet, int queue,int nUserType,bool bIsVideo)
{
	
	if(pu == NULL || packet == NULL)
		return 0;

    m_timelock.Lock();

	if(packet->m_nBodySize > 0 && pu->RTMP_IsConnectedEx())
	{
        if(m_iStartTime.tv_sec == 0 && m_iStartTime.tv_usec ==0)
        {
            gettimeofday(&m_iStartTime,NULL);
        }
        struct timeval curTime;
        gettimeofday(&curTime,NULL);
        
        unsigned int nTimeStamp =(curTime.tv_sec - m_iStartTime.tv_sec) * 1000 + (curTime.tv_usec - m_iStartTime.tv_usec)/1000;
        
		packet->m_nTimeStamp = nTimeStamp;

		SendMediaPackect smp;
		smp.nFrameType = nUserType;
		smp.nQueue = queue;

		memcpy(&smp.packet,packet,sizeof(RTMPPacket));
		if( bIsVideo)
		{
			int nSize = smp.packet.m_nBodySize > 131072 ? smp.packet.m_nBodySize : 131072;
			RTMPPacket_Alloc(&smp.packet,nSize);
			memcpy(smp.packet.m_body,packet->m_body,packet->m_nBodySize);
			smp.packet.m_nBodySize = packet->m_nBodySize;
		}
		else
		{
			int nSize = smp.packet.m_nBodySize > 8192 ? smp.packet.m_nBodySize : 8192;
			RTMPPacket_Alloc(&smp.packet,nSize);
			memcpy(smp.packet.m_body,packet->m_body,packet->m_nBodySize);
			smp.packet.m_nBodySize = packet->m_nBodySize;
		}

		pu->RTMP_SendPacketEx(smp,queue,bIsVideo);
	}

	if(!pu->RTMP_IsConnectedEx())
	{
		if(pu->RTMP_ReConnect(true))
		{
            printf("**************************************************************\n");
			SendMediaHeader(pu);
		}
	}
    m_timelock.Unlock();
	return 1;
}


bool CRTMPPublish::setSpeakersMute(bool vol) //静音
{
	return true;
}

bool CRTMPPublish::setSpeakersVolume(long vol)//音量
{
	return true;
}

long CRTMPPublish::getSpeakersVolume()
{
	long vol = 0;
	return vol;
}

bool CRTMPPublish::getMicMute()
{
	/*CSourAudio * pAudio = NULL;
	pAudio = (CSourAudio *)m_sdManager.getSourData(MEDIAMICAUDIO,0);
	if(pAudio)
		return pAudio->getMicMute();*/
	return false;
}

bool CRTMPPublish::setMicMute(bool vol)
{
	/*CSourAudio * pAudio = NULL;
	pAudio = (CSourAudio *)m_sdManager.getSourData(MEDIAMICAUDIO,0);
	if(pAudio)
		return pAudio->setMicMute(vol);*/
	return false;
}

bool CRTMPPublish::setMicVolume(long vol)
{
	/*CSourAudio * pAudio = NULL;
	pAudio = (CSourAudio *)m_sdManager.getSourData(MEDIAMICAUDIO,0);
	if(pAudio)
		return pAudio->setMicVolume(vol);*/
	return false;
}

long CRTMPPublish::getMicVolume()
{
	/*CSourAudio * pAudio = NULL;
	pAudio = (CSourAudio *)m_sdManager.getSourData(MEDIAMICAUDIO,0);
	if(pAudio)
		return pAudio->getMicVolume();*/
	return false;
}


MDevStatus CRTMPPublish::getMicDevStatus()
{
	if(GetDevMicCount() > 0)
	{

		if( m_audioPublish )
		{
			int nStreamType = m_audioPublish->getStreamType();
			int nTemp = nStreamType & SOURCEDEVAUDIO;
			if(nTemp ==  SOURCEDEVAUDIO)
			{
				if(getMicMute())
					return MUTE;
				return NORMAL;
			}
		}
		else
			return MICFORBID;
	}
	else
		return NODEV;
	return NODEV;
}

MDevStatus CRTMPPublish::getCamDevStatus()
{
	if(GetDevCameraCount() > 0)
	{
		if( m_listPublish.size() > 0)
		{
			list <CPublishUnit*>::iterator iter;
			for(iter = m_listPublish.begin(); iter != m_listPublish.end();iter++)
			{
				int nStreamType = m_audioPublish->getStreamType();
				int nTemp = nStreamType & SOURCECAMERA;
				if(nTemp == SOURCECAMERA)
					return NORMAL;
			}
			return CAMFORBID;
		}
		else
			return CAMFORBID;
	}
	else
		return NODEV;
}

MDevStatus CRTMPPublish::getSpeakersDevStatus()
{
    return NORMAL;
}

bool CRTMPPublish::SetEventCallback(scEventCallBack pEC,void* dwUser)
{
	m_pEventCallBack = pEC;
	m_EventpUser = dwUser;
	return true;
}

int CRTMPPublish::GetMicRTVolum() 
{
	if(m_bIsPreview)
	{
		return m_nMicVolum;
	}
	if( m_audioPublish )
		return m_audioPublish->GetMicRTVolum();
	return 0;
}


bool CRTMPPublish::PreviewSound(int nMicID,bool bIsPreview)
{
	/*CSourAudio * pAudio = NULL;
	pAudio = (CSourAudio *)m_sdManager.getSourData(MEDIAMICAUDIO,0);
	if(pAudio)
	{
		pAudio->setPreviewFalg(bIsPreview);
		pAudio->SourPreviewOpen(nMicID);
	}*/
	m_bIsPreview = bIsPreview;
	return true;
}
