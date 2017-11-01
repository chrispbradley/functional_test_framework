
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

include(ReadTestDB)
include(WriteTest)

set(_MPIEXEC_NAMES mpiexec mpirun lamexec srun)
# Most mpi distros have some form of mpiexec which gives us something we can reliably look for.
find_program(MPIEXEC
  NAMES ${_MPIEXEC_NAMES}
#  PATHS ${_MPI_PREFIX_PATH}
  PATH_SUFFIXES bin
  DOC "Executable for running MPI programs.")

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

set(OpenCMISSLibs_DIR ${OpenCMISSLibs_DIR})

find_package(OpenCMISSLibs 1.3.0 REQUIRED CONFIG)

")
set(TEST_INDEX 0)
while(TEST_INDEX LESS TEST_COUNT)
    math(EXPR TEST_INDEX "${TEST_INDEX}+1")

    set(_current_test_name ${TEST_${TEST_INDEX}_NAME})
    set(_current_test_url ${TEST_${TEST_INDEX}_URL})
    set(_current_test_branch ${TEST_${TEST_INDEX}_BRANCH})
    set(_current_test_targets ${TEST_${TEST_INDEX}_TARGETS})
    set(_current_test_expected_results ${TEST_${TEST_INDEX}_EXPECTED_RESULTS})
    set(_current_test_tolerance ${TEST_${TEST_INDEX}_TOLERANCE})
    set(_current_test_args ${TEST_${TEST_INDEX}_TARGETS_ARGS})
    set(_current_test_mp ${TEST_${TEST_INDEX}_MULTI_PROCESS})
    if (_current_test_mp)
        set(_current_test_np ${TEST_${TEST_INDEX}_NP})
    endif ()

    if (IS_ABSOLUTE "${_current_test_url}" AND EXISTS "${_current_test_url}/CMakeLists.txt")
        set(_current_test_root ${_current_test_url})
        file(APPEND ${SETUP_CMAKELISTS_FILE} "add_subdirectory(${_current_test_url} ${_current_test_name})\n")
    else ()
        file(APPEND ${SETUP_CMAKELISTS_FILE} "add_subdirectory(${_current_test_name})\n")
        set(_current_test_root ${TESTS_BASE_DIR}/${_current_test_name})
    endif ()

    list(LENGTH ${_current_test_targets} TARGET_COUNT)
    if (TARGET_COUNT EQUAL 0)
        if (_current_test_mp)
            write_mp_target_test(${SETUP_CMAKELISTS_FILE} ${_current_test_name}
                ${_current_test_targets} ${_current_test_np} ${_current_test_root} ${_current_test_expected_results}
                ${_current_test_tolerance} ${_current_test_args})
        else ()
            write_target_test(${SETUP_CMAKELISTS_FILE} ${_current_test_name}
                ${_current_test_targets} ${_current_test_root} ${_current_test_expected_results}
                ${_current_test_tolerance} ${_current_test_args})
        endif ()
    else ()
        set(TARGET_INDEX 0)
        while(TARGET_INDEX LESS TARGET_COUNT)
            list(GET ${_current_test_targets} ${TARGET_INDEX} _cur_target)
            list(GET ${_current_test_expected_results} ${TARGET_INDEX} _cur_expected_result)
            math(EXPR TARGET_INDEX "${TARGET_INDEX}+1")
            if (_current_test_mp)
                write_mp_target_test(${SETUP_CMAKELISTS_FILE} ${_current_test_name}_${TARGET_INDEX}
                    ${_cur_target} ${_current_test_np} ${_current_test_root} ${_cur_expected_result}
                    ${_current_test_tolerance} ${_current_test_args})
            else ()
                write_target_test(${SETUP_CMAKELISTS_FILE} ${_current_test_name}_${TARGET_INDEX}
                    ${_cur_target} ${_current_test_root} ${_cur_expected_result}
                    ${_current_test_tolerance} ${_current_test_args})
            endif ()
        endwhile()
    endif ()
endwhile()

file(APPEND ${SETUP_CMAKELISTS_FILE} "\n")
