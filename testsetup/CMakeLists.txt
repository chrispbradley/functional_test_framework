
# This project requires:
#  - NDIFF_EXECUTABLE: ndiff executable.
#  - DB_DIR: Database location that can be read with read_test_db.
#  - TESTS_BASE_DIR: Base directory where the examples to be tested are downloaded to.
#  - OpenCMISSLibs_DIR: A directory where opencmisslibs.config exists.

cmake_minimum_required(VERSION 3.4 FATAL_ERROR)
project(testsetup VERSION 1.0 LANGUAGES C CXX)

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

if (OPENCMISS_MPI)
    set(OPENCMISS_MPI_CONFIGURATION "set(OPENCMISS_MPI ${OPENCMISS_MPI})")
endif ()

include(ReadTestDB)
include(WriteTest)

file(COPY run_test.cmake DESTINATION ${TESTS_BASE_DIR})

if (IS_DIRECTORY "${TEST_DB}")
    read_test_db_dir()
else ()
    read_test_db_file()
endif ()

set(SETUP_CMAKELISTS_FILE ${TESTS_BASE_DIR}/CMakeLists.txt)
file(WRITE ${SETUP_CMAKELISTS_FILE} "
cmake_minimum_required(VERSION 3.4 FATAL_ERROR)
project(testrunner VERSION 1.0 LANGUAGES C CXX Fortran)
enable_testing()

${OPENCMISS_MPI_CONFIGURATION}
set(OpenCMISSLibs_DIR ${OpenCMISSLibs_DIR})

find_package(OpenCMISSLibs 1.3.0 CONFIG)

")
set(TEST_INDEX 0)
while(TEST_INDEX LESS TEST_COUNT)
    math(EXPR TEST_INDEX "${TEST_INDEX}+1")

    set(_current_name ${TEST_${TEST_INDEX}_NAME})
    set(_current_git_repo ${TEST_${TEST_INDEX}_GIT_REPO})
    set(_current_branch ${TEST_${TEST_INDEX}_BRANCH})

    foreach(_prefix TEST_ PYTEST_)
        set(_current_targets ${${_prefix}${TEST_INDEX}_TARGETS})
        set(_current_expected_results_list ${${_prefix}${TEST_INDEX}_EXPECTED_RESULTS})
        set(_current_tolerance ${${_prefix}${TEST_INDEX}_TOLERANCE})
        set(_current_args_list ${${_prefix}${TEST_INDEX}_TARGETS_ARGS})
        set(_current_mp ${${_prefix}${TEST_INDEX}_MULTI_PROCESS})
        if (_current_mp)
            set(_current_np ${TEST_${TEST_INDEX}_NP})
        endif ()

        if (_current_targets)
            set(write_test_module "write_")
            if (_current_mp)
                set(write_test_module "${write_test_module}mp_")
            endif ()
            if (_prefix STREQUAL "TEST_")
                set(write_test_module "${write_test_module}target_test")
            elseif (_prefix STREQUAL "PYTEST_")
                set(write_test_module "${write_test_module}python_test")
            endif ()

            if (IS_ABSOLUTE "${_current_git_repo}")
                set(_current_root ${_current_git_repo})
                if (_prefix STREQUAL "TEST_" AND EXISTS "${_current_git_repo}/CMakeLists.txt")
                    file(APPEND ${SETUP_CMAKELISTS_FILE} "add_subdirectory(${_current_git_repo} ${_current_name})\n")
                endif ()
            else ()
                set(_current_root ${TESTS_BASE_DIR}/${_current_name})
                if (_prefix STREQUAL "TEST_")
                    file(APPEND ${SETUP_CMAKELISTS_FILE} "add_subdirectory(${_current_name})\n")
                endif ()
            endif ()

            # Iterate over the current targets and write out a test specifically for that target.
            list(LENGTH _current_targets TARGET_COUNT)
            set(_current_unmodified_name ${_current_name})
            set(TARGET_INDEX 0)
            while(TARGET_INDEX LESS TARGET_COUNT)
                list(GET _current_targets ${TARGET_INDEX} _current_target)
                list(GET _current_expected_results_list ${TARGET_INDEX} _current_expected_results)
                if (_current_args_list)
                    list(GET _current_args_list ${TARGET_INDEX} _current_args)
                endif ()
                math(EXPR TARGET_INDEX "${TARGET_INDEX}+1")
                if (TARGET_COUNT GREATER 1)
                    set(_current_name ${_current_name}_${TARGET_INDEX})
                endif ()
                include(${write_test_module})
                write_test()
                # Reset current name
                set(_current_name ${_current_unmodified_name})
            endwhile()
        endif ()
    endforeach()
endwhile()

file(APPEND ${SETUP_CMAKELISTS_FILE} "\n")
