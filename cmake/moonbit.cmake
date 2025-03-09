include(CMakePrintHelpers)
set(MOON_HOME "$ENV{MOON_HOME}")

add_library(moonbit STATIC "${MOON_HOME}/lib/runtime.c")
target_include_directories(moonbit PUBLIC "${MOON_HOME}/include")

function(setup_moonbit_module directory)
  file(READ ${CMAKE_CURRENT_SOURCE_DIR}/${directory}/moon.mod.json MOON_MOD_JSON)
  string(JSON
    MOON_CURRENT_SOURCE_DIR
    ERROR_VARIABLE MOON_CURRENT_SOURCE_DIR_ERROR
    GET ${MOON_MOD_JSON} source)
  if(NOT MOON_CURRENT_SOURCE_DIR_ERROR STREQUAL NOTFOUND)
    set(MOON_CURRENT_SOURCE_DIR ${directory})
  endif()
  string(JSON
    MOON_CURRENT_TARGET_DIR
    ERROR_VARIABLE MOON_CURRENT_TARGET_DIR_ERROR
    GET ${MOON_MOD_JSON} source)
  if(NOT MOON_CURRENT_TARGET_DIR_ERROR STREQUAL NOTFOUND)
    set(MOON_CURRENT_TARGET_DIR ${MOON_CURRENT_SOURCE_DIR}/target)
  endif()
  set(MOON_CURRENT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${MOON_CURRENT_SOURCE_DIR} PARENT_SCOPE)
  set(MOON_CURRENT_TARGET_DIR ${CMAKE_CURRENT_BINARY_DIR}/${MOON_CURRENT_TARGET_DIR} PARENT_SCOPE)
endfunction()

function(add_moon_executable target_name)
  file(RELATIVE_PATH MOON_CURRENT_PACKAGE ${MOON_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
  add_moon_custom_target_native(${target_name})
  add_executable(
    ${target_name}
    ${MOON_CURRENT_TARGET_DIR}/native/release/build/${MOON_CURRENT_PACKAGE}/${target_name}.c)
  target_link_libraries(${target_name} PRIVATE moonbit)
endfunction()

function(add_moon_custom_target_native target_name)
  add_custom_target(
    ${target_name}-moon
    COMMAND moon build --target=native --directory ${MOON_CURRENT_SOURCE_DIR}
      --target-dir ${MOON_CURRENT_TARGET_DIR} || true
    BYPRODUCTS
      ${MOON_CURRENT_TARGET_DIR}/native/release/build/${MOON_CURRENT_PACKAGE}/${target_name}.c
      ${MOON_CURRENT_TARGET_DIR}/native/release/build/${MOON_CURRENT_PACKAGE}/${target_name}.exe)
endfunction()

function(add_moon_custom_target_wasm target_name)
  add_custom_target(
    ${target_name}-moon
    COMMAND moon build --target=wasm --directory ${MOON_CURRENT_SOURCE_DIR}
      --target-dir ${MOON_CURRENT_TARGET_DIR} || true
    BYPRODUCTS
      ${MOON_CURRENT_TARGET_DIR}/wasm/release/build/${MOON_CURRENT_PACKAGE}/${target_name}.wasm)
endfunction()

function(add_moon_module directory)
  setup_moonbit_module(${directory})
  add_subdirectory(${directory})
endfunction()

function(add_moon_package directory)
  add_subdirectory(${directory})
endfunction()
