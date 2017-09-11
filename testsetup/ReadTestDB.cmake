
macro(read_test_db)
    # Read database of tests.
    file(GLOB test_files LIST_DIRECTORIES FALSE ${DB_DIR}/*.cmake)

    set(TEST_COUNT 0)
    foreach(test_file ${test_files})
        math(EXPR TEST_COUNT "${TEST_COUNT}+1")
        message(STATUS "test_file: ${test_file}")
        get_filename_component(test_file "${test_file}" NAME)
        get_filename_component(TEST_NAME "${test_file}" NAME_WE)
        include(${DB_DIR}/${test_file})
        # Add test info to test variables.
        set(TEST_${TEST_COUNT}_NAME ${TEST_NAME})
        set(TEST_${TEST_COUNT}_URL ${TEST_URL})
        set(TEST_${TEST_COUNT}_BRANCH ${TEST_BRANCH})
        set(TEST_${TEST_COUNT}_TARGETS ${TEST_TARGETS})
        set(TEST_${TEST_COUNT}_EXPECTED_RESULTS ${TEST_EXPECTED_RESULTS})
    endforeach()
endmacro()
