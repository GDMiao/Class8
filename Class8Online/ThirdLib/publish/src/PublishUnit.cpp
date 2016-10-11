
#include "PublishUnit.h"
#include <string.h>
#include <math.h>
#include <unistd.h>

list<RtmpAddr> CPublishUnit::m_listRTMPAddr;

void* CALLBACK _send_media_loop(void *pUserData)
{
	if(pUserData)
	{
		CPublishUnit * pUser = (CPublishUnit *)pUserData;
		pUser->send_proc();
	}
    return NULL;
}


CPublishUnit::CPublishUnit(CSourDataManager* pDataManager)
{
	m_nStreamType = 0; //流类型
	m_MediaUrl[0] = '\0' ; //视频发布地址
	m_pDataManager = pDataManager;
	m_listVideoSour.clear();
	m_listAudioSour.clear();
	m_iSrcVideoWidth = 0;
	m_iSrcVideoHeight = 0;
	m_szRGBBuffer = NULL;
	m_nRGBBufSize = 0;
	m_rtmpImpl = NULL;
	m_udpImpl = NULL;
	m_bIsKaolaOK = false;
	m_bIsPublish = false;
	m_isCapturing = false;
	m_nMicVolum = 0;
	m_pbPCMBuffer = NULL;
	m_nAACInputSamples = 0;
	m_nVideoFps = 0;
	m_nVideoSpan = 0;
    memset(&m_nLastGetTime,0,sizeof(m_nLastGetTime));
	m_nNextGetTime = 0;
	m_bIsTakePhotos = false;
	m_pEventCallBack = NULL;
	m_EventpUser = NULL;
    bIsSendHeader = false;
    m_nCurDecoderML = 0;
}

CPublishUnit::~CPublishUnit()
{
	m_send_media_thread.End();
	m_listVideoSour.clear();
	m_listAudioSour.clear();
	if(m_BPL.pBuffer)
	{
		free(m_BPL.pBuffer);
		m_BPL.pBuffer = NULL;
	}
	PublishEnd();
}

void CPublishUnit::InitRTMPAddlist()
{
	RtmpAddr ra;
	ra.copy("rtmp://class8media.address.ch1","61.147.188.51",1935);
	m_listRTMPAddr.push_back(ra);
	ra.copy("rtmp://class8media.address.ch2","61.147.188.52",1935);
	m_listRTMPAddr.push_back(ra);
	ra.copy("rtmp://class8media.address.ch0","10.2.2.234",1935);
	m_listRTMPAddr.push_back(ra);
}

bool CPublishUnit::FindRealAddrByKey(const char* szHostaddr,RtmpAddr& ra)
{
	char *szHeader = "rtmp://";
	int nHeaderSize =  strlen(szHeader);
	char szKey[256] = {'\0'};
	strcpy(szKey,szHeader);
	if(strncmp(szHeader,szHostaddr,nHeaderSize) != 0)
		return false;
	char *p = (char*)szHostaddr + nHeaderSize;
	int i = nHeaderSize;
	while(*p != '\0' && *p != '\/')
	{
		szKey[i++] = *p++;
	}
	szKey[i] = '\0';

	if(m_listRTMPAddr.size() > 0)
	{
		list<RtmpAddr>::iterator iter;
		for(iter = m_listRTMPAddr.begin();iter != m_listRTMPAddr.end();iter++)
		{
			RtmpAddr rnode = (*iter);
			if(rnode.cmpIsMapping(szKey))
			{
				ra = rnode;
				return true;
			}
		}
	}
	return false;
}

STREAMPROTYPE CPublishUnit::getStreamProtocolType(const char* szUrl)
{
	STREAMPROTYPE  st = RTMPTYPE ;
	if(strncmp(szUrl,"rtmp://",strlen("rtmp://")) == 0)
	{
		st = RTMPTYPE;
	}
	else if(strncmp(szUrl,"udp://",strlen("udp://")) == 0)
	{
		st = UDPTYPE;
	}
	else if(strncmp(szUrl,"rtsp://",strlen("rtsp://")) == 0)
	{
		st = RTSPTYPE;
	}
	else if(strncmp(szUrl,"http://",strlen("http://")) == 0)
	{
		st = HTTPTYPE;
	}
	return st;
}

