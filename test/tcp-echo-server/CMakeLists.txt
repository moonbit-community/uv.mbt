add_custom_target(
  tcp-echo-server-moon
  COMMAND moon build --directory ${CMAKE_CURRENT_SOURCE_DIR} --target=native
  BYPRODUCTS
    ${CMAKE_CURRENT_SOURCE_DIR}/target/native/release/build/tcp-echo-server.c)

add_executable(
  tcp-echo-server
  ${CMAKE_CURRENT_SOURCE_DIR}/target/native/release/build/tcp-echo-server.c)
install(TARGETS tcp-echo-server RUNTIME DESTINATION "${CMAKE_SOURCE_DIR}/bin")
target_link_libraries(tcp-echo-server PRIVATE uv.mbt uv_a moonbit)
