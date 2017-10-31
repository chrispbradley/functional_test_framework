
macro(write_target_test TEST_NAME TEST_TARGET TEST_EXPECTED_RESULTS _OUTPUT)

    set(_TMP_OUTPUT "

# Create output directory
file(MAKE_DIRECTORY \${CMAKE_BINARY_DIR}/test_runs/${TEST_NAME})

add_test(NAME test_${TEST_NAME}
   COMMAND ${CMAKE_COMMAND}
   -DTEST_NAME=${TEST_NAME}
   -DNDIFF_EXECUTABLE=${NDIFF_EXECUTABLE}
   -Dtest_cmd=\$<TARGET_FILE:${TEST_TARGET}>
   -Dexpected_output=${TEST_BASE_DIR}/${TEST_NAME}/${TEST_EXPECTED_RESULTS}
   -Dtest_output=\${CMAKE_BINARY_DIR}/test_runs/${TEST_NAME}
   -P ${TEST_BASE_DIR}/run_test.cmake)
")

    set(${_OUTPUT} ${_TMP_OUTPUT})
endmacro()
