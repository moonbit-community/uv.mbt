cmake_minimum_required(VERSION 3.19)
project(uv.mbt LANGUAGES C)

set(c.mbt_DIR ${CMAKE_SOURCE_DIR}/../c.mbt/install/lib/cmake/c.mbt)
find_package(c.mbt REQUIRED)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE on)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -fsanitize=address -Wmissing-field-initializers")

include(cmake/moonbit.cmake)

setup_moonbit_module(.)

add_subdirectory(src/uv)

add_library(uv.mbt::moonbit ALIAS moonbit)
add_library(uv.mbt STATIC src/uv.c)
add_library(uv.mbt::uv.mbt ALIAS uv.mbt)
target_link_libraries(uv.mbt PRIVATE uv_a c.mbt::c.mbt moonbit)

include(GNUInstallDirs)
install(
  TARGETS uv.mbt moonbit uv_a
  EXPORT uv.mbt-targets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(
  EXPORT uv.mbt-targets
  NAMESPACE uv.mbt::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/uv.mbt
  FILE uv.mbt-targets.cmake)
export(EXPORT uv.mbt-targets FILE ${CMAKE_CURRENT_BINARY_DIR}/uv.mbt-targets.cmake)
include(CMakePackageConfigHelpers)
configure_package_config_file(
  ${CMAKE_CURRENT_LIST_DIR}/cmake/config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/uv.mbt-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/uv.mbt
)
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/uv.mbt-config.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/uv.mbt
)

option(UV_MBT_BUILD_TESTS "Build tests" OFF)

if(UV_MBT_BUILD_TESTS)
  add_moon_module(test)
endif()