bool  CPublishUnit::RTMP_ReConnect(bool bReConnect)
{
	if(bReConnect)
	{
		return RtmpConnect(m_MediaUrl,bReConnect);
	}
	return false;
}

bool CPublishUnit::RtmpConnect(const char* szRtmpUrl,bool bReConnect)
{
	if(m_rtmpImpl == NULL || !RTMP_IsConnected(m_rtmpImpl))
	{
		if(m_rtmpImpl == NULL)
		{
			m_rtmpImpl= RTMP_Alloc();  
			if(m_rtmpImpl == NULL) 
				return false;
		}
		RtmpAddr ra;
		RTMP_Init(m_rtmpImpl);
		int nRet = RTMP_SetupURL(m_rtmpImpl, (char*)szRtmpUrl); 
		RTMP_EnableWrite(m_rtmpImpl);  
		
		if(!FindRealAddrByKey(szRtmpUrl,ra))
		{
			if(!RTMP_Connect(m_rtmpImpl, NULL) || !RTMP_ConnectStream(m_rtmpImpl,0))
			{
				return false;
			}
		}
		else
		{
			if(!RTMP_ConnectEx(m_rtmpImpl, NULL,ra.szRealIP,ra.nPort) || !RTMP_ConnectStream(m_rtmpImpl,0))
			{
				return false;
			}
		}
	}
	return true;
}

int CPublishUnit::UDP_SendPacket(unsigned char* pBuf,unsigned nBufSize,unsigned int nPts)
{
	if(m_udpImpl && m_bIsPublish)
	{
		return m_udpImpl->sendData(pBuf,nBufSize,nPts);
	}
	return 0;
}

int CPublishUnit::RTMP_SendPacketEx(SendMediaPackect smp, int queue,bool bIsVideo)
{
	if(!m_bIsPublish)
		return 0;

	m_sendLock.Lock();

	if(bIsVideo)
	{
		if(m_sendVideoList.size() <= 20)
			m_sendVideoList.push_back(smp);
		else
		{
			RTMPPacket_Free(&smp.packet);
			smp.packet.m_body = NULL;
		}
	}
	else
	{
		if(m_sendAudioList.size() <= 200)
			m_sendAudioList.push_back(smp);
		else
		{
			RTMPPacket_Free(&smp.packet);
			smp.packet.m_body = NULL;
		}
	}

	//if(m_sendVideoList.size() <= 0 && m_sendAudioList.size() <= 0)
	//{
	//	m_sendCond.cond_signal();
	//}
	m_sendLock.Unlock();
	return 1;
}

bool CPublishUnit::RTMP_IsConnectedEx()
{
	if(m_rtmpImpl)
	{
		return RTMP_IsConnected(m_rtmpImpl);
	}
	return true;
}

bool CPublishUnit::RtmpDisConnect()
{
	if(m_rtmpImpl)
	{
		RTMP_DeleteStream(m_rtmpImpl);
 		RTMP_Close(m_rtmpImpl);
 		RTMP_Free(m_rtmpImpl);
 		m_rtmpImpl = NULL;
 	}
	return true;
}

bool CPublishUnit::bIsExistMediaType(int nMediaType)
{
	//vedio
	int nVideoTemp = m_nStreamType & nMediaType;
	if(nVideoTemp == nMediaType)
		return true;
	return false;
}

