#ifndef __OCTETS_H
#define __OCTETS_H

#include "AMemory.h"
#include <stdlib.h>
#include <algorithm>

namespace GNET
{

//	Memory allocations and free operations of GNET
inline void* GNET_Malloc(size_t size)
{
	return a_malloc(size);
}

inline void* GNET_Realloc(void* p, size_t size)
{
	return a_realloc(p, size);
}

inline void GNET_Free(void* p)
{
	return a_free(p);
}

class Octets
{
	void *base, *high;
	unsigned int cap;
public:
	Octets& reserve(unsigned int size)
	{
		if (size > cap)
		{
			for (size--,cap = 2; size >>= 1; cap <<= 1);
			size = (char*)high - (char*)base;
			base = GNET_Realloc(base, cap);
			high = (char*)base + size;
		}
		return *this;
	}
	Octets& replace(const void *data, unsigned int size)
	{
		reserve(size);
		memmove(base, data, size);
		high = (char*)base + size;
		return *this;
	}
	virtual ~Octets () { GNET_Free(base); }
	Octets () : base(0), high(0), cap(0) {}
	Octets (unsigned int size) : base(0), high(0), cap(0) { reserve(size); }
	Octets (const void *x, unsigned int size) : base(0), high(0), cap(0) { replace(x, size); }
	Octets (const void *x, const void *y) : base(0), high(0), cap(0) { replace(x, (char*)y - (char*)x); }
	Octets (const Octets &x) : base(0), high(0), cap(0) { if (x.size()) replace(x.begin(), x.size()); }
	Octets& operator = (const Octets&x) { return replace(x.begin(), x.size()); }
	bool operator == (const Octets &x) const { return x.size() == size() && !memcmp(x.base, base, size()); }
	bool operator != (const Octets &x) const { return ! operator == (x); }
	Octets& swap(Octets &x) { std::swap(base, x.base); std::swap(high, x.high); std::swap(cap, x.cap); return *this; }
	void* begin() { return base; }
	void* end()   { return high; }
	const void* begin() const { return base; }
	const void* end()   const { return high; }
	unsigned int size() const { return (char*)high - (char*)base; }
	unsigned int capacity() const { return cap; }
	Octets& clear() { high = base; return *this; }
	Octets& erase(void *x, void *y)
	{
		if (x != y)
		{
			memmove(x, y, (char*)high - (char*)y);
			high = (char*)high - ((char*)y - (char*)x);
		}	
		return *this;
	}
	Octets& insert(void *pos, const void *x, unsigned int size)
	{
		unsigned int off = (char*)pos - (char*)base;
		reserve((char*)high - (char*)base + size);
		if (pos)
		{
			pos = (char*)base + off;
			memmove((char*)pos + size, pos, (char*)high - (char*)pos);
			memmove(pos, x, size);
			high = (char*)high + size;
		} else {
			memmove(base, x, size);
			high = (char*)base + size;
		}
		return *this;
	}
	Octets& insert(void *pos, const void *x, const void *y) { insert(pos, x, (char*)y - (char*)x); return *this; }
	Octets& resize(unsigned int size) { reserve(size); high = (char*)base + size; return *this; }
};

};

#endif
