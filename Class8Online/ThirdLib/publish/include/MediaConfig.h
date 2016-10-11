#ifndef MEDIACONFIG_H
#define MEDIACONFIG_H
#include <stdlib.h>
#include <string.h>
#include "StreamHeader.h"


struct DecoderParam
{
    int nVideoW;        //ÊÓÆµ¿í
    int nVideoH;		//ÊÓÆµ¸ß
    int nVideoBitRate;	//ÊÓÆµÂëÂ
    int nVideoFps;		//ÊÓÆµÖ¡Â
    DecoderParam()
    {
        nVideoBitRate = 0; // ??
        nVideoW = 0;
        nVideoH = 0;
        nVideoFps = 0;
    }
};

struct StreamParam
{

	VideoUnit  VU[4];

	int  nVUNum;
    int DecoderParamML;
    DecoderParam arrDParam[3];

	HWND hShowHwnd;

	int nSelectMicID;//Ñ¡ÔñµÄid(0 <= id < GetDevMicCount())
	int bAudioKaraoke; 
	int nAudioBitRate; 
	int nAudioSmpRateCap;//ÒôÆµ²ÉÑù
	int nAudioSmpRateEn;
	int nAudioChannels;

    // 
	
	bool bIsFullScreen; //½ØÆÁÊÇ·ñÈ«ÆÁ
	bool bDrawLocRect;
	bool bIsPublish;

	StreamParam()
	{
		memset(&VU,0,sizeof(VU));
		nVUNum = 0;

        DecoderParamML = 1;
		nSelectMicID = 0;
		bAudioKaraoke = 0;
		hShowHwnd = NULL;

		nAudioBitRate = 64000;
		nAudioSmpRateCap = 32000;
		nAudioSmpRateEn = 32000;
		nAudioChannels = 1;
		
		bIsFullScreen = true;
		bDrawLocRect = false;
		bIsPublish = true;
	}
};

class CMediaConfig
{
public:
	CMediaConfig();
	~CMediaConfig();
public:
	void copyMediaParam(PublishParam pparam,StreamParam &sparam);
private:
	void getMediaConfig(MediabBusiness mb,MasterSlave ms,MediaRole mr,MediaLevel ml,
		bool bIsManyCamera,bool bIsHighAudio,StreamParam &param);

	void getAnchorMainSmoothConfig(StreamParam &param,bool bIsManyCamera,bool bIsHighAudio);
	void getAnchorMainStandConfig(StreamParam &param,bool bIsManyCamera,bool bIsHighAudio);
	void getAnchorMainHighConfig(StreamParam &param,bool bIsManyCamera,bool bIsHighAudio);

	void getAnchorSubSmoothConfig(StreamParam &param,bool bIsHighAudio);
	void getAnchorSubHighConfig(StreamParam &param,bool bIsHighAudio);
	void getAnchorSubStandConfig(StreamParam &param,bool bIsHighAudio);

	void getListenerConfig(StreamParam &param);
};

#endif