bool CPublishUnit::PublishStart(const char* szUrl,int nStreamType,StreamParam param)
{
	//
	if(szUrl == NULL)
		return false;
	
	if(m_isCapturing)
	{
		return true;
	}

	m_bIsPublish = param.bIsPublish;
	m_nStreamType = nStreamType;
	strcpy(m_MediaUrl,szUrl);
	int nTempType = m_nStreamType & VIDEOTYPE;
	if(nTempType == VIDEOTYPE)
	{
		m_nVideoFps = param.arrDParam[param.DecoderParamML].nVideoFps > 0 ? param.arrDParam[param.DecoderParamML].nVideoFps  : 1;
		m_nVideoSpan = 1000 / param.arrDParam[param.DecoderParamML].nVideoFps ;
		m_nLastGetTime.tv_sec = 0;
        m_nLastGetTime.tv_usec = 0;
		m_nNextGetTime = 0;
	}

	if(!SelectEncoder(nStreamType,param))
	{
		return false;
	}
	
	if(m_bIsPublish)
	{
		m_stNetType = getStreamProtocolType(szUrl);
		if(m_stNetType == RTMPTYPE)
		{
			if(!RtmpConnect(szUrl,false))
				return false;
		}
		else if(m_stNetType == UDPTYPE)
		{
			if(m_udpImpl == NULL)
			{
				m_udpImpl = new CUDPClinet(szUrl);
				m_udpImpl->InitUDPClient(UDPPUSH);
			}	
		}
	}

	if(m_send_media_thread.GetStop())
	{
		//m_sendCond.conde_setwaittime(10);
		m_send_media_thread.Begin(_send_media_loop,this);
	}
	m_isCapturing = true;
	return true;
}


bool CPublishUnit::PublishChanage(const char* szUrl,int nStreamType,StreamParam param)
{
	// 
	if(!m_isCapturing)
	{
		return false;
	}

	m_nStreamType = nStreamType;
	m_bIsPublish = param.bIsPublish;
	int nTempType = m_nStreamType & VIDEOTYPE;
	if(nTempType == VIDEOTYPE)
	{
		m_nVideoFps = param.arrDParam[param.DecoderParamML].nVideoFps  > 0 ? param.arrDParam[param.DecoderParamML].nVideoFps  : 1;
		m_nVideoSpan = 1000 / param.arrDParam[param.DecoderParamML].nVideoFps ;
	}

	if(!SelectEncoder(nStreamType,param))
	{
		return false;
	}

	if(m_bIsPublish)
	{
		m_stNetType = getStreamProtocolType(szUrl);
		if(m_stNetType == RTMPTYPE)
		{
			if(!RtmpConnect(szUrl,false))
				return false;
		}
		else if(m_stNetType == UDPTYPE)
		{
			if(m_udpImpl == NULL)
			{
				m_udpImpl = new CUDPClinet(szUrl);
			}	
			m_udpImpl->InitUDPClient(UDPPUSH);
		}
	}
	else
	{
		int nTempType = m_nStreamType & AUDIOTYPE;
		if(m_udpImpl && nTempType != AUDIOTYPE)
		{
			m_udpImpl->UnInitUDPClient();
		}	
	}

	return true;
}

bool CPublishUnit::PublishChanageEx(int nWidth,int nHeight)
{
    //vedio
    if(nWidth == m_iSrcVideoWidth && m_iSrcVideoHeight == nHeight)
        return true;
    
    bool bVIsExist = false;
    VideoEncoderNode venTemp;
    int nVideoTemp = m_nStreamType & VIDEOTYPE;
    if(nVideoTemp == VIDEOTYPE)
    {
        m_iSrcVideoWidth = nWidth;
        m_iSrcVideoHeight = nHeight;
        int nFps = m_publishparam.arrDParam[m_nCurDecoderML].nVideoFps;
        int nVideoBitRate = m_publishparam.arrDParam[m_nCurDecoderML].nVideoBitRate;
        
        for(m_encoderVIter = m_listVE.begin();m_encoderVIter != m_listVE.end();m_encoderVIter++)
        {
            VideoEncoderNode ven = (*m_encoderVIter);
            if(ven.nVideoH == nHeight
               &&ven.nVideoW == nWidth
               &&ven.ph264Encoder)
            {
                bVIsExist = true;
                ven.ph264Encoder->h264_EncodeInit(m_iSrcVideoWidth,m_iSrcVideoHeight);
                venTemp = ven;
                break;
            }
        }
        
        if( !bVIsExist && nFps != 0 && nVideoBitRate != 0)
        {

            VideoEncoderNode ven;
            ven.nVideoBitRate = nVideoBitRate ;
            ven.nVideoFps = nFps;
            ven.nVideoH = nHeight;
            ven.nVideoW = nWidth ;
            ven.ph264Encoder = new CH264Encoder();
            if(ven.ph264Encoder)
            {
                ven.ph264Encoder->h264_SetParam(ven.nVideoW,ven.nVideoH,ven.nVideoBitRate,ven.nVideoFps);
                if(ven.ph264Encoder->h264_EncodeInit(ven.nVideoW,ven.nVideoH))
                {
                    m_listVE.push_back(ven);
                    venTemp = ven;
                }
                else
                {
                    delete ven.ph264Encoder;
                    ven.ph264Encoder = NULL;
                    return false;
                }
            }
        }
    }
    if(venTemp.ph264Encoder)
    {
        m_vLock.Lock();
        m_vCurExcEncoder = venTemp;
        bIsSendHeader = false;
        m_vLock.Unlock();
    }
    return true;
}

