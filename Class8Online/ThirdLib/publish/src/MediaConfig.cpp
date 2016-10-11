#include "MediaConfig.h"

CMediaConfig::CMediaConfig()
{

}

CMediaConfig::~CMediaConfig()
{

}

void CMediaConfig::copyMediaParam(PublishParam pparam,StreamParam &sparam)
{
	getMediaConfig(pparam.mb,pparam.ms,pparam.mr,pparam.ml,pparam.bIsManyCamera,pparam.bIsHighAudio,sparam);
	sparam.bAudioKaraoke = pparam.bAudioKaraoke;
	sparam.bDrawLocRect = pparam.bDrawLocRect;
	sparam.bIsFullScreen = pparam.bIsFullScreen;
	sparam.bIsPublish = pparam.bIsPublish;
	sparam.hShowHwnd = pparam.hShowHwnd;
	sparam.nSelectMicID = pparam.nSelectMicID;
	//sparam.nVEnMainID = pparam.nVEnMainID;
	//sparam.nVEnSubID = pparam.nVEnSubID;
	sparam.nVUNum = pparam.nVUNum;
	memcpy(&sparam.VU,&pparam.VU,sizeof(pparam.VU));

}

void CMediaConfig::getMediaConfig(MediabBusiness mb,MasterSlave ms,MediaRole mr,MediaLevel ml,
								 bool bIsManyCamera,bool bIsHighAudio,StreamParam &param)
{
	if(mb == EDUCATION)
	{
		if(ms == MAINCAMERA)
		{
			if(mr == ANCHORROLE)
			{
				if(ml == SMOOTHLEVEL)
				{
					getAnchorMainSmoothConfig(param,bIsManyCamera,bIsHighAudio);
                    param.DecoderParamML = SMOOTHLEVEL;
				}
				else if(ml == STANDARRDLEVEL)
				{
					getAnchorMainStandConfig(param,bIsManyCamera,bIsHighAudio);
                    param.DecoderParamML = STANDARRDLEVEL;
				}
				else if(ml == HIGHLEVEL)
				{
					getAnchorMainHighConfig(param,bIsManyCamera,bIsHighAudio);
                    param.DecoderParamML = HIGHLEVEL;
				}

			}
			else if(mr == LISTENERROLE)
			{
				getListenerConfig(param);
			}
			
		}
		else if(ms == SUBCAMERA)
		{
			if(mr == ANCHORROLE)
			{
				if(ml == SMOOTHLEVEL)
				{
					getAnchorSubSmoothConfig(param,bIsHighAudio);
                     param.DecoderParamML = SMOOTHLEVEL;
				}
				else if(ml == STANDARRDLEVEL)
				{
					getAnchorSubStandConfig(param,bIsHighAudio);
                    param.DecoderParamML = STANDARRDLEVEL;
				}
				else if(ml == HIGHLEVEL)
				{
					getAnchorSubHighConfig(param,bIsHighAudio);
                    param.DecoderParamML = HIGHLEVEL;
				}
			}
			else if(mr == LISTENERROLE)
			{
				getListenerConfig(param);
			}
		}
	}
}

void CMediaConfig::getAnchorMainSmoothConfig(StreamParam &param,bool bIsManyCamera,bool bIsHighAudio)
{

    param.arrDParam[SMOOTHLEVEL].nVideoFps = 8;
    param.arrDParam[SMOOTHLEVEL].nVideoW = 352;
    param.arrDParam[SMOOTHLEVEL].nVideoH = 288;
    param.arrDParam[SMOOTHLEVEL].nVideoBitRate = 200;


    param.arrDParam[STANDARRDLEVEL].nVideoFps = 8;
    param.arrDParam[STANDARRDLEVEL].nVideoW = 640;
    param.arrDParam[STANDARRDLEVEL].nVideoH = 480;
    param.arrDParam[STANDARRDLEVEL].nVideoBitRate = 300;
    
    param.arrDParam[HIGHLEVEL].nVideoFps = 8;
    param.arrDParam[HIGHLEVEL].nVideoW = 1280;
    param.arrDParam[HIGHLEVEL].nVideoH = 720;
    param.arrDParam[HIGHLEVEL].nVideoBitRate = 400;
	//“Ù∆µ
	if(bIsHighAudio)
	{
		param.nAudioBitRate = 64000;
		param.nAudioChannels = 1;
		param.nAudioSmpRateCap = 32000;
		param.nAudioSmpRateEn = 32000; //48000
	}
	else
	{
		param.nAudioBitRate = 64000;
		param.nAudioChannels = 1;
		param.nAudioSmpRateCap = 32000;
		param.nAudioSmpRateEn = 16000;
	}
}

