//
//  AXOSSys.h
//  Angelica
//
//  Created by jianming lin on 2/23/13.
//
//

#ifndef _A_XOS_SYS_H_
#define _A_XOS_SYS_H_

#include "ATypes.h"
#if A_PLATFORM_XOS

//#include "ASys.h"
#include "errno.h"
#include <pthread.h>

#define a_snprintf snprintf
#define a_isnan isnan

A_FORCEINLINE auint32 ASys::GetFileTimeStamp(const char* szFileName)
{

    struct stat fileStat;
	stat(szFileName, &fileStat);
	return (auint32)(fileStat.st_mtime);
}

A_FORCEINLINE auint32 ASys::GetFileSize(const char* szFileName)
{
	struct stat fileStat;
	if(stat(szFileName, &fileStat) == 0)
    {
        return (auint32)(fileStat.st_size);
    }
    
	return 0;
}

A_FORCEINLINE  auint32 ASys::ChangeFileAttributes(const char* szFileName, int mode)
{
	return chmod( szFileName,mode);
}

A_FORCEINLINE bool ASys::IsFileExist(const char* szFileName)
{
    if( access(szFileName, 0) == 0)
        return true;
	return false;
}

A_FORCEINLINE bool ASys::DeleteFile(const char* szFile)
{
    if( remove(szFile) == -1)
        return afalse;
    
    return atrue;
}

A_FORCEINLINE bool ASys::CopyFile(const char* src,const char* des,bool bFailIfExists)
{
    const int BUF_SIZE = 1024;
    FILE* fromfd = NULL;
    FILE*  tofd = NULL;
    int bytes_read = 0;
    int bytes_write = 0;
    char buffer[BUF_SIZE];

    /*open source file*/
    if((fromfd = fopen(src,"r")) == NULL)
    {
        //fprintf(stderr,"Open source file failed:%s\n",strerror(errno));
        return afalse;
    }
    /*create dest file*/
    if((tofd = fopen(des,"wb")) == NULL)
    {
        //fprintf(stderr,"Create dest file failed:%s\n",strerror(errno));
        fclose(fromfd);
        return 0;
    }
    
    /*copy file code*/
    while((bytes_read = fread(buffer,1,BUF_SIZE,fromfd)))
    {
        if(bytes_read ==-1 && errno!=EINTR)
            break; /*an important mistake occured*/
        else if(bytes_read == 0)
        {
            break;
        }
        else if( bytes_read > 0 )
        {
            bytes_write = fwrite(buffer,1,bytes_read,tofd);
            ASSERT(bytes_write == bytes_read);
        }
    }
    fclose(fromfd);
    fclose(tofd);
    return atrue;
}

A_FORCEINLINE bool ASys::MoveFile(const char* src,const char* des)
{
    if(!CopyFile(src,des,false))
        return false;
    if( !DeleteFile(src))
        return false;    
    return  true;
}



A_FORCEINLINE bool ASys::CreateDirectory(const char* szDir)
{
    if( mkdir(szDir, S_IRWXU) == -1)
        return afalse;
    
    return  atrue;
    
}



A_FORCEINLINE void ASys::Sleep(unsigned int nMilliSecond)
{
    ::usleep(nMilliSecond * 1000);
}

A_FORCEINLINE auptrint ASys::GetCurrentThreadID()
{
	return (auptrint)pthread_self();
}

#define ASys_GetCurrentFrame(frame_cur) __asm\
{\
	mov frame_cur, ebp\
}

//鈥欌€毬棵斺墹陋茠鈥光€濃垰鈭樎犓澛Ｂ?卤每鈥撁庘€濃垰鈭?// A_FORCEINLINE unsigned long ASys::GetCurrentFrame()
// {
// 	unsigned long frame_cur = 0;
//
// 	__asm
// 	{
// 		mov frame_cur, ebp
// 	}
// 	return frame_cur;
// }

//A_FORCEINLINE int ASys::GetSizeCharFromWChar(const wchar_t* szString)
//{
////	return WideCharToMultiByte( CP_ACP, 0, szString, -1, NULL, 0, NULL, NULL );
//    return 0;
//}

//A_FORCEINLINE int ASys::GetSizeWCharFromChar(const char* szString)
//{
//	//return MultiByteToWideChar( CP_ACP, 0, szString, -1, NULL, 0 );
//    return 0;
//}

//A_FORCEINLINE int ASys::GetSizeUTF8FromWChar( const wchar_t* szString )
//{
//    aint32 iConvertBytes = 0;
//    char* oldlocale = setlocale(LC_CTYPE,"en_US.UTF-8");
//    
//    //	Calculate destination buffer size
//    iConvertBytes = wcstombs(NULL, szString, 0);
//    setlocale(LC_CTYPE,oldlocale);
//	return ++iConvertBytes;
//}


//A_FORCEINLINE int ASys::GetSizeWCharFromUTF8( const char* szString )
//{
//    char* oldlocale = setlocale(LC_CTYPE,"en_US.UTF-8");
//    int iConvertChar = mbstowcs(NULL, szString, 0);
//    setlocale(LC_CTYPE,oldlocale);
//    return ++iConvertChar;
//}


#define A_CPPTEXT_TO_GB2312(x) A_UTF8_TO_GB2312(x)
#define A_GB2312_TO_CPPTEXT(x) A_GB2312_TO_UTF8(x)
#define A_CPPTEXT_TO_UTF8(x) (x)
#define A_UTF8_TO_CPPTEXT(x) (x)

#define ASTR_CPPTEXT_TO_GB2312(x) ASTR_UTF8_TO_GB2312(x)
#define ASTR_GB2312_TO_CPPTEXT(x) ASTR_GB2312_TO_UTF8(x)
#define ASTR_CPPTEXT_TO_UTF8(x) (x)
#define ASTR_UTF8_TO_CPPTEXT(x) (x)

#include <pthread.h>
template<typename T>
struct AngelicaThreadLocal
{
    AngelicaThreadLocal()
    {
        pthread_key_create(&key, AngelicaThreadLocal<T>::_ClearStorage);
    }
    AngelicaThreadLocal(const T& other) : AngelicaThreadLocal()
    {
        m_InitData = other;
    }
    AngelicaThreadLocal<T>& operator=(const T& other)
    {
        Data() = other;
        return *this;
    }
    operator const T&() const
    {
        return Data();
    }
    operator T&()
    {
        return Data();
    }
    
private:
    pthread_key_t key;
    T m_InitData;
    static void _ClearStorage(void* pData)
    {
        if(pData)
            delete (T*)pData;
    }
    T& Data() const
    {
        void* data = pthread_getspecific(key);
        if(!data)
        {
            data = new T(m_InitData);
            pthread_setspecific(key, data);
        }
        return *(T*)data;
    }
};
#define AThreadLocal(of_type) AngelicaThreadLocal<of_type>

#endif	//A_PLATFORM_XOS

#endif //_A_XOS_SYS_H_
