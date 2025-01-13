add_custom_target(
  idle-basic-moon
  COMMAND moon build --directory ${CMAKE_CURRENT_SOURCE_DIR} --target=native
  BYPRODUCTS
    ${CMAKE_CURRENT_SOURCE_DIR}/target/native/release/build/idle-basic.c)

add_executable(
  idle-basic
  ${CMAKE_CURRENT_SOURCE_DIR}/target/native/release/build/idle-basic.c)
install(TARGETS idle-basic RUNTIME DESTINATION "${CMAKE_SOURCE_DIR}/bin")
target_link_libraries(idle-basic PRIVATE uv.mbt uv_a moonbit)
