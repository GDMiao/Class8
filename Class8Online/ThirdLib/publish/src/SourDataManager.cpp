#include "SourDataManager.h"

CSourDataManager::CSourDataManager()
{
	m_listSour.clear();
	InitDevSourManager();
}

CSourDataManager::~CSourDataManager()
{
	UninitDevSourManager();
	
}

void CSourDataManager::clearSour()
{
	list<SourceNode>::iterator iter;
	for(iter = m_listSour.begin(); iter != m_listSour.end();iter++)
	{
		ISourData *psd = (*iter).pSD;
		if(psd)
		{
			psd->SourClose();
			delete psd;
		    (*iter).pSD = NULL;
		}
	}
	m_listSour.clear();
}

bool CSourDataManager::InitDevSourManager()
{
	StreamParam param;
	//liw
    string sname = "carame";
	CSourCamera * pCamera = new CSourCamera(640,480,10,sname);
	if(pCamera == NULL)
	{
		return false;
	}

	pCamera->SetSourType(SOURCECAMERA);
	pCamera->SourOpen(&param);

	SourceNode sN;
	sN.pSD = (ISourData *)pCamera;
	sN.nMediaType = MEDIACAMERAVIODE;
	sN.nUserType = PUSHTONET;
	sN.nIndex = 0;
	m_listSour.push_back(sN);

	CSourAudio *pAudio = new CSourAudio("audio");
	if(pAudio == NULL)
	{
		clearSour();
		return false;
	}

	pAudio->SetSourType(SOURCEDEVAUDIO);
	pAudio->SourOpen(&param);
	sN.pSD = (ISourData *)pAudio;
	sN.nMediaType = MEDIAMICAUDIO;
	sN.nUserType = PUSHTONET;
	sN.nIndex = 0;
	m_listSour.push_back(sN);
	
	return false;
}

bool CSourDataManager::UninitDevSourManager()
{
	clearSour();
	return false;
}

//功能：获取当前设备摄像头设备信息
long CSourDataManager::GetDevCameraCount()
{
	list<SourceNode>::iterator iter;
	for(iter = m_listSour.begin();iter != m_listSour.end();iter++)
	{
		ISourData* pSour = (*iter).pSD;
		if(pSour->GetSourType() == SOURCECAMERA)
		{
			return ((CSourCamera*)pSour)->GetDevCameraCount();
		}	
	}
	return 0;
}

bool CSourDataManager::GetDevCameraName(long nIndex,char szName[256])
{
	list<SourceNode>::iterator iter;
	for(iter = m_listSour.begin();iter != m_listSour.end();iter++)
	{
		ISourData* pSour = (*iter).pSD;
		if(pSour->GetSourType() == SOURCECAMERA)
		{
			((CSourCamera*)pSour)->GetDevCameraName(nIndex,szName);
			 return true;
		}
			
	}
	return false;
}

//功能:获取当前设备麦克风数目
long   CSourDataManager::GetDevMicCount()
{
	list<SourceNode>::iterator iter;
	for(iter = m_listSour.begin();iter != m_listSour.end();iter++)
	{
		if((*iter).nMediaType == MEDIAMICAUDIO)
		{
			ISourData* pSour = (*iter).pSD;
			return ((CSourAudio*)pSour)->GetDevMicCount();
		}	
	}
	return 0;
}

bool   CSourDataManager::GetDevMicName(int nMicID,char szName[256])
{
	list<SourceNode>::iterator iter;
	for(iter = m_listSour.begin();iter != m_listSour.end();iter++)
	{
		if((*iter).nMediaType == MEDIAMICAUDIO)
		{
			ISourData* pSour = (*iter).pSD;
			return ((CSourAudio*)pSour)->GetDevMicName(nMicID,szName);
		}	
	}
	return 0;
}

ISourData* CSourDataManager::getSourData(int nMediaType,int nIndex)
{
	ISourData* psd = NULL;
	list<SourceNode>::iterator iter;
	for(iter = m_listSour.begin();iter != m_listSour.end();iter++)
	{
		if(((*iter).nMediaType == nMediaType) && ((*iter).nIndex == nIndex) )
		{
			psd = (*iter).pSD;
			break;
		}	
	}
	return psd;
}