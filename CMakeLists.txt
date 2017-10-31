
cmake_minimum_required(VERSION 3.4 FATAL_ERROR)
project(OpenCMISS-FunctionalTests VERSION 1.0 LANGUAGES C CXX)

# Default values for test database.
set(TEST_DB_GIT_BASE https://github.com)
set(TEST_DB_ORG hsorby)
set(TEST_DB_REPO_NAME FunctionalTests-Database)
set(TEST_DB_REPO_URL ${TEST_DB_GIT_BASE}/${TEST_DB_ORG}/${TEST_DB_REPO_NAME} CACHE STRING "User specified test database url.")
set(TEST_DB_REPO_BRANCH master CACHE STRING "Branch of the database git repository to use.")

set(TEST_DB "${CMAKE_CURRENT_BINARY_DIR}/test_db/" CACHE PATH "Set the test database.")

# Default values for ndiff.
set(NDIFF_GIT_BASE https://github.com)
set(NDIFF_ORG OpenCMISS-Utilities)
set(NDIFF_REPO_NAME ndiff)
set(NDIFF_REPO_BRANCH v2.0.0)

if (DEFINED BUILD_TYPE)
    set(CMAKE_BUILD_TYPE ${BUILD_TYPE} CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE)
else ()
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.")
endif ()

find_package(OpenCMISSLibs REQUIRED)
#set(OpenCMISSLibs_DIR ${OpenCMISSLibs_DIR} CACHE PATH "Install prefix for OpenCMISS libraries.")

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
set(NDIFF_REPO_URL ${NDIFF_GIT_BASE}/${NDIFF_ORG}/${NDIFF_REPO_NAME})
set(NDIFF_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=.)

include(ExternalProject)

ExternalProject_Add(ndiff
    PREFIX ndiff
    STAMP_DIR ndiff/stamp
    TMP_DIR ndiff/tmp
    SOURCE_DIR ndiff/src
    BINARY_DIR ndiff/build
    GIT_REPOSITORY ${NDIFF_REPO_URL}
    GIT_TAG ${NDIFF_REPO_BRANCH}
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
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CTestTestFile.cmake" "# Generated test configuration file.\r\nsubdirs(\"testrunner-build\")\r\n")

add_custom_target(setup_tests
    COMMAND ${CMAKE_COMMAND}
        -DOpenCMISSLibs_DIR=${OpenCMISSLibs_DIR}
        -DTEST_DB=${TEST_DB}
        -DNDIFF_EXECUTABLE=${CMAKE_CURRENT_BINARY_DIR}/ndiff/build/bin/ndiff
        -DTESTS_BASE_DIR=${CMAKE_CURRENT_BINARY_DIR}/tests
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
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

add_custom_target(clear_tests
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/testsetup-build
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/testsetup-build
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/testrunner-build
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/testrunner-build
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/tests)

set(ADVANCED_GUI_ENTRIES)
list(APPEND ADVANCED_GUI_ENTRIES BLAS_DIR BZip2_DIR CELLML_DIR CSim_DIR Clang_DIR FIELDML-API_DIR FTGL_DIR Fieldml-API_DIR)
list(APPEND ADVANCED_GUI_ENTRIES Freetype_DIR GDCM-ABI_DIR GLEW_DIR HYPRE_DIR IRON_DIR ITK_DIR ImageMagick_DIR)
list(APPEND ADVANCED_GUI_ENTRIES LIBCELLML_DIR LLVM_DIR LibCellML_DIR LibXml2_DIR METIS_DIR MUMPS_DIR NETGEN_DIR)
list(APPEND ADVANCED_GUI_ENTRIES OPTPP_DIR PARMETIS_DIR PASTIX_DIR PETSC_DIR PNG_DIR PTSCOTCH_DIR SCALAPACK_DIR)
list(APPEND ADVANCED_GUI_ENTRIES SUITESPARSE_DIR SUNDIALS_DIR SUPERLU_DIR SUPERLU_DIST_DIR TIFF_DIR ZINC_DIR ZLIB_DIR)
list(APPEND ADVANCED_GUI_ENTRIES QT_QMAKE_EXECUTABLE CMAKE_OSX_ARCHITECTURES CMAKE_OSX_DEPLOYMENT_TARGET CMAKE_OSX_SYSROOT)
list(APPEND ADVANCED_GUI_ENTRIES CMAKE_CODEBLOCKS_MAKE_ARGUMENT CMAKE_CODEBLOCKS_EXECUTABLE CMAKE_INSTALL_PREFIX)
mark_as_advanced(${ADVANCED_GUI_ENTRIES})
