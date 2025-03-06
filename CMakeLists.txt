cmake_minimum_required(VERSION 3.18)
project(uv.mbt)

add_subdirectory(lib)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE on)

include(cmake/moonbit.cmake)

setup_moonbit_module(.)

add_library(uv.mbt STATIC src/uv.c)
target_link_libraries(uv.mbt PRIVATE uv_a c.mbt::c.mbt moonbit)

install(TARGETS uv.mbt DESTINATION ${CMAKE_SOURCE_DIR}/lib)

add_moon_module(test)
