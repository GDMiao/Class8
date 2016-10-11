//-------------------------------------------------------------------------------------------------
//FileName:ASys.h
//Created by liyi 2012,11,22
//-------------------------------------------------------------------------------------------------
#ifndef _A_SYS_H_
#define _A_SYS_H_

#include "ATypes.h"
#include "AArray.h"
#include "AString.h"
#include "AMemBase.h"
#include "vector.h"

//	Device family
enum
{
	ADEV_FAMILY_MASK		= 0xff000000,
	ADEV_FAMILY_UNKNOWN		= 0x00000000,
	ADEV_FAMILY_PC			= 0x01000000,
	ADEV_FAMILY_IOS			= 0x02000000,
	ADEV_FAMILY_ANDROID		= 0x04000000,
    ADEV_FAMILY_WINRT       = 0x08000000,
};

//	Device type
enum
{
	ADEV_TYPE_MASK			= 0x00ffffff,
	ADEV_TYPE_UNKNOWN		= 0,

	ADEV_TYPE_PC			= 0001,

	//	Device type			
	ADEV_TYPE_IPHONE1		= 1000,
	ADEV_TYPE_IPHONE3		= 1001,
	ADEV_TYPE_IPHONE4		= 1002,
	ADEV_TYPE_IPHONE4S		= 1003,
	ADEV_TYPE_IPHONE5		= 1004,
	ADEV_TYPE_IPHONE5S		= 1005,

	ADEV_TYPE_IPAD			= 2000,
	ADEV_TYPE_IPAD2			= 2001,
	ADEV_TYPE_IPAD3			= 2002,
	ADEV_TYPE_IPAD4			= 2003,
	ADEV_TYPE_IPADAIR		= 2004,

	ADEV_TYPE_IPAD_MINI		= 3000,
	ADEV_TYPE_IPAD_MINI2	= 3001,

	ADEV_TYPE_ITOUCH1		= 4000,
	ADEV_TYPE_ITOUCH2		= 4001,
	ADEV_TYPE_ITOUCH3		= 4002,
	ADEV_TYPE_ITOUCH4		= 4003,
	ADEV_TYPE_ITOUCH5		= 4004,

	ADEV_TYPE_ANDROID		= 5000,

    ADEV_TYPE_WINRT         = 6000,
};

typedef void (*FDebugOutput)(const char*);
typedef auint32 (*FMessageBox)(const char* pTextKey, const char* pOptionKey, auint32 uType, auint32 timeout);
typedef void (*FOpenEmbeddedUrl)(const char*);


class ASys : public AMemBase
{
public:
	//文件系统
	//判断文件或文件夹是否存在
	A_FORCEINLINE static bool IsFileExist(const char* szFileName);
	//删除文件
	A_FORCEINLINE static bool DeleteFile(const char* szFile);
    A_FORCEINLINE static bool CopyFile(const char* src,const char* des,bool bFailIfExists);
    A_FORCEINLINE static bool MoveFile(const char* src,const char* des);
	//删除目录及其内部的所有文件
	static bool DeleteDirectory(const char* szDir);
	//创建目录，不会递归创建，若该目录的上级
	A_FORCEINLINE static bool CreateDirectory(const char* szDir);

	//遍历目录, 输入文件夹结尾没有斜杠，返回的文件名中不包含路径
	static bool GetFilesInDirectory(abase::vector<AString>& arrFiles, const char* szDir);
	//获取工作目录的绝对路径
	static bool GetBaseDirectory(char* szBaseDir);
	//获取可以写入文档的目录，ios 上并不是所有目录下都能写文件的 add by linzihan
	static bool GetDocumentsDirectory(char* szDocumentDir);
	//获取文件改动的时间戳
	A_FORCEINLINE static auint32 GetFileTimeStamp(const char* szFileName);
	A_FORCEINLINE static auint32 GetFileSize(const char* szFileName);
    //S_IREAD,S_IWRITE,S_IRWXU
	A_FORCEINLINE static auint32 ChangeFileAttributes(const char* szFileName, int mode);

    //	Device operations
	//	Get device, device id = (ADEV_FAMILY_xxx << 24) | ADEV_TYPE_xxx
	//	pstr: if not NULL, used to receive device decription text.
    static auint32 GetDeviceID(AString* pstr);
    static void SetDeviceToken(abyte* devicetoken, auint32 length);
    static auint32 GetDeviceToken(abyte* devicetoken);
    static bool    GetVersion(AString& strVersion);
    static bool    GetDeviceIdentifiler(AString& str);
    static void    OpenUrlWithEmbedded(const char* url);
    static void    SetOpenUrlWithEmbeddedFunction(FOpenEmbeddedUrl pFun);


