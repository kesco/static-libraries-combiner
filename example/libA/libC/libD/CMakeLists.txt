cmake_minimum_required(VERSION 3.25)

project(StaticLibrariesCombiner-LibD)

set(LIBD_SRC libD.cpp)
set(LIBD_INCLUDES libD.hpp)
add_library(D STATIC ${LIBD_SRC} ${LIBD_INCLUDES})
target_include_directories(D PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})