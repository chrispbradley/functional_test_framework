# some argument checking:
# TEST_CMD is the command to run with all its arguments.
if (NOT TEST_CMD)
    message( FATAL_ERROR "Variable TEST_CMD not defined" )
endif ()
# EXPECTED_OUTPUT contains the name of the "expected" output file
#if (NOT EXPECTED_OUTPUT)
#    message( FATAL_ERROR "Variable EXPECTED_OUTPUT not defined" )
#endif ()
# TEST_OUTPUT contains the name of the directory the executable will be run from.
if (NOT TEST_OUTPUT)
    message( FATAL_ERROR "Variable TEST_OUTPUT not defined" )
endif ()

if (DEFINED EXPECTED_OUTPUT)
    set(EXPECTED_OUTPUT_DEFINED TRUE)
else ()
    set(EXPECTED_OUTPUT_DEFINED FALSE)
endif ()
if (IS_DIRECTORY "${EXPECTED_OUTPUT}")
    set(_NDIFF_COUNT 0)
    # Assume all files inside expected output directory are to be compared.
    file(GLOB_RECURSE expected_files LIST_DIRECTORIES FALSE ${EXPECTED_OUTPUT}/*)
    foreach(_file ${expected_files})
        math(EXPR _NDIFF_COUNT "${_NDIFF_COUNT}+1")
        string(REGEX REPLACE "^${EXPECTED_OUTPUT}/" "" _output_file ${_file} )
        set(NDIFF_ABS_COMPARISON_${_NDIFF_COUNT} COMMAND ${NDIFF_EXECUTABLE} -abserr ${TEST_ABS_TOLERANCE} ${_file} ${TEST_OUTPUT}/${_output_file})
        set(NDIFF_REL_COMPARISON_${_NDIFF_COUNT} COMMAND ${NDIFF_EXECUTABLE} -relerr ${TEST_REL_TOLERANCE} ${_file} ${TEST_OUTPUT}/${_output_file})
    endforeach()
elseif (EXISTS "${EXPECTED_OUTPUT}")
    set(_NDIFF_COUNT 1)
    set(NDIFF_ABS_COMPARISON_1 COMMAND ${NDIFF_EXECUTABLE} -abserr ${TEST_ABS_TOLERANCE} ${EXPECTED_OUTPUT} ${TEST_OUTPUT})
    set(NDIFF_REL_COMPARISON_1 COMMAND ${NDIFF_EXECUTABLE} -relerr ${TEST_REL_TOLERANCE} ${EXPECTED_OUTPUT} ${TEST_OUTPUT})
endif ()

string(REPLACE "|" ";" TEST_CMD ${TEST_CMD})
execute_process(
    COMMAND ${TEST_CMD}
    RESULT_VARIABLE test_execution_not_successful
    OUTPUT_VARIABLE _out
    ERROR_VARIABLE _out
    WORKING_DIRECTORY test_runs/${TEST_NAME})

file(WRITE test_runs/${TEST_NAME}/${TEST_NAME}.ctest_out ${_out})

if (test_execution_not_successful)
    message(STATUS "test_execution_not_successful: ${test_execution_not_successful}")
    message(STATUS "_out: ${_out}")
    message(SEND_ERROR "${TEST_NAME} did not execute succesfully!\n${TEST_CMD}")
elseif (EXPECTED_OUTPUT_DEFINED AND _NDIFF_COUNT EQUAL 0)
    message(STATUS "test_execution_not_successful: ${test_execution_not_successful}")
    message(STATUS "_out: ${_out}")
    message(SEND_ERROR "${TEST_NAME} does not have expected output!")
else ()
    set(_NDIFF_INDEX 0)
    while(_NDIFF_INDEX LESS _NDIFF_COUNT)
        math(EXPR _NDIFF_INDEX "${_NDIFF_INDEX}+1")
        list(GET NDIFF_ABS_COMPARISON_${_NDIFF_INDEX} 4 _expected_file)
        list(GET NDIFF_ABS_COMPARISON_${_NDIFF_INDEX} 5 _actual_file)

        if (NOT EXISTS "${_expected_file}")
            message(SEND_ERROR "Expected output: '${_expected_file}' does not exist!")
        endif ()
        if (NOT EXISTS "${_actual_file}")
            message(SEND_ERROR "Actual output: '${_actual_file}' does not exist!")
        endif ()

        execute_process(
          ${NDIFF_ABS_COMPARISON_${_NDIFF_INDEX}}
          RESULT_VARIABLE test_abs_not_successful
          OUTPUT_FILE ${_actual_file}.abs_ndiff
          ERROR_VARIABLE _ERROR)

        if (_ERROR)
            message(SEND_ERROR "Test '${TEST_NAME}' reported abs ndiff error: ${_ERROR}")
        endif ()

	if (test_abs_not_successful)
	
           execute_process(
              ${NDIFF_REL_COMPARISON_${_NDIFF_INDEX}}
              RESULT_VARIABLE test_rel_not_successful
              OUTPUT_FILE ${_actual_file}.rel_ndiff
              ERROR_VARIABLE _ERROR)

           if (_ERROR)
               message(SEND_ERROR "Test '${TEST_NAME}' reported rel ndiff error: ${_ERROR}")
           endif ()

	   if (test_rel_not_successful)
               message(SEND_ERROR "Expected output: '${_expected_file}' does not match actual output '${_actual_file}'!")
           endif ()        
	
	endif()       

    endwhile()
endif ()