bool CPublishUnit::PublishEnd()
{
	if(m_isCapturing)
	{
		m_send_media_thread.End();
		RtmpDisConnect();
		if(m_udpImpl)
		{
			m_udpImpl->UnInitUDPClient();
			delete m_udpImpl;
			m_udpImpl = NULL;
		}

		for(m_encoderVIter = m_listVE.begin();m_encoderVIter != m_listVE.end();m_encoderVIter++)
		{
			VideoEncoderNode ven = (*m_encoderVIter);
			if(ven.ph264Encoder)
			{
				ven.ph264Encoder->h264_EncodeUninit();
				delete ven.ph264Encoder;
				ven.ph264Encoder = NULL;
			}
		}
		m_listVE.clear();

		if(m_aCurExcEncoder.paacEncoder)
		{
			m_aCurExcEncoder.paacEncoder->aac_EncodeUnInit();
			delete m_aCurExcEncoder.paacEncoder;
			m_aCurExcEncoder.paacEncoder = NULL;
		}

		if(m_szRGBBuffer)
		{
			delete [] m_szRGBBuffer;
			m_szRGBBuffer = NULL;
		}

		if(m_pbPCMBuffer)
		{
			delete [] m_pbPCMBuffer;
			m_pbPCMBuffer = NULL;
		}
		clearSendList();
	}
	m_isCapturing = 0;
	return true;
}


bool CPublishUnit::setShowRect(int nIndex,int nStreamType,ScRect showRect)
{
	m_picLock.Lock();
	list<PicSourceNode>::iterator iter;
	for(iter = m_listVideoSour.begin();iter != m_listVideoSour.end();iter++)
	{
		if((*iter).pSD->GetSourType() == nStreamType)
		{
			if(nIndex == (*iter).pSD->getSourID())
			{
				(*iter).rc = showRect;
				break;
			}
		}
	}
	m_picLock.Unlock();
	return true;
}

bool CPublishUnit::SelectVideoEnhanceTypes(int nStreamType,StreamParam param)
{
	bool bStatus = true;
	
	if(m_pDataManager)
	{
		for(int i = 0; i< param.nVUNum;i++)
		{
			if(param.VU[i].nType == SOURCECAMERA || param.VU[i].nType == SOURCESCREEN)
			{
				ISourData*  pSD = m_pDataManager->getSourData(MEDIASCREENVIODE,param.VU[i].nSelectCameraID);
				if(pSD)
				{
					pSD->AVE_SetID(param.VU[i].nVEnMainID,param.VU[i].nVEnSubID, param.VU[0].nParam);
				}
			}
		}
	}

	return bStatus;
}

