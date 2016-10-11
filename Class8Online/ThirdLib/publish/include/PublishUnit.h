#ifndef PUBLISHUNIT_H
#define PUBLISHUNIT_H
#include "StreamHeader.h"
#include "rtmp.h"
#include "SourDataManager.h"
#include "CUDPClient.h"
#include <list>

using namespace std;

struct SendMediaPackect
{
	RTMPPacket packet;
	unsigned int nFrameType;
	int          nQueue;
	SendMediaPackect()
	{
		memset(&packet,0,sizeof(RTMPPacket));
		nFrameType = 0;
		nQueue = 0;
	}
};


class CPublishUnit
{
public:
	CPublishUnit(CSourDataManager* pDataManager);
	~CPublishUnit();
    
public:
	bool PublishStart(const char* szUrl,int nStreamType,StreamParam param);
	bool PublishChanage(const char* szUrl,int nStreamType,StreamParam param);
	bool PublishEnd();
    bool PublishChanageEx(int nWidth,int nHeight);

    inline void  PushChangeML(int ml) { m_nCurDecoderML = ml; }
    
	bool getMediaMsgHeader(RTMPPacket& packet,bool bIsSend = false);
	bool getVideoHeader(RTMPPacket& packet,bool bIsSend = false);
	bool getAudioHeader(RTMPPacket& packet,bool bIsSend = false);

	bool getAudioData(RTMPPacket& packet,unsigned char* audioBuffer ,int len);
    bool getVideoData(RTMPPacket& packet,unsigned char* videoBuffer, int vWidth, int vHeight);

	int   UDP_SendPacket(unsigned char* pBuf,unsigned nBufSize,unsigned int nPts);
	int   RTMP_SendPacketEx(SendMediaPackect smp, int queue,bool bIsVideo);
	bool  RTMP_IsConnectedEx();
	bool  RTMP_ReConnect(bool bReConnect=false);
	bool  bIsExistMediaType(int nMediaType);
	void clearSendList();
	bool setShowRect(int nIndex,int nStreamType,ScRect showRect);
	void send_proc();
	inline char* getPublishAddr() {return m_MediaUrl;}
	inline STREAMPROTYPE getNetType() {return m_stNetType;}
	inline int GetMicRTVolum() {return m_nMicVolum;}
	void TakePhotos();
	bool SetEventCallback(scEventCallBack pEC,void* dwUser);
	inline int getStreamType() {return m_nStreamType;}
    
    bool  getbIsSendSucessVideoHeader() {return  bIsSendHeader;}
private:
	bool SelectDevSour(int nStreamType,StreamParam param);
	STREAMPROTYPE getStreamProtocolType(const char* szUrl);
	bool SelectVideoEnhanceTypes(int nStreamType,StreamParam param);
	bool RtmpConnect(const char* szRtmpUrl,bool bReConnect=false);
	bool SelectEncoder(int nStreamType,StreamParam param);
	bool RtmpDisConnect();
	void ZoomBitMap(unsigned char *pSrcImg, unsigned char *pDstImg, int nWidth, int nHeight, int nDesW,int nDstH,ScRect rc); 
	void CheckBPL(int nMaxW,int nMaxH);
	int CalculateMicVolum(unsigned char* pBuf,unsigned int nBufSize);
	bool bIsGetImageTime();
private:
	static bool FindRealAddrByKey(const char* szHostaddr,RtmpAddr& ra);
	static void InitRTMPAddlist();
private:
	list<PicSourceNode>  m_listVideoSour;
	CMutexLock           m_picLock;
	list<ISourData*>  m_listAudioSour;
	CMutexLock          m_audLock;
private:
	int   m_nStreamType; //流类型
	STREAMPROTYPE  m_stNetType;
	char  m_MediaUrl[512] ; //视频发布地址
private:
	bool  m_isCapturing;
	bool  m_bIsPublish ;
    
    bool  bIsSendHeader ;
    int   m_nCurDecoderML;
    StreamParam m_publishparam;
private:
	int   m_iSrcVideoWidth;
	int   m_iSrcVideoHeight;
	unsigned char*  m_szRGBBuffer;
	unsigned int    m_nRGBBufSize;
	VideoEncoderNode m_vCurExcEncoder;
	PicLayer       m_BPL;
    
	int            m_nVideoFps;
	int            m_nVideoSpan;
	struct timeval    m_nLastGetTime;
	int    m_nNextGetTime;
    
	list<VideoEncoderNode>::iterator m_encoderVIter;
	list<VideoEncoderNode> m_listVE;
	CMutexLock       m_vLock;
private:
	AudioEncoderNode m_aCurExcEncoder;
	unsigned long          m_nAACInputSamples;
	unsigned char*		   m_pbPCMBuffer;
    bool           m_bIsKaolaOK;
	CMutexLock     m_aLock;
	int            m_nMicVolum;
	bool           m_bIsTakePhotos;
private:
	CSourDataManager  *m_pDataManager;
	RTMP          *m_rtmpImpl;
	CUDPClinet    *m_udpImpl;
 
private:
	list<SendMediaPackect>   m_sendVideoList;
	list<SendMediaPackect>   m_sendAudioList;
	CMutexLock               m_sendLock;
	CSCThread                m_send_media_thread;
	//CSCCond                  m_sendCond;
private:
	scEventCallBack			 m_pEventCallBack;
	void *					m_EventpUser;
private:
	static list<RtmpAddr> m_listRTMPAddr;
};
#endif