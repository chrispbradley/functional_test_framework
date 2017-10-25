
macro(read_test_db_dir)
    # Read database of tests.
    file(GLOB test_files LIST_DIRECTORIES FALSE ${TEST_DB}/*.cmake)

    set(TEST_COUNT 0)
    foreach(test_file ${test_files})
        math(EXPR TEST_COUNT "${TEST_COUNT}+1")
        #message(STATUS "test_file: ${test_file}")
        get_filename_component(test_file "${test_file}" NAME)
        get_filename_component(TEST_NAME "${test_file}" NAME_WE)
        add_functional_test(${TEST_DB}/${test_file})
    endforeach()
endmacro()

macro(read_test_db_file)
    set(TEST_COUNT 1)
    get_filename_component(TEST_NAME "${TEST_DB}" NAME_WE)
    add_functional_test(${TEST_DB})
endmacro()

macro(add_functional_test TEST_DESCRIPTION_FILE)
    include(${TEST_DESCRIPTION_FILE})
    set(TEST_${TEST_COUNT}_NAME ${TEST_NAME})
    set(TEST_${TEST_COUNT}_URL ${TEST_URL})
    set(TEST_${TEST_COUNT}_BRANCH ${TEST_BRANCH})
    set(TEST_${TEST_COUNT}_TARGETS ${TEST_TARGETS})
    set(TEST_${TEST_COUNT}_EXPECTED_RESULTS ${TEST_EXPECTED_RESULTS})
endmacro()