bool CPublishUnit::SelectEncoder(int nStreamType,StreamParam param)
{
	bool bAIsExist = false;
	bool bVIsExist = false;
	VideoEncoderNode venTemp;
	AudioEncoderNode aenTemp;
	//audio
	m_bIsKaolaOK = param.bAudioKaraoke;
	int nAudioTemp = nStreamType & AUDIOTYPE;
    
    m_nCurDecoderML = param.DecoderParamML;
    m_publishparam = param;
    
	if(nAudioTemp == AUDIOTYPE)
	{
		m_aLock.Lock();
		AudioEncoderNode aen = m_aCurExcEncoder;
		if(aen.bAudioKaraoke == param.bAudioKaraoke
			&& aen.nAudioBitRate == param.nAudioBitRate 
			&& aen.nAudioSmpRateCap == param.nAudioSmpRateCap && aen.paacEncoder)
		{
			bAIsExist = true;		
		}
		else
		{
			if(aen.paacEncoder)
			{
				aen.paacEncoder->aac_EncodeUnInit();
				delete aen.paacEncoder;
				aen.paacEncoder = NULL;
			}
		}

	    if(!bAIsExist)
	    {
			AudioEncoderNode aen;
			aen.bAudioKaraoke = param.bAudioKaraoke;
			aen.nAudioBitRate = param.nAudioBitRate;
			aen.nAudioSmpRateCap = param.nAudioSmpRateCap;
			aen.nAudioSmpRateEn = param.nAudioSmpRateEn;

			int iChannel = param.nAudioChannels;
			unsigned long  nAACInputSamples = 0;
			aen.paacEncoder = new CAACEncoder();
			if(aen.paacEncoder && aen.paacEncoder->aac_EncodeInit(iChannel,aen.nAudioBitRate,aen.nAudioSmpRateEn,nAACInputSamples))
			{
				if(nAACInputSamples != m_nAACInputSamples)
				{
					delete m_pbPCMBuffer;
					m_pbPCMBuffer = NULL;
					m_nAACInputSamples = nAACInputSamples;
				}
				if(m_pbPCMBuffer == NULL )
					m_pbPCMBuffer = new unsigned char [m_nAACInputSamples];
			}
			else
			{
				if(aen.paacEncoder)
				{
					delete aen.paacEncoder;
					aen.paacEncoder = NULL;
				}
				m_aLock.Unlock();
				return false;
			}
			aenTemp = aen;
		}
		m_aCurExcEncoder = aenTemp;
		m_aLock.Unlock();
	}

	//vedio
	int nVideoTemp = nStreamType & VIDEOTYPE;
	if(nVideoTemp == VIDEOTYPE)
	{
        m_iSrcVideoWidth = param.arrDParam[param.DecoderParamML].nVideoW;
        m_iSrcVideoHeight = param.arrDParam[param.DecoderParamML].nVideoH;
        
		for(m_encoderVIter = m_listVE.begin();m_encoderVIter != m_listVE.end();m_encoderVIter++)
		{
			VideoEncoderNode ven = (*m_encoderVIter);
			if(ven.nVideoBitRate == param.arrDParam[param.DecoderParamML].nVideoBitRate
				&&ven.nVideoFps == param.arrDParam[param.DecoderParamML].nVideoFps
				&&ven.nVideoH == param.arrDParam[param.DecoderParamML].nVideoH
				&&ven.nVideoW == param.arrDParam[param.DecoderParamML].nVideoW
				&&ven.ph264Encoder)
			{
				bVIsExist = true;
				ven.ph264Encoder->h264_EncodeInit(m_iSrcVideoWidth,m_iSrcVideoHeight);
				venTemp = ven;
				break;
			}
		}
        
        /*m_vLock.Lock();
        
        VideoEncoderNode venxTemp = m_vCurExcEncoder;
        if(venxTemp.nVideoBitRate == param.nVideoBitRate
           &&venxTemp.nVideoFps == param.nVideoFps
           &&venxTemp.nVideoH == param.nVideoH
           &&venxTemp.nVideoW == param.nVideoW
           &&venxTemp.ph264Encoder)
        {
            bVIsExist = true;
        }*/
        

		if( !bVIsExist )
		{
           /* if(m_vCurExcEncoder.ph264Encoder)
            {
                m_vCurExcEncoder.ph264Encoder->h264_EncodeUninit();
                delete m_vCurExcEncoder.ph264Encoder;
                m_vCurExcEncoder.ph264Encoder = NULL;
            }*/
            
			VideoEncoderNode ven;
			ven.nVideoBitRate = param.arrDParam[param.DecoderParamML].nVideoBitRate ;
			ven.nVideoFps = param.arrDParam[param.DecoderParamML].nVideoFps;
			ven.nVideoH = param.arrDParam[param.DecoderParamML].nVideoH;
			ven.nVideoW = param.arrDParam[param.DecoderParamML].nVideoW;
			ven.ph264Encoder = new CH264Encoder();
			if(ven.ph264Encoder)
			{
				ven.ph264Encoder->h264_SetParam(ven.nVideoW,ven.nVideoH,ven.nVideoBitRate,ven.nVideoFps);
				if(ven.ph264Encoder->h264_EncodeInit(ven.nVideoW,ven.nVideoH))
				{
					m_listVE.push_back(ven);
					venTemp = ven;
				}
				else
				{
					delete ven.ph264Encoder;
					ven.ph264Encoder = NULL;
					return false;
				}
			}
		}
	}
    m_vLock.Lock();
	m_vCurExcEncoder = venTemp;
    bIsSendHeader = false;
	m_vLock.Unlock();
	return true;
}


