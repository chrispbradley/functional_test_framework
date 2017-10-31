
# This project requires:
#  - NDIFF_EXECUTABLE: ndiff executable.
#  - DB_DIR: Database location that can be read with read_test_db.
#  - TEST_BASE_DIR: Test base directory where the tests live.
#  - OpenCMISSLibs_DIR: A directory where opencmisslibs.config exists.

cmake_minimum_required(VERSION 3.4 FATAL_ERROR)
project(testsetup VERSION 1.0 LANGUAGES C CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# Basic test for multi-configuration capable environments
if (MSVC OR XCODE)
    set(_MULTI_CONFIG_ENV TRUE)
else ()
    set(_MULTI_CONFIG_ENV FALSE)
endif ()

if (_MULTI_CONFIG_ENV)
    set(MULTICONFIG_BUILD_CONFIG --config $<CONFIGURATION>)
else ()
    set(SINGLE_ARCHITECUTRE_BUILD_TYPE -release)
    set(SINGLE_BUILD_CONFIG -DCMAKE_BUILD_TYPE=Release)
endif ()

include(ReadTestDB)
include(AcquireTest)
include(WriteTest)

file(COPY run_test.cmake DESTINATION ${TEST_BASE_DIR})

if (IS_DIRECTORY "${TEST_DB}")
    read_test_db_dir()
else ()
    read_test_db_file()
endif ()

set(_run "
cmake_minimum_required(VERSION 3.4 FATAL_ERROR)
project(testrunner VERSION 1.0 LANGUAGES C CXX Fortran)
enable_testing()

set(OpenCMISSLibs_DIR ${OpenCMISSLibs_DIR})

find_package(OpenCMISSLibs 1.3.0 REQUIRED CONFIG)

")
set(TEST_INDEX 0)
while(TEST_INDEX LESS TEST_COUNT)
    math(EXPR TEST_INDEX "${TEST_INDEX}+1")

    list(APPEND _run "add_subdirectory(${TEST_${TEST_INDEX}_NAME})\n")

    set(_current_test_name ${TEST_${TEST_INDEX}_NAME})
    set(_current_test_url ${TEST_${TEST_INDEX}_URL})
    set(_current_test_branch ${TEST_${TEST_INDEX}_BRANCH})
    set(_current_test_targets ${TEST_${TEST_INDEX}_TARGETS})
    set(_current_test_expected_results ${TEST_${TEST_INDEX}_EXPECTED_RESULTS})

    acquire_test(${_current_test_name} ${TEST_BASE_DIR}/${_current_test_name} ${_current_test_url} ${_current_test_branch})

    list(LENGTH ${_current_test_targets} TARGET_COUNT)
    if (TARGET_COUNT EQUAL 0)
        write_target_test(${_current_test_name} ${_current_test_targets} ${_current_test_expected_results} _ctest_code)
        list(APPEND _run ${_ctest_code})
    else ()
        set(TARGET_INDEX 0)
        while(TARGET_INDEX LESS TARGET_COUNT)
            list(GET ${_current_test_targets} ${TARGET_INDEX} _cur_target)
            list(GET ${_current_test_expected_results} ${TARGET_INDEX} _cur_expected_result)
            math(EXPR TARGET_INDEX "${TARGET_INDEX}+1")
            write_target_test(${_current_test_name}_${TARGET_INDEX} ${_cur_target} ${_cur_expected_result} _ctest_code)
            list(APPEND _run ${_ctest_code})
        endwhile()
    endif ()
endwhile()

list(APPEND _run "\n")

file(WRITE ${TEST_BASE_DIR}/CMakeLists.txt ${_run})