    static bool IsJailBreak();
    static bool IsHaveWifi();
    static bool IsHave3G_2G();
	static auint64 GetTotalPhysMemSize();	//	Get all physical memory size in bytes
	static auint64 GetFreeDiskSpaceSize();  //Get free DiskSpace size in bytes 
	//设置user图形分辨率0.5 - 1.0
	static afloat32 GetUserResolutionScale();
    static void SetUserResolutionScale(afloat32 scale);
    //mainscreen.height * DPI / DEFAULTHEIGHT(768)
    static afloat32 GetDeviceScreenScale();
	// For UI.
	static auint32 GetUnscaledWidth();
	static auint32 GetUnscaledHeight();
	static afloat32 GetWindowScale();
    
    //获取DPI scale 标准 dip = 163 sacle = 1, retain = 326 scale = 2 
    static afloat32 GetDeviceDpiScale();
	static auint32 GetOriginalWindowWidth();
	static auint32 GetOriginalWindowHeight();
    static abool IsRetinaScreen();

	//如下一组接口仅用于window下的设备模拟
	static void SetDeviceDpiScale(afloat32 scale);
	static void SetOriginalWindowWidth(auint32 width);
	static void SetOriginalWindowHeight(auint32 height);

	//	Get Milli-second
	static auint32 GetMilliSecond();
	//	Get micro-second
	static auint64 GetMicroSecond();
	//	Get seconds elapsed since midnight (00:00:00), January 1, 1970, UTC
	static auint64 GetTimeSince1970();
	//	Make ATIME structure from time value returned by GetTimeSince1970()
	static void GMTime(auint64 _time, ATIME& atm);
	static void LocalTime(auint64 _time, ATIME& atm);
	//	Make time value from ATIME structure
	//	wday in atm are not used.
	static auint64 TimeGM(const ATIME& atm);	//	Note: this function isn't implemented now and always return 0.
	static auint64 TimeLocal(const ATIME& atm);
	//	Get current time
	//	piMilliSec: can be NULL, used to get millisecond. Not every system support this, and on those
	//		systems -1 will be returned.
	static void GetCurGMTime(ATIME& atm, auint32* piMilliSec);
	static void GetCurLocalTime(ATIME& atm, auint32* piMilliSec);

	//让当前线程睡眠
	A_FORCEINLINE static void Sleep(unsigned int nMilliSecond);
	//输出信息到调试窗口
	static void OutputDebug(const char* szDebugInfo);
	static void SetOutputDebugFunction(FDebugOutput pFun);

	static void SetMessageBoxFunction(FMessageBox pFun);
	//	Output message to a popup message box
	//	pTextKey: utf-8 encoding string
	//	pOptionKey: utf-8 encoding string
	static auint32 MessageBox(const char* pTextKey, const char* pOptionKey, auint32 uType, auint32 timeout = 10000);
	//	Output message to a popup message box
	//	pTextKey: C-text encoding string
	//	pOptionKey: C-text encoding string
	static auint32 MessageBox_CText(const char* pTextKey, const char* pOptionKey, auint32 uType, auint32 timeout = 10000);
    
    static abool CopyDataToPasteboard(const char* pData);
    static abool GetPastebordData(AString& data);