bool CPublishUnit::getMediaMsgHeader(RTMPPacket& packet,bool bIsSend)
{
	if(m_rtmpImpl == NULL  || packet.m_body == NULL)
		return false;
	packet.m_nChannel = 0x04;  
	packet.m_headerType = RTMP_PACKET_SIZE_LARGE;  
	packet.m_nTimeStamp = 0;  
	packet.m_nInfoField2 = m_rtmpImpl->m_stream_id;   

	packet.m_hasAbsTimestamp = 0;  
	unsigned char* szBodyBuffer = (unsigned char*)packet.m_body;
	char * szTmp = packet.m_body;  
	packet.m_packetType = RTMP_PACKET_TYPE_INFO;  

	if(m_vCurExcEncoder.ph264Encoder)
	{
		int nVHSize = 0;
		m_vCurExcEncoder.ph264Encoder->h264_copyHeaderParam((unsigned char*)szTmp,nVHSize);
		szTmp += nVHSize;
	}
	///////////////////////////////////////////////////////////////////////////////

	if(m_aCurExcEncoder.paacEncoder)
	{
		int nAHSize = 0;
		m_aCurExcEncoder.paacEncoder->aac_copyHeaderParam((unsigned char*)szTmp,nAHSize,m_aCurExcEncoder.bAudioKaraoke);
		szTmp +=  nAHSize;
	}
	///////////////////////////////////////////////////////////////////////////////
	szTmp=put_amf_string( szTmp, "");
    szTmp=put_byte( szTmp, AMF_OBJECT_END );
    
	packet.m_nBodySize=szTmp-(char *)szBodyBuffer; 
	return true;
}

bool CPublishUnit::getVideoHeader(RTMPPacket& packet,bool bIsSend)
{
	if((m_rtmpImpl == NULL && m_udpImpl == NULL ) || packet.m_body == NULL)
		return false;

	packet.m_nChannel = 0x04;  
	packet.m_headerType = RTMP_PACKET_SIZE_LARGE;  
	packet.m_nTimeStamp = 0;  
	if(m_rtmpImpl)
		packet.m_nInfoField2 = m_rtmpImpl->m_stream_id;  
	else if(m_udpImpl)
		packet.m_nInfoField2 = 1;  
	else 
		return false;

	packet.m_hasAbsTimestamp = 0;  
	unsigned char* szBodyBuffer = (unsigned char*)packet.m_body;
	char * szTmp = packet.m_body;  
	packet.m_packetType = RTMP_PACKET_TYPE_INFO; 

	if(m_vCurExcEncoder.ph264Encoder)
	{
		packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
		packet.m_packetType = RTMP_PACKET_TYPE_VIDEO;  
		szBodyBuffer[0]=0x17;  
		szBodyBuffer[1]=0x00;  
		szBodyBuffer[2]=0x00;  
		szBodyBuffer[3]=0x00;  
		szBodyBuffer[4]=0x00;  
		szBodyBuffer[5]=0x01;  
		szBodyBuffer[6]=0x42;  
		szBodyBuffer[7]=0xC0;  
		szBodyBuffer[8]=0x15;  
		szBodyBuffer[9]=0x03;  
		szBodyBuffer[10]=0x01;  
		szTmp=(char *)szBodyBuffer+11;  
		int nVSSize = 0;
		if(!m_vCurExcEncoder.ph264Encoder->h264_CopyPPSandSPS((unsigned char*)szTmp,nVSSize))
            return false;
		szTmp += nVSSize;
		packet.m_nBodySize=szTmp-(char *)szBodyBuffer;
        bIsSendHeader = true;
		return true;
	}
	return false;
}

