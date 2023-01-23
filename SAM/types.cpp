#include "types.h"

#include "strnatcmp.h"

bool NaturalSort::operator() (const std::string& a, const std::string& b) const
{
	return strnatcasecmp(a.c_str(), b.c_str()) < 0;
}