	// 字符编码转换函数。
	// 字符编码转换函数 Part I: 单个字符UTF32 <-> UTF8，自己实现的。
	struct UTF8_EncodedChar
	{
		UTF8_EncodedChar()
		{
			memset(bytes, 0, 8);
		}
		int GetByteCount()
		{
			return len > 6 ? 6 : len;
		}
		union
		{
			achar bytes[8];
			struct
			{
				achar byte0;
				achar byte1;
				achar byte2;
				achar byte3;
				achar byte4;
				achar byte5;
				achar byte6; // always null
				auint8 len;
			};
		};
	};
	static aint32 ParseUnicodeFromUTF8Str(const achar* szUTF8, aint32* pnAdvancedInUtf8Str = 0, auint32 nUtf8StrMaxLen = A_MAX_UINT32);
	static UTF8_EncodedChar EncodeUTF8(aint32 ch);
	static aint32 ParseUnicodeFromUTF8StrEx(const achar* szUTF8, aint32 iParsePos = 0, aint32* piParsedHeadPos = 0, aint32* pnUtf8ByteCounts = 0, auint32 nUtf8StrMaxLen = A_MAX_UINT32);
	// 字符编码转换函数 Part II: UTF16LE <-> UTF8，自己实现的。
	static aint32 UTF16Len(const auint16* sz16); // returns the auint16-char count NOT including \0.
	static aint32 UTF8ToUTF16LE(auint16* sz16, const achar* sz8); // returns the auint16-char count including \0 of the converted string.
	static aint32 UTF16LEToUTF8(achar* sz8, const auint16* sz16); // returns the byte count including \0 of the converted string.
	// 字符编码转换函数 Part III: 平台相关。下面的函数在不同系统上采用了不同的实现。
	// iSrcLen: if < 0, whole szSrc including ending character ('\0') will be converted.
	static aint32 CPPTextToGB2312(achar* szDest, const char* szSrc, int iSrcLen, int nDestBufferMaxSize); // returns the byte count including \0 of the converted string.
	static aint32 GB2312ToCPPText(achar* szDest, const char* szSrc, int iSrcLen, int nDestBufferMaxSize); // returns the byte count including \0 of the converted string.
	// 字符编码转换函数 Part IV: 引擎常用编码转换。
	// iSrcLen: if < 0, whole szSrc including ending character ('\0') will be converted.
	static aint32 GB2312ToUTF8(achar* szDest, const char* szSrc, int iSrcLen, int nDestBufferMaxSize); // returns the byte count including \0 of the converted string.
	static aint32 UTF8ToGB2312(achar* szDest, const char* szSrc, int iSrcLen, int nDestBufferMaxSize); // returns the byte count including \0 of the converted string.
	// From GB2132 to system's file name encoding format
	static aint32 GB2132ToFileNameEncoding(achar* szDest, const achar* szSrc, aint32 nDestBufferMaxSize);
	//	Windows system only
#ifdef A_PLATFORM_WIN_DESKTOP
	A_FORCEINLINE static aint32 WCharLen(const wchar_t* szWStr) { return (aint32)wcslen(szWStr); }
	static aint32 WCharToChar(char* szDest, const wchar_t* szSrc, int nDestBufferMaxSize); // returns the byte count including \0 of the converted string.
	static aint32 CharToWChar(wchar_t* szDest, const char* szSrc, int nDestBufferMaxSize); // returns the wchar_t count including \0 of the converted string.
	static aint32 WCharToUTF8(char* szDest, const wchar_t* szSrc, int nDestBufferMaxSize); // returns the byte count including \0 of the converted string.
	static aint32 UTF8ToWChar(wchar_t* szDest, const char* szSrc, int nDestBufferMaxSize); // returns the wchar_t count including \0 of the converted string.
#endif	//	A_PLATFORM_WIN_DESKTOP
	// 字符编码转换函数。^end^

	static int AccessFile(const char* path, int mode);
	static int SetFileSize(int fd, aint32 size );
	static aint64 AtoInt64(const char* szString);
	static int StrCmpNoCase(const char* sz1, const char* sz2);
	static char* Strlwr( char* str );
	static char* Strupr(char* str);
	static int  Fileno( FILE * _File);
	static bool IsNan(float f);

	//FIXME!! 内存调试函数。这个几个函数与AMemory类耦合太紧密，需要重构
	//输出函数的调用堆栈到DebugOutput
	static void ExportSymbolInfo(void* ptr);
	//读入Address的符号文件
	static void LoadAddressSymbol(void* pAddress);
	//输出所有已经记录的函数调用栈
	static void DumpAllAddressSymbol(FILE* pAddiInfoFile);



	//For thread
	static auptrint GetCurrentThreadID();

	//结束当前进程
	static void Exit();
};

#if A_PLATFORM_WIN_DESKTOP
#include "AWinSys.h"
#elif A_PLATFORM_ANDROID
#include "AAndroidSys.h"
#elif A_PLATFORM_LINUX
//
#elif A_PLATFORM_XOS
#include "AXOSSys.h"
#elif A_PLATFORM_WINRT
#include "AWinRTSys.h"
#endif

// macros below is defined in the "AWinSys.h" or "AXOSSys.h" or ...
// #define a_snprintf _snprintf
// #define a_isnan _isnan

// by Silas, 2013/06/26, the Thread Local Storage macro is defined in the "AWinSys.h" or "AXOSSys.h" or ...
// on Windows, it is like this:
// #define AThreadLocal(of_type) __declspec(thread) of_type

// ## Classes for string convert macros.
class BaseStackStringConverter
{
protected:
	
	BaseStackStringConverter(void* pAllocaBuffer)
	{
		nBufferLen = nBufferLenTemp;
		szBuffer = pAllocaBuffer;
	}

public:
	operator achar*() const { return (achar*)szBuffer; }
	operator auchar*() const { return (auchar*)szBuffer; }
	operator wchar_t*() const { return (wchar_t*)szBuffer; }
	operator void*() const { return szBuffer; }

