
#include "publishinterface.h"
#include "rtmppublish.h"
#include "MediaConfig.h"
CRTMPPublish* g_rtmpPublish = NULL;

 void InitLibEnv(HWND hShowHandle,int nFps,int nSampleRate)
{
	if(g_rtmpPublish == NULL)
	{
		//HWND hShowHwnd = NULL;
		g_rtmpPublish = new CRTMPPublish(hShowHandle, nFps,nSampleRate);
		setSpeakersMute(false);
	}
}

 void   UninitLibEnv()
{
	if(g_rtmpPublish)
	{
		delete g_rtmpPublish;
		g_rtmpPublish = NULL;
	}
}

void* getMediaMediaCollection()
{
    if(g_rtmpPublish)
    {
        return g_rtmpPublish->getMediaMediaCollection();
    }
    return NULL;
}

long   GetDevCameraCount()
{
	if(g_rtmpPublish)
	{
		return g_rtmpPublish->GetDevCameraCount();
	}
	return 0;
}


bool   GetDevCameraName(int nCameraID,char szName[256])
{
	if(g_rtmpPublish)
		return g_rtmpPublish->GetDevCameraName(nCameraID,szName);
	return false;
}


long   GetDevMicCount()
{
	if(g_rtmpPublish)
	{
		return g_rtmpPublish->GetDevMicCount();
	}
	return 0;
}

bool   GetDevMicName(int nMicID,char szName[256])
{
	if(g_rtmpPublish)
		return g_rtmpPublish->GetDevMicName(nMicID,szName);
	return false;
}


bool   TakePhotos(const char* szUrl)
{
	if(g_rtmpPublish)
		return g_rtmpPublish->TakePhotos(szUrl);
	return false;
}

bool   parsePushAddrURL(const char* szRtmpPushUrl,PushAddress pa[4],int& nPaNum)
{
	if(pa == NULL || szRtmpPushUrl == NULL)
		return false;
	int i = 0;
	char szPushAddrHeader[128] = {'\0'};
	char szPushStreamID[128] = {'\0'};
	char szVideoURL[1024] = {'\0'};
	char *p = NULL;
	const char *szSeparatorStream = "|&|";
	const char *szSeparatorMedia = "|@|";
	p = (char*)strstr(szRtmpPushUrl,szSeparatorMedia);

	if(p != NULL)
	{
		strncpy(szVideoURL,szRtmpPushUrl,p-szRtmpPushUrl);
		szVideoURL[p-szRtmpPushUrl+1] = '\0';
		strcpy(pa[i].szPushAddr,p+strlen(szSeparatorMedia));
		pa[i++].nMediaType = AUDIOTYPE;
	}
	else
	{
		strcpy(szVideoURL,szRtmpPushUrl);
	}

	p = (char*)strstr(szVideoURL,szSeparatorStream);
	if(p)
	{
		strcpy(pa[i].szPushAddr,szVideoURL);
		strncpy(pa[i].szPushAddr,szVideoURL,p-szVideoURL);
		pa[i].szPushAddr[p-szVideoURL] = '\0';
		pa[i++].nMediaType = VIDEOTYPE;
		char *pp = p;
		p = p + strlen(szSeparatorStream);
		if(p)
		{
			
			int n = 0;
			int nLen = strlen(pa[i-1].szPushAddr);
			n = nLen;
			while(n > 0)
			{
				if(*pp == '\/')
				{
					strncpy(szPushAddrHeader,szVideoURL,pp-szVideoURL);
					szPushAddrHeader[pp-szVideoURL +1] = '\0';
					break;
				}
				pp--;
				n--;
			}
			char *q = p;
			char *Temp = p;
			p = strstr(q,szSeparatorStream);
			if(p)
			{
				strncpy(szPushStreamID,q,p-q);
				szPushStreamID[p-q+1] = '\0';
				sprintf(pa[i].szPushAddr,"%s/%s",szPushAddrHeader,szPushStreamID);
				pa[i++].nMediaType = VIDEOTYPE;
				p = p + strlen(szSeparatorStream);
				strcpy(szPushStreamID,p);
				sprintf(pa[i].szPushAddr,"%s/%s",szPushAddrHeader,szPushStreamID);
				pa[i++].nMediaType = VIDEOTYPE;
			}
			else
			{
				strcpy(szPushStreamID,q);
			}
		}
		
	}
	else
	{
		strcpy(pa[i].szPushAddr,szVideoURL);
		pa[i++].nMediaType = VIDEOTYPE;
	}
	nPaNum = i;
	return true;
}

