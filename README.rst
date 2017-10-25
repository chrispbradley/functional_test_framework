
======================================
OpenCMISS Functional Testing Framework
======================================

Framework overview
==================

The OpenCMISS functional testing framework is designed to be used for running examples as tests.  It has been written using the CMake scripting language.

The framework is one part of the required software that enables testing.  There are two other parts to the software the test database and the functional tests or examples as they are better known.

The frameworks job is to pull together the functional tests and utilities onto a local machine and execute the tests so that a comparison between the expected output and the actual output can be made.

The description of which functional tests are to be run are defined in the test database.  Any test database can be supplied to the framework as long as it conforms to the OpenCMISS test database standard.

OpenCMISS test database standard
================================

This framework currently supports a single standard of test database.  In the future we would like to extend this to be able to handle an RDF annotated test database that is compatible with PMR.

The database must consist of individual test description files or be a single test description file. Each test description file that defines a functional test must have the suffix '.cmake'. Each test description file must contain valid text that can be 'included' by CMake.  Each file must define four variables:

#. TEST_URL
#. TEST_BRANCH
#. TEST_TARGETS
#. TEST_EXPECTED_RESULTS 

The *TEST_URL* variable must specify the location of a git repository.  The *TEST_BRANCH* variable must specify a branch within the repository specified by *TEST_URL*.  The *TEST_TARGETS* variable must specify the name of the executable to test.  The name of the executable must be a target as CMake understands targets.  The *TEST_TARGETS*  variable may be specified as a list of executable names.  The *TEST_EXPECTED_RESULTS* variable must specify the location of the expected results relative to the root of the repository.  The *TEST_EXPECTED_RESULTS* may be specified as a list of expected results locations.  The number of entries in the *TEST_EXPECTED_RESULTS* variable must match the number of entries in the *TEST_TARGETS* variable.  The entries in the *TEST_EXPECTED_RESULTS* variable may be either a location of a single file or a single directory.  In the case where an entry in the *TEST_EXPECTED_RESULTS* variable specifies  a directory every file found in that directory will be tested against the files output by the target executable specified in the corresponding entry in the *TEST_TARGETS* variable.

How to use
==========

To use the framework execute the following commands from a terminal application (Windows users will have to determine the equivalent commands as an exercise)::

  git clone https://github.com/OpenCMISS/functional_test_framework.git functional_test_framework
  mkdir functional_test_framework-build
  cd functional_test_framework-build
  cmake -DOpenCMISSLibs_DIR=/location/where/opencmiss/libraries/are/installed ../functional_test_framework
  make

.. note:: The OpenCMISSLibs_DIR should be set with a value which is an actual directory accessible from your machine where the OpenCMISS libraries have been installed.

This will configure, build, and run the test(s) defined by the test database.  You can run just the tests (once the intial configure, build, and run has successfully completed) with the `ctest` command::

   ctest

Framework configuration
=======================

The framework must be configured with *OpenCMISSLibs_DIR* set to the location of an OpenCMISS libraries installation install directory.

You can also optionally set the location of the test database with the *TEST_DB_REPO_URL* variable and also set the branch from the test database repository with the *TEST_DB_REPO_BRANCH* variable.  These variables can be passed in through the command line or set using a CMake-GUI application.

Further you can set the location of the test database to use using the *TEST_DB* variable.  The test database may either point directly to a test description file as defined above or a directory containing test description files.

Test description file
=====================

Below is an example of a test description file that meets the requirements of the test framework::

   set(TEST_URL https://github.com/OpenCMISS-Examples/burgers_static.git)
   set(TEST_BRANCH develop)
   set(TEST_TARGETS burgers_static_fortran)
   set(TEST_EXPECTED_RESULTS expected_results.txt)