	static AThreadLocal(size_t) nBufferLenTemp;
	static AThreadLocal(const void*) szConvertSrcTemp;
	static AThreadLocal(size_t) nSrcLenTemp;

	static size_t Prepare(const AString& rStr)
	{
		szConvertSrcTemp = (const char*)rStr;
		nSrcLenTemp = rStr.GetLength();
		return nSrcLenTemp;
	}

	static size_t Prepare(const BaseStackStringConverter& rStr)
	{
		szConvertSrcTemp = (const char*)rStr;
		nSrcLenTemp = rStr.GetLength();
		return nSrcLenTemp;
	}

	static size_t Prepare(const char* rStr)
	{
		szConvertSrcTemp = rStr;
		nSrcLenTemp = strlen(rStr);
		return nSrcLenTemp;
	}
	
	static size_t PrepareUTF16_UTF8(const auint16* rStr)
	{
		szConvertSrcTemp = (const char*)rStr;
		nSrcLenTemp = ASys::UTF16Len(rStr);
		return nSrcLenTemp * 4 + 1;
	}
	
	static size_t PrepareUTF8_UTF16(const char* rStr)
	{
		szConvertSrcTemp = rStr;
		nSrcLenTemp = strlen(rStr);
		return nSrcLenTemp * 2 + 2;
	}

	size_t GetLength() const { return nBufferLen; }

protected:

	size_t nBufferLen;
	void* szBuffer;
};

class UTF8ToGBConverter : public BaseStackStringConverter
{
public:
	UTF8ToGBConverter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::UTF8ToGB2312((char*)szBuffer, (const char*)szSrc, (int)nSrcLenTemp+1, (int)nBufferLen); }
};

class GBToUTF8Converter : public BaseStackStringConverter
{
public:
	GBToUTF8Converter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::GB2312ToUTF8((char*)szBuffer, (const char*)szSrc, (int)nSrcLenTemp+1, (int)nBufferLen); }
};

class CTextToGBConverter : public BaseStackStringConverter
{
public:
	CTextToGBConverter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::CPPTextToGB2312((char*)szBuffer, (const char*)szSrc, (int)nSrcLenTemp+1, (int)nBufferLen); }
};

class GBToCTextConverter : public BaseStackStringConverter
{
public:
	GBToCTextConverter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::GB2312ToCPPText((char*)szBuffer, (const char*)szSrc, (int)nSrcLenTemp+1, (int)nBufferLen); }
};

class UTF16ToUTF8Converter : public BaseStackStringConverter
{
public:
	UTF16ToUTF8Converter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::UTF16LEToUTF8((char*)szBuffer, (const auint16*)szSrc); }
};

class UTF8ToUTF16Converter : public BaseStackStringConverter
{
public:
	UTF8ToUTF16Converter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::UTF8ToUTF16LE((auint16*)szBuffer, (const achar*)szSrc); }
};
// =# Classes for string convert macros. ^above^

// ## Helper Macro To Convert String To Different Encodings.
// The return values of these macros should NOT be released.

// Convert from UTF-8 to GB2312/GBK. Returned pointer should NOT be released.
#define A_UTF8_TO_GB2312(x) (achar*)UTF8ToGBConverter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::Prepare(x) * 2 + 1))
// Convert to UTF-8 from GB2312/GBK. Returned pointer should NOT be released.
#define A_GB2312_TO_UTF8(x) (achar*)GBToUTF8Converter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::Prepare(x) * 2 + 1))

// Convert from UTF-16 to UTF-8. Returned pointer should NOT be released.
#define A_UTF16_TO_UTF8(x) (achar*)UTF16ToUTF8Converter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::PrepareUTF16_UTF8((const auint16*)(x))))
// Convert from UTF-8 to UTF-16. Returned pointer should NOT be released.
#define A_UTF8_TO_UTF16(x) (auint16*)(void*)UTF8ToUTF16Converter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::PrepareUTF8_UTF16(x)))

// ## Helper Macro To Convert String To Different Encodings. - Using AString as macro param.
// The return values of these macros should NOT be released.
// Convert from UTF-8 to GB2312/GBK. Returned pointer should NOT be released.
#define ASTR_UTF8_TO_GB2312(x) UTF8ToGBConverter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::Prepare(x) * 2 + 1))
// Convert to UTF-8 from GB2312/GBK. Returned pointer should NOT be released.
#define ASTR_GB2312_TO_UTF8(x) GBToUTF8Converter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::Prepare(x) * 2 + 1))

