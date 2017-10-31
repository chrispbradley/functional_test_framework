# some argument checking:
# test_cmd is the command to run with all its arguments
if (NOT test_cmd)
    message( FATAL_ERROR "Variable test_cmd not defined" )
endif ()
# expected_output contains the name of the "expected" output file
if (NOT expected_output)
    message( FATAL_ERROR "Variable expected_output not defined" )
endif ()
# test_output contains the name of the output file the test_cmd will produce
if (NOT test_output)
    message( FATAL_ERROR "Variable test_output not defined" )
endif ()

if (IS_DIRECTORY "${expected_output}")
    set(_NDIFF_COUNT 0)
    # Assume all files inside expected output directory are to be compared.
    file(GLOB expected_files LIST_DIRECTORIES FALSE ${expected_output}/*)
    foreach(_file ${expected_files})
        math(EXPR _NDIFF_COUNT "${_NDIFF_COUNT}+1")
        get_filename_component(_output_file ${_file} NAME)
        set(NDIFF_COMPARISON_${_NDIFF_COUNT} COMMAND ${NDIFF_EXECUTABLE} -relerr 1e-14 ${_file} ${test_output}/${_output_file})
    endforeach()
else ()
    set(_NDIFF_COUNT 1)
    set(NDIFF_COMPARISON_1 COMMAND ${NDIFF_EXECUTABLE} ${expected_output} ${test_output})
endif ()

execute_process(
    COMMAND ${test_cmd}
    RESULT_VARIABLE test_execution_not_successful
    WORKING_DIRECTORY test_runs/${TEST_NAME})

if (test_execution_not_successful)
    message(SEND_ERROR "${TEST_NAME} did not execute succesfully!")
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
