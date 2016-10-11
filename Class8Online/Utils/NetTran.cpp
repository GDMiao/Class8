//
//  NetTran.cpp
//  Class8Online
//
//  Created by Class8 on 16/8/31.
//  Copyright © 2016年 chuliangliang. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>
#include <string.h>
#include <ifaddrs.h>
#include "unistd.h"
#include "NetTran.h"

void connectServer(const char* serv,unsigned int port,bool isIp6)
{
    int r = 0;
    int s = 0;
    
    s = socket(isIp6 ? AF_INET6 : AF_INET,SOCK_STREAM,IPPROTO_TCP);
    
    if(s<=0)
    {
        return;
    }
    
    if(isIp6)
    {
        sockaddr_in6 addrServ;
        
        memset(&addrServ,0,sizeof(addrServ));
        addrServ.sin6_len = sizeof(sockaddr_in6);
        addrServ.sin6_family = AF_INET6;
        addrServ.sin6_port = htons(port);
        r = inet_pton(AF_INET6,serv,(void*)&addrServ.sin6_addr);
        if(r<0)
        {
            goto _end;
        }

        //r = connect(s, (struct sockaddr *)&addrServ,sizeof(addrServ));
    }
    else
    {
        sockaddr_in addrServ;

        memset(&addrServ,0,sizeof(addrServ));
        addrServ.sin_len = sizeof(sockaddr_in);
        addrServ.sin_family = AF_INET;
        addrServ.sin_port = htons(port);
        r = inet_pton(AF_INET,serv,(void*)&addrServ.sin_addr);
        if(r<0)
        {
            goto _end;
        }
        
        //r = connect(s, (struct sockaddr *)&addrServ,sizeof(addrServ));
        if(r<0)
        {
            goto _end;
        }
    }

_end:
    shutdown(s,SHUT_RDWR);
}

bool getNetAddr(const char* host,unsigned int port,char * addr)
{
    if(NULL==host || NULL == addr)
    {
        return false;
    }
    
    bool isIp6 = false;
    struct addrinfo* ifAddr = NULL;
    struct addrinfo  ifHints;
    struct addrinfo* reAddr = NULL;
    char szPort[32];
    
    memset(&ifHints, 0, sizeof(ifHints));
    
    ifHints.ai_flags = AI_DEFAULT;
    ifHints.ai_family = AF_UNSPEC;
    ifHints.ai_socktype = SOCK_STREAM;
    
    sprintf(szPort,"%d",port);
    
    int ret = getaddrinfo(host, szPort, &ifHints, &ifAddr);
    if(ret != 0)
    {
        printf("getaddrinfo failed");
        return false;
    }
    
    reAddr = ifAddr;
    while(reAddr)
    {
        char ipAddr[128]={0};
        if(ifAddr->ai_family == AF_INET6)
        {
            struct sockaddr_in6* addrIn = (struct sockaddr_in6*)reAddr->ai_addr;
            inet_ntop(AF_INET6,&addrIn->sin6_addr,ipAddr,sizeof(ipAddr));
            isIp6 = true;
        }
        else
        {
            struct sockaddr_in* addrIn = (struct sockaddr_in*)reAddr->ai_addr;
            inet_ntop(AF_INET,&addrIn->sin_addr,ipAddr,sizeof(ipAddr));
            isIp6 = false;
        }
        
        reAddr = reAddr->ai_next;
        
        if(addr)
        {
            strcpy(addr,ipAddr);
        }
        
        if(isIp6)
        {
            break;
        }
    }
    
    freeaddrinfo(ifAddr);
   
    if(isIp6)
    {
        connectServer(addr,port,isIp6);
    }
    else
    {
        connectServer(host,port,isIp6);
    }

    return isIp6;
}