void CMediaConfig::getAnchorMainStandConfig(StreamParam &param,bool bIsManyCamera,bool bIsHighAudio)
{
    param.arrDParam[SMOOTHLEVEL].nVideoFps = 8;
    param.arrDParam[SMOOTHLEVEL].nVideoW = 352;
    param.arrDParam[SMOOTHLEVEL].nVideoH = 288;
    param.arrDParam[SMOOTHLEVEL].nVideoBitRate = 200;
    
    
    param.arrDParam[STANDARRDLEVEL].nVideoFps = 8;
    param.arrDParam[STANDARRDLEVEL].nVideoW = 640;
    param.arrDParam[STANDARRDLEVEL].nVideoH = 480;
    param.arrDParam[STANDARRDLEVEL].nVideoBitRate = 300;
    
    param.arrDParam[HIGHLEVEL].nVideoFps = 8;
    param.arrDParam[HIGHLEVEL].nVideoW = 1280;
    param.arrDParam[HIGHLEVEL].nVideoH = 720;
    param.arrDParam[HIGHLEVEL].nVideoBitRate = 400;
	//“Ù∆µ
	if(bIsHighAudio)
	{
		param.nAudioBitRate = 94000;
		param.nAudioChannels = 1;
		param.nAudioSmpRateCap = 32000;
		param.nAudioSmpRateEn = 32000;
	}
	else
	{
		param.nAudioBitRate = 64000;
		param.nAudioChannels = 1;
		param.nAudioSmpRateCap = 32000;
		param.nAudioSmpRateEn = 32000;
	}
}

void CMediaConfig::getAnchorMainHighConfig(StreamParam &param,bool bIsManyCamera,bool bIsHighAudio)
{
    param.arrDParam[SMOOTHLEVEL].nVideoFps = 8;
    param.arrDParam[SMOOTHLEVEL].nVideoW = 352;
    param.arrDParam[SMOOTHLEVEL].nVideoH = 288;
    param.arrDParam[SMOOTHLEVEL].nVideoBitRate = 200;
    
    
    param.arrDParam[STANDARRDLEVEL].nVideoFps = 8;
    param.arrDParam[STANDARRDLEVEL].nVideoW = 640;
    param.arrDParam[STANDARRDLEVEL].nVideoH = 480;
    param.arrDParam[STANDARRDLEVEL].nVideoBitRate = 300;
    
    param.arrDParam[HIGHLEVEL].nVideoFps = 8;
    param.arrDParam[HIGHLEVEL].nVideoW = 1280;
    param.arrDParam[HIGHLEVEL].nVideoH = 720;
    param.arrDParam[HIGHLEVEL].nVideoBitRate = 400;

	//“Ù∆µ
	param.nAudioBitRate = 92000;
	param.nAudioChannels = 1;
	param.nAudioSmpRateCap = 32000;
	param.nAudioSmpRateEn = 32000;
}

void CMediaConfig::getAnchorSubSmoothConfig(StreamParam &param,bool bIsHighAudio)
{
    param.arrDParam[SMOOTHLEVEL].nVideoFps = 8;
    param.arrDParam[SMOOTHLEVEL].nVideoW = 352;
    param.arrDParam[SMOOTHLEVEL].nVideoH = 288;
    param.arrDParam[SMOOTHLEVEL].nVideoBitRate = 120;
    
    
    param.arrDParam[STANDARRDLEVEL].nVideoFps = 8;
    param.arrDParam[STANDARRDLEVEL].nVideoW = 352;
    param.arrDParam[STANDARRDLEVEL].nVideoH = 288;
    param.arrDParam[STANDARRDLEVEL].nVideoBitRate = 120;
    
    param.arrDParam[HIGHLEVEL].nVideoFps = 8;
    param.arrDParam[HIGHLEVEL].nVideoW = 352;
    param.arrDParam[HIGHLEVEL].nVideoH = 288;
    param.arrDParam[HIGHLEVEL].nVideoBitRate = 120;

	//“Ù∆µ
	if(bIsHighAudio)
	{
		param.nAudioBitRate = 64000;
		param.nAudioChannels = 1;
		param.nAudioSmpRateCap = 32000;
		param.nAudioSmpRateEn = 32000;
	}
	else
	{
		param.nAudioBitRate = 64000;
		param.nAudioChannels = 1;
		param.nAudioSmpRateCap = 32000;
		param.nAudioSmpRateEn = 16000;
	}
}

