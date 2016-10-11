
// ScreenRecoderDlg.h : 头文件
//

#pragma once

#include "PublishUnit.h"
#include "sc_CSLock.h"
#include "sc_Thread.h"
#include "CUDPClient.h"

#include <list>

using namespace std;


class CRTMPPublish
{
// 构造
public:
	CRTMPPublish(HWND hShowHwnd,int nFps,int nSampleRate);	// 标准构造函数
	~CRTMPPublish();
    bool InitMediaDevice(int nFps,int nSampleRate);

public:
    void * getMediaMediaCollection();
	bool PushStart(const char* szUrl,int nStreamType,StreamParam& param);
	bool PushChange(const char* szUrl,int nStreamType,StreamParam& param);
	bool PushEnd(const char* szUrl);

    bool  PushChangeML(const char* szRtmpPushUrl,int ml);
    
	bool PushChangeEx(const char* szVideoUrl,const char* szAudioUrl,int nStreamType,StreamParam& param);
	bool PushStartEx(const char* szVideoUrl,const char* szAudioUrl,int nStreamType,StreamParam& param);

	bool PushFileToServerBegin(const char* szLocalFile,char* szServerURL,int nUseDrawToolType,HWND hShowHwnd);

	bool   moveImageShowRect(const char* szRtmpPushUrl,int nIndex,int nStreamType,ScRect showRect);

	long GetDevCameraCount();
	bool GetDevCameraName(long nIndex,char szName[256]);

	long   GetDevMicCount();
    bool   GetDevMicName(int nMicID,char szName[256]);

	void OnVideoTimer(unsigned char* videoBuffer, int vWidth, int vHeight);
	void OnAudioTimer(unsigned char* audioBuffer ,int len);
    
    void AuidoThread();

	bool setSpeakersMute(bool vol);
	bool setSpeakersVolume(long vol);

	bool setMicVolume(long vol);
	bool setMicMute(bool vol);
	bool getMicMute();

	long getMicVolume();
	long getSpeakersVolume();
    
	MDevStatus getMicDevStatus();

	MDevStatus getCamDevStatus();

	MDevStatus getSpeakersDevStatus();

	int    GetMicRTVolum();

	bool PreviewSound(int nMicID,bool bIsPreview);
	bool TakePhotos(const char* szUrl);
	
	void send_proc();
	void send_audio_proc();
	bool SetEventCallback(scEventCallBack pEC,void* dwUser);
	
	
private:
	bool OnInit();
	void OnUnInit();

	void PreviewSoundEx();
	int RTMP_SendPacket_Ex(CPublishUnit *pu, RTMPPacket *packet, int queue,int nUserType,bool bIsVideo=true);
	int UDP_SendPacket_Ex(CPublishUnit *pu,unsigned char* pBuf,unsigned nBufSize);
	CPublishUnit* FindPU(const char* szURL);
	CPublishUnit* FindPUAndRemove(const char* szURL);
	void SendMediaHeader(CPublishUnit *pu,bool bIsSend = false);
	int CalculateMicVolum(unsigned char* pBuf,unsigned int nBufSize);
private:

	CMutexLock		m_timelock;
    
	struct timeval	m_iStartTime;
	CMutexLock      m_vLock;
	RTMPPacket      m_packetVideo;  
	RTMPPacket      m_packetAudio;  
	CMutexLock      m_aLock;
    
    unsigned char*  m_szAudioBuf;
    unsigned int    m_nAduioMaxSize;
    unsigned int    m_nDataSize;
    int             m_nReadPos;
    CMutexLock      m_AudioLock;
    CSCThread       m_audioThread;
private:
	list <CPublishUnit*> m_listPublish;
	CPublishUnit*        m_audioPublish;  
	char m_szPlayFileName[512] ;
private:
	CSourDataManager  m_sdManager;
	RTMP           *m_InitImpl;
	bool           m_bIsPreview;
	int            m_nMicVolum;
private:
	scEventCallBack  m_pEventCallBack;
	void *			 m_EventpUser;
private:
    int              m_nVideoW;
    int              m_nVideoH;
    int              m_nFps;
    int              m_nSampeleRate;
    HWND               m_hShowHwnd;
};

