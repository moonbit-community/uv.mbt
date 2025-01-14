function(add_moon_executable target_name)
  add_moon_custom_target(${target_name})
  add_executable(
    ${target_name}
    ${CMAKE_CURRENT_BINARY_DIR}/target/native/release/build/${target_name}.c)
  install(TARGETS ${target_name} RUNTIME DESTINATION bin)
endfunction()

function(add_moon_custom_target target_name)
  add_custom_target(
    ${target_name}-moon
    COMMAND moon build --target=native --directory ${CMAKE_CURRENT_SOURCE_DIR}
            --target-dir ${CMAKE_CURRENT_BINARY_DIR}/target
    BYPRODUCTS
      ${CMAKE_CURRENT_BINARY_DIR}/target/native/release/build/${target_name}.c
      ${CMAKE_CURRENT_BINARY_DIR}/target/native/release/build/${target_name}.exe
  )
endfunction()
