  #ifndef SOURNET_H
#define SOURNET_H
#include "sc_Thread.h"
#include "sc_CSLock.h"
#include "timerqueue.h"
#include <list>
using namespace std;
using namespace biz_utility;

struct  UDPFrameNode
{
	unsigned int nFrameSize;
	unsigned char* pFrame;
	UDPFrameNode()
	{
		nFrameSize = 0;
		pFrame = NULL;
	}
};

struct NetCameraNode
{
	int nIndex;
	short nW;
	short nH;
	short m_nUDPPort;
	char szIP[64];
	char szNetCamName[128];
	NetCameraNode()
	{
		nIndex = -1;
		nW = 0;
		nH = 0;
		m_nUDPPort = 0;
		szIP[0] = '\0';
		szNetCamName[0] = '\0';
	}
};

class CSourNet
{
public:
	CSourNet();
	~CSourNet();
public:
	bool GetBuffer(unsigned char* pBuf,unsigned int& nBufSize);
	bool SourOpen(int nIndex) ;
	bool SourClose(int nIndex);
	void getVideoWAndH(int nIndex,int &nW,int &nH);
	int getNetCamNum();
	void getNetCameraName(int nIndex,char szName[256]);
	void OnGetVideoTimer(int nEvent);
	void OnProUDPMessage();
private:
	static int  Groupsock(unsigned short nPort);
	static bool getSourcePort0(int socket, unsigned short& resultPortNum) ;
	static bool getSourcePort( int socket, unsigned short& port);
	static unsigned setBufferTo(int bufOptName, int socket, unsigned requestedSize) ;
	static unsigned getBufferSize(int bufOptName,int socket) ;
	static unsigned getSendBufferSize(int socket);
	static unsigned getReceiveBufferSize(int socket);
    static unsigned setSendBufferTo(int socket, unsigned requestedSize);
	static unsigned setReceiveBufferTo(int socket, unsigned requestedSize);
	static bool makeSocketNonBlocking(int sock);
	static bool makeSocketBlocking(int sock);
	static int  Init(unsigned short nPort,bool broadcast);

	void getFreeNode(UDPFrameNode& frameNode,int nSize);
	void PutFreeNode(UDPFrameNode& frameNode);
	
private:
	int			 m_hUDPSocket;
	unsigned short m_nUDPPort;
	int		m_nBroadcastPort;
	int		m_hBroadcastSocket;
    bool	m_bIsBindBroadcast;
	ITimerQueue		m_nVideoTimer;
private:
	int    m_iSrcVideoHeight;
	bool   m_bIsEffective;
	NetCameraNode * m_pNCam;
	int m_nMaxNetCamNum;
	int m_nCurNetCamNum;
	CMutexLock m_broadRecvLock;
	CSCThread       m_udpThreadProMsg;
private:
	list<UDPFrameNode> m_freeList;
	CMutexLock   m_freeLock;
	list<UDPFrameNode> m_busyList;
	CMutexLock   m_busyLock;

};
#endif