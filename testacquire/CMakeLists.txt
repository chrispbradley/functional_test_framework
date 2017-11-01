
# This project requires:
#  - NDIFF_EXECUTABLE: ndiff executable.
#  - DB_DIR: Database location that can be read with read_test_db.
#  - TESTS_BASE_DIR: Base directory where the examples to be tested are downloaded to.
#  - OpenCMISSLibs_DIR: A directory where opencmisslibs.config exists.

cmake_minimum_required(VERSION 3.4 FATAL_ERROR)
project(testacquire VERSION 1.0 LANGUAGES C CXX)

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

if (IS_DIRECTORY "${TEST_DB}")
    read_test_db_dir()
else ()
    read_test_db_file()
endif ()

set(TEST_INDEX 0)
while(TEST_INDEX LESS TEST_COUNT)
    math(EXPR TEST_INDEX "${TEST_INDEX}+1")

    set(_current_test_name ${TEST_${TEST_INDEX}_NAME})
    set(_current_test_git_repo ${TEST_${TEST_INDEX}_GIT_REPO})
    set(_current_test_branch ${TEST_${TEST_INDEX}_BRANCH})

    if (IS_ABSOLUTE "${_current_test_git_repo}" AND EXISTS "${_current_test_git_repo}/CMakeLists.txt")
        # Local test already acquired so do nothing
    else ()
        acquire_test(${_current_test_name} ${TESTS_BASE_DIR}/${_current_test_name} ${_current_test_git_repo} ${_current_test_branch})
    endif ()
endwhile()