void CMediaConfig::getAnchorSubHighConfig(StreamParam &param,bool bIsHighAudio)
{
    param.arrDParam[SMOOTHLEVEL].nVideoFps = 8;
    param.arrDParam[SMOOTHLEVEL].nVideoW = 352;
    param.arrDParam[SMOOTHLEVEL].nVideoH = 288;
    param.arrDParam[SMOOTHLEVEL].nVideoBitRate = 120;
    
    
    param.arrDParam[STANDARRDLEVEL].nVideoFps = 8;
    param.arrDParam[STANDARRDLEVEL].nVideoW = 352;
    param.arrDParam[STANDARRDLEVEL].nVideoH = 288;
    param.arrDParam[STANDARRDLEVEL].nVideoBitRate = 120;
    
    param.arrDParam[HIGHLEVEL].nVideoFps = 8;
    param.arrDParam[HIGHLEVEL].nVideoW = 352;
    param.arrDParam[HIGHLEVEL].nVideoH = 288;
    param.arrDParam[HIGHLEVEL].nVideoBitRate = 120;

	//“Ù∆µ
	param.nAudioBitRate = 92000;
	param.nAudioChannels = 1;
	param.nAudioSmpRateCap = 32000;
	param.nAudioSmpRateEn = 32000;
}

void CMediaConfig::getAnchorSubStandConfig(StreamParam &param,bool bIsHighAudio)
{
	// ”∆µ
    param.arrDParam[SMOOTHLEVEL].nVideoFps = 8;
    param.arrDParam[SMOOTHLEVEL].nVideoW = 352;
    param.arrDParam[SMOOTHLEVEL].nVideoH = 288;
    param.arrDParam[SMOOTHLEVEL].nVideoBitRate = 120;
    
    
    param.arrDParam[STANDARRDLEVEL].nVideoFps = 8;
    param.arrDParam[STANDARRDLEVEL].nVideoW = 352;
    param.arrDParam[STANDARRDLEVEL].nVideoH = 288;
    param.arrDParam[STANDARRDLEVEL].nVideoBitRate = 120;
    
    param.arrDParam[HIGHLEVEL].nVideoFps = 8;
    param.arrDParam[HIGHLEVEL].nVideoW = 352;
    param.arrDParam[HIGHLEVEL].nVideoH = 288;
    param.arrDParam[HIGHLEVEL].nVideoBitRate = 120;

	//“Ù∆µ
	if(bIsHighAudio)
	{
		param.nAudioBitRate = 92000;
		param.nAudioChannels = 1;
		param.nAudioSmpRateCap = 32000;
		param.nAudioSmpRateEn = 32000;
	}
	else
	{
		param.nAudioBitRate = 64000;
		param.nAudioChannels = 1;
		param.nAudioSmpRateCap = 32000;
		param.nAudioSmpRateEn = 32000;
	}
}

void CMediaConfig::getListenerConfig(StreamParam &param)
{
	// ”∆µ
    param.arrDParam[SMOOTHLEVEL].nVideoFps = 8;
    param.arrDParam[SMOOTHLEVEL].nVideoW = 352;
    param.arrDParam[SMOOTHLEVEL].nVideoH = 288;
    param.arrDParam[SMOOTHLEVEL].nVideoBitRate = 240;
    
    
    param.arrDParam[STANDARRDLEVEL].nVideoFps = 8;
    param.arrDParam[STANDARRDLEVEL].nVideoW = 352;
    param.arrDParam[STANDARRDLEVEL].nVideoH = 288;
    param.arrDParam[STANDARRDLEVEL].nVideoBitRate = 240;
    
    param.arrDParam[HIGHLEVEL].nVideoFps = 8;
    param.arrDParam[HIGHLEVEL].nVideoW = 352;
    param.arrDParam[HIGHLEVEL].nVideoH = 288;
    param.arrDParam[HIGHLEVEL].nVideoBitRate = 240;

	//“Ù∆µ
	param.nAudioBitRate = 64000;
	param.nAudioChannels = 1;
	param.nAudioSmpRateCap = 32000;
	param.nAudioSmpRateEn = 16000;
}