bool   rtmpPushStreamToServerBegin(const char* szRtmpPushUrl,int nStreamType,PublishParam Param)
{
	if(g_rtmpPublish== NULL || szRtmpPushUrl == NULL )
		return false;
	char szVideoURL[512] = {'\0'};
	char szAudioURL[512] = {'\0'};
	const char *szSplit = "|@|";
	const char *p = NULL;
	p = strstr(szRtmpPushUrl,szSplit);
	if(p == NULL)
	{
		strcpy(szVideoURL,szRtmpPushUrl);
	}
	else
	{
		strncpy(szVideoURL,szRtmpPushUrl,p-szRtmpPushUrl);
		szVideoURL[p-szRtmpPushUrl+1] = '\0';
		strcpy(szAudioURL,p+strlen(szSplit));
	}

	CMediaConfig  mc;
	StreamParam  sparam;
    bool bIsResult = true;
	mc.copyMediaParam(Param,sparam);
    int nFps = sparam.arrDParam[Param.ml].nVideoFps;
    g_rtmpPublish->InitMediaDevice(nFps, sparam.nAudioSmpRateEn);
	if(strcmp(szAudioURL,"") == 0)
		bIsResult = g_rtmpPublish->PushStart(szRtmpPushUrl,nStreamType,sparam);
	else
		bIsResult = g_rtmpPublish->PushStartEx(szVideoURL,szAudioURL,nStreamType,sparam);
    
    return bIsResult;
}

 bool   rtmpPushStreamToServerChangeML(const char* szRtmpPushUrl,enum MediaLevel ml)
{
    if(g_rtmpPublish == NULL || szRtmpPushUrl == NULL)
        return false;
    return g_rtmpPublish->PushChangeML(szRtmpPushUrl, ml);
}

bool   rtmpPushStreamToServerEnd(const char* szRtmpPushUrl)
{
	if(g_rtmpPublish == NULL || szRtmpPushUrl == NULL)
		return false;	

	char szVideoURL[512] = {'\0'};
	char szAudioURL[512] = {'\0'};
	const char *szSplit = "|@|";
	const char *p = NULL;
	p = strstr(szRtmpPushUrl,szSplit);
	if(p == NULL)
	{
		strcpy(szVideoURL,szRtmpPushUrl);
	}
	else
	{
		strncpy(szVideoURL,szRtmpPushUrl,p-szRtmpPushUrl);
		szVideoURL[p-szRtmpPushUrl+1] = '\0';
		strcpy(szAudioURL,p+strlen(szSplit));
	}
	bool bIsAudioResult = true;
	bool bIsVideoResult = true;
	if(strcmp(szAudioURL,"") != 0)
		 bIsAudioResult =  g_rtmpPublish->PushEnd(szAudioURL);
	bIsVideoResult = g_rtmpPublish->PushEnd(szVideoURL);
	return (bIsAudioResult && bIsVideoResult);
}

