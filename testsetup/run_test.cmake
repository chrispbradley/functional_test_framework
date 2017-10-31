# some argument checking:
# TEST_CMD is the command to run with all its arguments
if (NOT TEST_CMD)
    message( FATAL_ERROR "Variable TEST_CMD not defined" )
endif ()
# EXPECTED_OUTPUT contains the name of the "expected" output file
if (NOT EXPECTED_OUTPUT)
    message( FATAL_ERROR "Variable EXPECTED_OUTPUT not defined" )
endif ()
# TEST_OUTPUT contains the name of the output file the TEST_CMD will produce
if (NOT TEST_OUTPUT)
    message( FATAL_ERROR "Variable TEST_OUTPUT not defined" )
endif ()

set(EXPECTED_OUTPUT_FOUND TRUE)
if (IS_DIRECTORY "${EXPECTED_OUTPUT}")
    set(_NDIFF_COUNT 0)
    # Assume all files inside expected output directory are to be compared.
    file(GLOB expected_files LIST_DIRECTORIES FALSE ${EXPECTED_OUTPUT}/*)
    foreach(_file ${expected_files})
        math(EXPR _NDIFF_COUNT "${_NDIFF_COUNT}+1")
        get_filename_component(_output_file ${_file} NAME)
        set(NDIFF_COMPARISON_${_NDIFF_COUNT} COMMAND ${NDIFF_EXECUTABLE} -relerr ${TEST_TOLERANCE} ${_file} ${TEST_OUTPUT}/${_output_file})
    endforeach()
elseif (EXISTS "${EXPECTED_OUTPUT}")
    set(_NDIFF_COUNT 1)
    set(NDIFF_COMPARISON_1 COMMAND ${NDIFF_EXECUTABLE} ${EXPECTED_OUTPUT} ${TEST_OUTPUT})
else ()
    set(EXPECTED_OUTPUT_FOUND FALSE)
endif ()

execute_process(
    COMMAND ${TEST_CMD}
    RESULT_VARIABLE test_execution_not_successful
    WORKING_DIRECTORY test_runs/${TEST_NAME})

if (test_execution_not_successful)
    message(SEND_ERROR "${TEST_NAME} did not execute succesfully!")
elseif (_NDIFF_COUNT EQUAL 0 OR NOT EXPECTED_OUTPUT_FOUND)
    message(SEND_ERROR "${TEST_NAME} does not have expected output!")
else ()
    set(_NDIFF_INDEX 0)
    while(_NDIFF_INDEX LESS _NDIFF_COUNT)
        math(EXPR _NDIFF_INDEX "${_NDIFF_INDEX}+1")
        execute_process(
          ${NDIFF_COMPARISON_${_NDIFF_INDEX}}
          RESULT_VARIABLE test_not_successful
          OUTPUT_VARIABLE _OUTPUT
          ERROR_VARIABLE _ERROR)

        if (test_not_successful)
            list(GET NDIFF_COMPARISON_${_NDIFF_INDEX} 4 _expected_file)
            list(GET NDIFF_COMPARISON_${_NDIFF_INDEX} 5 _actual_file)
            message(SEND_ERROR "Expected output: '${_expected_file}' does not match actual output '${_actual_file}'!")
        endif ()
        
        if (_ERROR)
            message(SEND_ERROR "Test '${TEST_NAME}' reported error: ${_ERROR}")
        endif ()
    endwhile()
endif ()
