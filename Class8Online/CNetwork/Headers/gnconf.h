#ifndef __CONF_H
#define __CONF_H

#pragma warning (disable:4786)
#include "NetSys.h"
//#include <io.h> //FIX ME by linzihan
#include <map>
#include <string>
#include <fstream>
#include <sys/stat.h>

#include "gnthread.h"

#ifdef R_OK
#undef R_OK
#endif
#define R_OK 04

namespace GNET
{

using std::string;
class Conf
{
public:
	typedef string section_type;
	typedef string key_type;
	typedef string value_type;
	static void Release()
	{
		A_SAFERELEASE_INTERFACE(Conf::m_pLocker); 
	}
private:
	time_t mtime;
	struct stringcasecmp
	{
		bool operator() (const string &x, const string &y) const { return ASys::StrCmpNoCase(x.c_str(), y.c_str()) < 0; }
	};
	static Conf instance;
	typedef std::map<key_type, value_type, stringcasecmp> section_hash;
	typedef std::map<section_type, section_hash, stringcasecmp> conf_hash;
	conf_hash confhash;
	string filename;
    //FIX ME by linzihan
	//static Thread::RWLock locker;
    static ASysThreadMutex* m_pLocker;
    
	Conf() : mtime(0) {
        if(m_pLocker == NULL)
        {
            m_pLocker = AThreadFactory::CreateThreadMutex();
        }
    }

	~Conf()
	{
	}

	void reload()
	{
		//struct stat st;
        //FIX ME by linzihan
		//Thread::RWLock::WRScoped l(locker);
        ACSWrapper l(m_pLocker);
        //add by linzihan
		for ( ; mtime != ASys::GetFileTimeStamp(filename.c_str()); mtime = ASys::GetFileTimeStamp(filename.c_str()))
		{
			//mtime = st.st_mtime;
			std::ifstream ifs(filename.c_str());
			string line;
			section_type section;
			section_hash sechash;
			if (!confhash.empty()) confhash.clear();
			while (std::getline(ifs, line))
			{
				const char c = line[0];
				if (c == '#' || c == ';') continue;
				if (c == '[')
				{
					string::size_type start = line.find_first_not_of(" \t", 1);
					if (start == string::npos) continue;
					string::size_type end   = line.find_first_of(" \t]", start);
					if (end   == string::npos) continue;
					if (!section.empty()) confhash[section] = sechash;
					section = section_type(line, start, end - start);
					sechash.clear();
				} else {
					string::size_type key_start = line.find_first_not_of(" \t");
					if (key_start == string::npos) continue;
					string::size_type key_end   = line.find_first_of(" \t=", key_start);
					if (key_start == string::npos) continue;
					string::size_type val_start = line.find_first_of("=", key_end);
					if (key_start == string::npos) continue;
					val_start = line.find_first_not_of(" \t", val_start + 1);
					if (key_start == string::npos) continue;
					sechash[key_type(line, key_start, key_end - key_start)] = value_type(line, val_start);
				}
			}
			if (!section.empty()) confhash[section] = sechash;
		}
	}
public:
	value_type find(const section_type &section, const key_type &key)
	{
        //FIX ME by linzihan
		//Thread::RWLock::RDScoped l(locker);
        ACSWrapper l(m_pLocker);
		return confhash[section][key];
	}
	static Conf *GetInstance(const char *file = NULL)
	{
		if (file && ASys::AccessFile(file, R_OK) == 0)
		{
            
			instance.filename = file;
			instance.reload();
		}
		return &instance; 
	}
};	

};

#endif

