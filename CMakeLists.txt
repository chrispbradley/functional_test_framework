
cmake_minimum_required(VERSION 3.4 FATAL_ERROR)
project(OpenCMISS-FunctionalTests VERSION 1.0 LANGUAGES C CXX)

# Default values for test database.
set(TEST_DB_GIT_BASE https://github.com)
set(TEST_DB_ORG hsorby)
set(TEST_DB_REPO_NAME FunctionalTests-Database)

# Default values for ndiff.
set(NDIFF_GIT_BASE https://github.com)
set(NDIFF_ORG OpenCMISS-Dependencies)
set(NDIFF_REPO_NAME ndiff)
set(NDIFF_REPO_BRANCH v2.0.0)

if (DEFINED BUILD_TYPE)
    set(CMAKE_BUILD_TYPE ${BUILD_TYPE} CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE)
else ()
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif ()

set(OpenCMISSLibs_DIR ${OpenCMISSLibs_DIR} CACHE PATH "Install prefix for OpenCMISS libraries.")
set(TEST_DB_REPO_URL ${TEST_DB_GIT_BASE}/${TEST_DB_ORG}/${TEST_DB_REPO_NAME} CACHE STRING "User specified test database url.")
set(TEST_DB_REPO_BRANCH master CACHE STRING "Branch of the database git repository to use.")

# Basic test for multi-configuration capable environments.
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

# Get ndiff installed.
set(NDIFF_GITHUB_REPO_URL ${NDIFF_GIT_BASE}/${NDIFF_ORG}/${NDIFF_REPO_NAME})
set(NDIFF_GITHUB_BRANCH ${NDIFF_REPO_BRANCH})
set(NDIFF_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=.)

include(ExternalProject)

ExternalProject_Add(ndiff
    PREFIX ndiff
    STAMP_DIR ndiff/stamp
    TMP_DIR ndiff/tmp
    SOURCE_DIR ndiff/src
    BINARY_DIR ndiff/build
    GIT_REPOSITORY ${NDIFF_GITHUB_REPO_URL}
    GIT_TAG ${NDIFF_GITHUB_BRANCH}
    CMAKE_COMMAND ${CMAKE_COMMAND}
    CMAKE_ARGS ${SINGLE_BUILD_CONFIG} ${NDIFF_CMAKE_ARGS}
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install ${MULTICONFIG_BUILD_CONFIG}
)

ExternalProject_Add(test_db
    SOURCE_DIR test_db/
    GIT_REPOSITORY ${TEST_DB_REPO_URL}
    GIT_TAG ${TEST_DB_REPO_BRANCH}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/testsetup-build)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/testrunner-build)

add_custom_target(setup_tests
    COMMAND ${CMAKE_COMMAND}
        -DOpenCMISSLibs_DIR=${OpenCMISSLibs_DIR}
        -DDB_DIR=${CMAKE_CURRENT_BINARY_DIR}/test_db/
        -DNDIFF_EXECUTABLE=${CMAKE_CURRENT_BINARY_DIR}/ndiff/build/bin/ndiff
        -DTEST_BASE_DIR=${CMAKE_CURRENT_BINARY_DIR}/tests
        ${CMAKE_CURRENT_SOURCE_DIR}/testsetup
    COMMAND ${CMAKE_COMMAND} --build . ${MULTICONFIG_BUILD_CONFIG}
    DEPENDS test_db ndiff
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/testsetup-build)

add_custom_target(build_tests
    COMMAND ${CMAKE_COMMAND} ${CMAKE_CURRENT_BINARY_DIR}/tests
    COMMAND ${CMAKE_COMMAND} --build . ${MULTICONFIG_BUILD_CONFIG}
    DEPENDS setup_tests
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/testrunner-build)

add_custom_target(run_tests ALL
    COMMAND ${CMAKE_CTEST_COMMAND}
    DEPENDS build_tests
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/testrunner-build)

mark_as_advanced(CMAKE_OSX_ARCHITECTURES CMAKE_OSX_DEPLOYMENT_TARGET CMAKE_OSX_SYSROOT CMAKE_INSTALL_PREFIX)
