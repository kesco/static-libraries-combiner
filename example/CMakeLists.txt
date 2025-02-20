cmake_minimum_required(VERSION 3.25)

project(StaticLibrariesCombiner)

include(${CMAKE_SOURCE_DIR}/../cmake/combiner.cmake)

add_subdirectory(libA)

set(COMBINER_SRC main.cpp)
add_executable(demo ${COMBINER_SRC})
target_link_libraries(demo A)