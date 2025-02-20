cmake_minimum_required(VERSION 3.25)

project(StaticLibrariesCombiner-LibA)

add_subdirectory(libB)
add_subdirectory(libC)

set(LIBA_SRC libA.cpp)
set(LIBA_INCLUDES libA.hpp)
add_library(A STATIC ${LIBA_SRC} ${LIBA_INCLUDES})
target_include_directories(A PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(A PRIVATE B C)

combine_static_libraries(A A_ALL)