// Convert from UTF-16 to UTF-8. Returned pointer should NOT be released.
#define ASTR_UTF16_TO_UTF8(x) UTF16ToUTF8Converter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = ASys::UTF16LEToUTF8(0, (const auint16*)(const void*)(BaseStackStringConverter::szConvertSrcTemp = (x)))))
// Convert from UTF-8 to UTF-16. Returned pointer should NOT be released.
#define ASTR_UTF8_TO_UTF16(x) (auint16*)(void*)UTF8ToUTF16Converter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::Prepare(x) * 2 + 2))
// =# Helper Macro To Convert String To Different Encodings. ^above^

////////////////////////////////////////////////////////////////////////////////////////////
//	wchar_t operations, only for windows system
////////////////////////////////////////////////////////////////////////////////////////////

#ifdef A_PLATFORM_WIN_DESKTOP

class WCharToUTF8Converter : public BaseStackStringConverter
{
public:
	WCharToUTF8Converter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::WCharToUTF8((char*)szBuffer, (const wchar_t*)szSrc, (int)nBufferLen); }
};

class UTF8ToWCharConverter : public BaseStackStringConverter
{
public:
	UTF8ToWCharConverter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::UTF8ToWChar((wchar_t*)szBuffer, (const char*)szSrc, (int)nBufferLen); }
};

class WCharToCharConverter : public BaseStackStringConverter
{
public:
	WCharToCharConverter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::WCharToChar((char*)szBuffer, (const wchar_t*)szSrc, (int)nBufferLen); }
};

class CharToWCharConverter : public BaseStackStringConverter
{
public:
	CharToWCharConverter(void* pAllocaBuffer) : BaseStackStringConverter(pAllocaBuffer) { Convert(szConvertSrcTemp); }
protected:
	void Convert(const void* szSrc) { nBufferLen = ASys::CharToWChar((wchar_t*)szBuffer, (const char*)szSrc, (int)nBufferLen); }
};

// Convert a wide string to UTF-8. Returned pointer should NOT be released.
#define A_WCHAR_TO_UTF8(x) (achar*)WCharToUTF8Converter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = ASys::WCharToUTF8(0, (const wchar_t*)(const void*)(BaseStackStringConverter::szConvertSrcTemp = (x)), 0)))
// Convert from UTF-8 back to wide string. Returned pointer should NOT be released.
#define A_UTF8_TO_WCHAR(x) (wchar_t*)UTF8ToWCharConverter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = ASys::UTF8ToWChar(0, (const char*)(const void*)(BaseStackStringConverter::szConvertSrcTemp = (x)), 0) * sizeof(wchar_t)))
// Convert a wide string to current code-page. Returned pointer should NOT be released.
#define A_WCHAR_TO_CHAR(x) (achar*)WCharToCharConverter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = ASys::WCharToChar(0, (const wchar_t*)(const void*)(BaseStackStringConverter::szConvertSrcTemp = (x)), 0)))
// Convert from current code-page back to wide string. Returned pointer should NOT be released.
#define A_CHAR_TO_WCHAR(x) (wchar_t*)CharToWCharConverter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = ASys::CharToWChar(0, (const char*)(const void*)(BaseStackStringConverter::szConvertSrcTemp = (x)), 0) * sizeof(wchar_t)))
// Convert a wide string to UTF-8. Returned pointer should NOT be released.
#define ASTR_WCHAR_TO_UTF8(x) WCharToUTF8Converter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = ASys::WCharToUTF8(0, (const wchar_t*)(const void*)(BaseStackStringConverter::szConvertSrcTemp = (x)), 0)))
// Convert from UTF-8 back to wide string. Returned pointer should NOT be released.
#define ASTR_UTF8_TO_WCHAR(x) UTF8ToWCharConverter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::Prepare(x) * sizeof(wchar_t) + sizeof(wchar_t)))
// Convert a wide string to current code-page. Returned pointer should NOT be released.
#define ASTR_WCHAR_TO_CHAR(x) WCharToCharConverter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = ASys::WCharToChar(0, (const wchar_t*)(const void*)(BaseStackStringConverter::szConvertSrcTemp = (x)), 0)))
// Convert from current code-page back to wide string. Returned pointer should NOT be released.
#define ASTR_CHAR_TO_WCHAR(x) CharToWCharConverter(AAlloca16(BaseStackStringConverter::nBufferLenTemp = BaseStackStringConverter::Prepare(x) * sizeof(wchar_t) + sizeof(wchar_t)))


#endif	//	A_PLATFORM_WIN_DESKTOP






#endif //_A_SYS_H_

