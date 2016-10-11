#ifndef __GNET_GCLIENT_STATE
#define __GNET_GCLIENT_STATE

#ifdef SERVER_SOURCE
#include "protocol.h"
#else
#include "gnproto.h"
#endif

namespace GNET
{

extern GNET::Protocol::Manager::Session::State state_GLoginClient;

//extern GNET::Protocol::Manager::Session::State state_MFSClientClient;

};

#endif
