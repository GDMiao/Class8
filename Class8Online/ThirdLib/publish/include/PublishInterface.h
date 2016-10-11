#ifndef PUBLISHINTERFACE_H
#define PUBLISHINTERFACE_H


#include "StreamHeader.h"

 void   InitLibEnv(HWND hShowHandle,int nFps,int nSampleRate);

 void   UninitLibEnv();

 long   GetDevCameraCount();

 bool   GetDevCameraName(int nCameraID,char szName[256]);

 long   GetDevMicCount();

 bool   GetDevMicName(int nMicID,char szName[256]);

 bool   TakePhotos(const char* szUrl);

 bool   parsePushAddrURL(const char* szRtmpPushUrl,struct PushAddress pa[4],int& nPaNum);

 bool   rtmpPushStreamToServerBegin(const char* szRtmpPushUrl,int nStreamType,struct PublishParam Param);

 bool   rtmpPushStreamToServerEnd(const char* szRtmpPushUrl);

 bool   rtmpPushStreamToServerChangeML(const char* szRtmpPushUrl,enum MediaLevel ml);

 bool   rtmpPushStreamToServerChange(const char* szRtmpPushUrl,int nStreamType,struct PublishParam Param);

 bool   moveImageShowRect(const char* szRtmpPushUrl,int nIndex,int nStreamType,struct ScRect showRect);

 bool  savePushDataToLocalFlvFileBegin(const char* szLocalFile,HWND hRecordWindow);

 bool  savePushDataToLocalFlvFileEnd();

 bool setMicMute(bool vol);

 bool setMicVolume(long vol);

 long getMicVolume();

 int GetMicRTVolum();

 long getSpeakersVolume();

 bool setSpeakersMute(bool vol);

 bool setSpeakersVolume(long vol);

 enum MDevStatus getMicDevStatus();

 MDevStatus getCamDevStatus();

 MDevStatus getSpeakersDevStatus();

 bool PreviewSound(int nMicID,bool bIsPreview);

 bool SetEventCallback(scEventCallBack pEC,void* dwUser);

void* getMediaMediaCollection();

#endif