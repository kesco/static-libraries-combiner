cmake_minimum_required(VERSION 3.25)

project(StaticLibrariesCombiner-LibC)

add_subdirectory(libD)

set(LIBC_SRC libC.cpp)
set(LIBC_INCLUDES libC.hpp)
add_library(C STATIC ${LIBC_SRC} ${LIBC_INCLUDES})
target_link_libraries(C PRIVATE D)
target_include_directories(C PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})