#include <useful.hpp>

#include <locale>

std::string capitalize(std::string in)
{
	const auto &facet = std::use_facet<std::ctype<char>>(std::locale::classic());
	for (auto &c : in) {
		c = facet.toupper(c);
	}
	return in;
}
