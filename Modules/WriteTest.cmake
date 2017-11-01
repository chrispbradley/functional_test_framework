
macro(write_target_test OUTPUT_FILENAME TEST_NAME TEST_TARGET TEST_ROOT TEST_EXPECTED_RESULTS TEST_TOLERANCE)
    set(TEST_CMD \$<TARGET_FILE:${TEST_TARGET}>)
    _write_test_to_file(${OUTPUT_FILENAME} ${TEST_NAME} ${TEST_CMD} ${TEST_ROOT} ${TEST_EXPECTED_RESULTS} ${TEST_TOLERANCE} ${ARGN})
endmacro()

macro(write_mp_target_test OUTPUT_FILENAME TEST_NAME TEST_TARGET TEST_NP TEST_ROOT TEST_EXPECTED_RESULTS TEST_TOLERANCE)
    set(TEST_CMD ${MPIEXEC}|-n|${TEST_NP}|\$<TARGET_FILE:${TEST_TARGET}>)
    _write_test_to_file(${OUTPUT_FILENAME} ${TEST_NAME} ${TEST_CMD} ${TEST_ROOT} ${TEST_EXPECTED_RESULTS} ${TEST_TOLERANCE} ${ARGN})
endmacro()

function(_write_test_to_file OUTPUT_FILENAME TEST_NAME TEST_CMD TEST_ROOT TEST_EXPECTED_RESULTS TEST_TOLERANCE)
    set(CONFIGURED_INPUTS)
    foreach(_arg ${ARGN})
        set(TEST_CMD "${TEST_CMD}|${_arg}")
        if (EXISTS "${TEST_ROOT}/${_arg}")
            list(APPEND CONFIGURED_INPUTS "configure_file(${TEST_ROOT}/${_arg} \${CMAKE_BINARY_DIR}/test_runs/${TEST_NAME}/${_arg})")
        endif ()
    endforeach()

    set(_TMP_OUTPUT "
# Create output directory
file(MAKE_DIRECTORY \${CMAKE_BINARY_DIR}/test_runs/${TEST_NAME})

# Configure input files (if required).
${CONFIGURED_INPUTS}

add_test(NAME test_${TEST_NAME}
   COMMAND ${CMAKE_COMMAND}
   -DTEST_NAME=${TEST_NAME}
   -DNDIFF_EXECUTABLE=${NDIFF_EXECUTABLE}
   -DTEST_CMD=${TEST_CMD}
   -DTEST_TOLERANCE=${TEST_TOLERANCE}
   -DEXPECTED_OUTPUT=${TEST_ROOT}/${TEST_EXPECTED_RESULTS}
   -DTEST_OUTPUT=\${CMAKE_BINARY_DIR}/test_runs/${TEST_NAME}
   -P ${TESTS_BASE_DIR}/run_test.cmake)

")

    file(APPEND ${OUTPUT_FILENAME} ${_TMP_OUTPUT})
endfunction()