bool CPublishUnit::getAudioHeader(RTMPPacket& packet,bool bIsSend)
{
	if(m_aCurExcEncoder.paacEncoder)
	{
		if((m_rtmpImpl == NULL && m_udpImpl == NULL ) || packet.m_body == NULL)
			return false;

		if(m_rtmpImpl)
			packet.m_nInfoField2 = m_rtmpImpl->m_stream_id;  
		else if(m_udpImpl)
			packet.m_nInfoField2 = 1;  
		else 
			return false;

		packet.m_nChannel = 0x04;  
		packet.m_headerType = RTMP_PACKET_SIZE_LARGE;  
		packet.m_nTimeStamp = 0;  

		packet.m_hasAbsTimestamp = 0; 
		packet.m_packetType = RTMP_PACKET_TYPE_AUDIO; 

		char hdr[4] ;
		if(m_aCurExcEncoder.nAudioSmpRateEn == 16000)
		{
			hdr[0] = 0xAF;
			hdr[1] = 0x00;
			hdr[2] = 0x14;
			hdr[3] = 0x08;
		}
		else if(m_aCurExcEncoder.nAudioSmpRateEn == 32000)
		{
			hdr[0] = 0xAF;
			hdr[1] = 0x00;
			hdr[2] = 0x12;
			hdr[3] = 0x90;
		}
		memcpy(packet.m_body,hdr, 4);
		packet.m_nBodySize	= 4;
		return true;
	}
	return false;
}



bool CPublishUnit::getVideoData(RTMPPacket& packet,unsigned char* videoBuffer, int vWidth, int vHeight)
{
    char* szBodyBuffer = packet.m_body;
    packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
    packet.m_nTimeStamp = 0;
    packet.m_hasAbsTimestamp = 0;
    packet.m_packetType = RTMP_PACKET_TYPE_VIDEO;
    szBodyBuffer[0]=0x17;
    szBodyBuffer[1]=0x01;
    szBodyBuffer[2]=0x00;
    szBodyBuffer[3]=0x00;
    szBodyBuffer[4]=0x42;
    
    unsigned int nBufSize = DATA_SIZE - 18;
    
    m_vLock.Lock();
    if(!m_vCurExcEncoder.ph264Encoder->h264_Encode((unsigned char*)szBodyBuffer,nBufSize,m_szRGBBuffer,videoBuffer,vWidth,vHeight))
    {
        m_vLock.Unlock();
        return false;
    }
    m_vLock.Unlock();
    packet.m_nBodySize = nBufSize;
    return true;
}


