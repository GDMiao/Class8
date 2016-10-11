//-------------------------------------------------------------------------------------------------
//FileName:APlatform.h
//Created by liyi 2012,11,22
//-------------------------------------------------------------------------------------------------
#ifndef _A_PLATFORM_H_
#define _A_PLATFORM_H_

//Platform Defines
#if defined(_MSC_VER) 

#if defined(WINRT)
#define A_PLATFORM_WINRT 1
#else
#define A_PLATFORM_WIN_DESKTOP 1
#define A_PLATFORM_WIN_DESKTOP 1
#endif

#if defined(_WIN64)
#define A_PLATFORM_64 1
#elif defined(_WIN32)
#define A_PLATFORM_32 1
#endif

#elif defined(__ANDROID__)
//Attention: "__linux__" is also defined on Android platform.
#define A_PLATFORM_ANDROID 1

#if defined(__x86_64__)
#define A_PLATFORM_64 1
#else
#define A_PLATFORM_32 1
#endif

#elif defined(__linux__)

#define A_PLATFORM_LINUX 1

#if defined(__x86_64__)
#define A_PLATFORM_64 1
#else
#define A_PLATFORM_32 1
#endif


#elif defined(__APPLE__)

#define A_PLATFORM_XOS 1


#if defined(__x86_64__) || defined(__arm64__)
#define A_PLATFORM_64 1
#else
#define A_PLATFORM_32 1
#endif

#endif


#ifdef __cplusplus
#define A_BEGIN_EXTERN_C	extern "C" {
#define A_END_EXTERN_C      }
#define A_EXTERN_C			extern "C"
#else
#define A_BEGIN_EXTERN_C
#define A_END_EXTERN_C
#define A_EXTERN_C
#endif

#endif //_A_PLATFORM_H_

