cmake_minimum_required(VERSION 3.25)

project(StaticLibrariesCombiner-LibB)

set(LIBB_SRC libB.cpp)
set(LIBB_INCLUDES libB.hpp)
add_library(B STATIC ${LIBB_SRC} ${LIBB_INCLUDES})
target_include_directories(B PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})