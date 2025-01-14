cmake_minimum_required(VERSION 3.18)
project(uv.mbt)

add_subdirectory(lib)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE on)

include(CMakePrintHelpers)
set(MOON_HOME "$ENV{MOON_HOME}")
cmake_print_variables(MOON_HOME)

include(cmake/Moon.cmake)

add_library(moonbit INTERFACE)
target_include_directories(moonbit INTERFACE "${MOON_HOME}/include")

add_library(uv.mbt STATIC src/uv.c)
target_link_libraries(uv.mbt PRIVATE uv_a moonbit)

install(TARGETS uv.mbt DESTINATION ${CMAKE_SOURCE_DIR}/lib)

add_subdirectory(test)