bool CPublishUnit::getAudioData(RTMPPacket& packet,unsigned char* audioBuffer ,int len)
{
	if(m_isCapturing)
	{
		CSourAudio * pAudio = NULL;
		list<ISourData*>::iterator iter;
		packet.m_nChannel = 0x04;    
		packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
		packet.m_nTimeStamp = 0;
		packet.m_hasAbsTimestamp = 0; 
		packet.m_packetType = RTMP_PACKET_TYPE_AUDIO; 
		unsigned char* szTemp = (unsigned char*)packet.m_body; 
		szTemp[0]  = 0xAF;
		szTemp[1]  = 0x01;// Raw AAC

	
        m_aLock.Lock();
        if(m_aCurExcEncoder.paacEncoder)
        {
            unsigned int nBufSize = len;
            m_nMicVolum = CalculateMicVolum(audioBuffer, nBufSize);
            //AAC encode
            unsigned char* pbAACBuffer = NULL;
            unsigned int  m_outPutAAcSize = 0;
            if(m_aCurExcEncoder.paacEncoder->aac_Encode(&pbAACBuffer,m_outPutAAcSize,audioBuffer,len))
            {
                if(m_outPutAAcSize > 0)
                {
                    memcpy(szTemp+2,pbAACBuffer+7,m_outPutAAcSize-7);
                    packet.m_nBodySize =  m_outPutAAcSize -7 + 2;
                    m_aLock.Unlock();
                    return true;
                }
            }
        }
        m_aLock.Unlock();
	}
	return false;
}

int CPublishUnit::CalculateMicVolum(unsigned char* pBuf,unsigned int nBufSize)
{
	int nVol = 0;

	/*for(int i = 0; i<nBufSize>>5; i++)
		nVol += abs((short)(pBuf[i*32] + (pBuf[32*i+1]<<8))); // every one sample each 32 sample pcm is 16bits

	nVol = (nVol/nBufSize)<<1; // nMicVolum*4/(nBufSize>>1)/256
	nVol = nVol>0?nVol:0;
	nVol = nVol<128?nVol:128;*/

	return nVol;
}


void CPublishUnit::send_proc()
{
	while(!m_send_media_thread.GetStop())
	{
		bool bIsVideo = false;
		SendMediaPackect smp;

		m_sendLock.Lock();
		int nSendListSize  = m_sendAudioList.size();
		if(nSendListSize  > 0)
		{
			smp = m_sendAudioList.front();
			m_sendAudioList.pop_front();
		}
		else
		{
			nSendListSize  = m_sendVideoList.size();
			if(nSendListSize  > 0)
			{
				bIsVideo = true;
				smp = m_sendVideoList.front();
				m_sendVideoList.pop_front();
			}
		}
		m_sendLock.Unlock();

		if(smp.packet.m_body)
		{
			int res = 0;
			if(m_rtmpImpl && RTMP_IsConnected(m_rtmpImpl))
			{
				res = RTMP_SendPacket(m_rtmpImpl, &smp.packet, smp.nQueue);
			}

			if(smp.packet.m_body != NULL)
			{
				RTMPPacket_Free(&smp.packet);
				smp.packet.m_body = NULL;
			}
		}
        else
        {
            usleep(10000);
        }
        //m_sendCond.cond_wait();
	}
}

void CPublishUnit::clearSendList()
{
	m_sendLock.Lock();
	if(m_sendVideoList.size() > 0)
	{
		list<SendMediaPackect>::iterator itersend;
		for(itersend = m_sendVideoList.begin(); itersend != m_sendVideoList.end();itersend++)
		{
			SendMediaPackect smp = (*itersend);
			if(smp.packet.m_body)
			{
				RTMPPacket_Free(&smp.packet);
				smp.packet.m_body = NULL;
			}
		}
	}
	m_sendVideoList.clear();
	if(m_sendAudioList.size() > 0)
	{
		list<SendMediaPackect>::iterator itersend;
		for(itersend = m_sendAudioList.begin(); itersend != m_sendAudioList.end();itersend++)
		{
			SendMediaPackect smp = (*itersend);
			if(smp.packet.m_body)
			{
				RTMPPacket_Free(&smp.packet);
				smp.packet.m_body = NULL;
			}
		}
	}
	m_sendAudioList.clear();
	
	m_sendLock.Unlock();
}

bool CPublishUnit::SetEventCallback(scEventCallBack pEC,void* dwUser)
{
	m_pEventCallBack = pEC;
	m_EventpUser = dwUser;
	return true;
}

void CPublishUnit::TakePhotos()
{
	m_bIsTakePhotos = true;
}