bool   rtmpPushStreamToServerChange(const char* szRtmpPushUrl,int nStreamType,PublishParam Param)
{
	if(g_rtmpPublish == NULL || szRtmpPushUrl == NULL)
		return false;	

	CMediaConfig  mc;
	StreamParam  sparam;
    bool bIsResult = true;
	mc.copyMediaParam(Param,sparam);

	char szVideoURL[512] = {'\0'};
	char szAudioURL[512] = {'\0'};
	const char *szSplit = "|@|";
	const char *p = NULL;
	p = strstr(szRtmpPushUrl,szSplit);
	if(p == NULL)
	{
		strcpy(szVideoURL,szRtmpPushUrl);
	}
	else
	{
		strncpy(szVideoURL,szRtmpPushUrl,p-szRtmpPushUrl);
		szVideoURL[p-szRtmpPushUrl+1] = '\0';
		strcpy(szAudioURL,p+strlen(szSplit));
	}
	if(strcmp(szAudioURL,"") == 0)
		bIsResult =  g_rtmpPublish->PushChange(szRtmpPushUrl,nStreamType,sparam);
	else
		bIsResult =  g_rtmpPublish->PushChangeEx(szVideoURL,szAudioURL,nStreamType,sparam);
    
    return true;
}



 bool   moveImageShowRect(const char* szRtmpPushUrl,int nIndex,int nStreamType,ScRect showRect)
{
	if(g_rtmpPublish == NULL || szRtmpPushUrl == NULL)
		return false;	

	char szVideoURL[512] = {'\0'};
	char szAudioURL[512] = {'\0'};
	const char *szSplit = "|@|";
	const char *p = NULL;
	p = strstr(szRtmpPushUrl,szSplit);
	if(p == NULL)
	{
		strcpy(szVideoURL,szRtmpPushUrl);
	}
	else
	{
		strncpy(szVideoURL,szRtmpPushUrl,p-szRtmpPushUrl);
		szVideoURL[p-szRtmpPushUrl+1] = '\0';
		strcpy(szAudioURL,p+strlen(szSplit));
	}

	return g_rtmpPublish->moveImageShowRect(szVideoURL,nIndex,nStreamType,showRect);
}


bool setMicMute(bool vol)
{
	if(g_rtmpPublish == NULL)
		return false;
	return g_rtmpPublish->setMicMute(vol);
}


bool setMicVolume(long vol)
{
	if(g_rtmpPublish == NULL)
		return false;
	return g_rtmpPublish->setMicVolume(vol);
}


long getMicVolume()
{
	if(g_rtmpPublish == NULL)
		return 0;
	return g_rtmpPublish->getMicVolume();
}


int GetMicRTVolum()
{
	if(g_rtmpPublish == NULL)
		return false;
	return g_rtmpPublish->GetMicRTVolum();
}


long getSpeakersVolume()
{
	if(g_rtmpPublish == NULL)
		return 0;
	return g_rtmpPublish->getSpeakersVolume();
}


bool setSpeakersMute(bool vol)
{
	if(g_rtmpPublish == NULL)
		return false;
	return g_rtmpPublish->setSpeakersMute(vol);
}

bool setSpeakersVolume(long vol)
{
	if(g_rtmpPublish == NULL && (vol >= 0 && vol <= 100))
		return false;
	return g_rtmpPublish->setSpeakersVolume(vol);
}


MDevStatus getMicDevStatus()
{
	if(g_rtmpPublish == NULL)
		return NODEV;
	return g_rtmpPublish->getMicDevStatus();
}


MDevStatus getCamDevStatus()
{
	if(g_rtmpPublish == NULL)
		return NODEV;
	return g_rtmpPublish->getCamDevStatus();
}

MDevStatus getSpeakersDevStatus()
{
	if(g_rtmpPublish == NULL)
		return NODEV;
	return g_rtmpPublish->getSpeakersDevStatus();
}

bool SetEventCallback(scEventCallBack pEC,void* dwUser)
{
	if(g_rtmpPublish == NULL)
		return false;
	return  g_rtmpPublish->SetEventCallback(pEC,dwUser);
}

bool PreviewSound(int nMicID,bool bIsPreview)
{
	if(g_rtmpPublish == NULL)
		return false;
	return  g_rtmpPublish->PreviewSound(nMicID,bIsPreview);
}
