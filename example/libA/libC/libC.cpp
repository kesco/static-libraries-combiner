//
// Created by bringwin808 on 24-7-12.
//

#include "libC.hpp"

#include <cstdio>

#include "libD.hpp"

namespace libC {

void PrintCLib() {
  std::printf("LibC Method Called.\n");
  libD::PrintDLib();
}

}
