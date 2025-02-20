#include "libA.hpp"

#include <cstdio>

#include "libB.hpp"
#include "libC.hpp"

namespace libA {

void PrintALib() {
  std::printf("LibA Method Called.\n");
  libB::PrintBLib();
  libC::PrintCLib();
}

}