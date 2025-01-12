add_custom_target(uvcat-moon
  COMMAND moon build --directory ${CMAKE_CURRENT_SOURCE_DIR} --target=native
  BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/target/native/release/build/uvcat.c)

add_executable(
  uvcat
  ${CMAKE_CURRENT_SOURCE_DIR}/target/native/release/build/uvcat.c)
install(TARGETS uvcat RUNTIME DESTINATION "${CMAKE_SOURCE_DIR}/bin")
target_link_libraries(uvcat PRIVATE uv.mbt uv_a moonbit)
