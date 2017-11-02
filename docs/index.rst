
OpenCMISS Functional Testing Framework
======================================

.. contents:: **Contents**

Framework overview
==================

The OpenCMISS functional testing framework has been designed to run examples as functional tests.  The framework has been written using the CMake scripting language.

The framework is one part of the required software that enables testing of examples.  There are two other parts to the software they are: the test database; the functional tests (or examples as they are better known).

The frameworks job is to pull together the functional tests and utilities onto a local machine and execute the tests and report on whether the test passed or failed.  Where available a comparison between the expected output and the actual output of the executed test is made.

The description of which functional tests are to be run are defined in the test database.  Any test database can be supplied to the framework as long as it conforms to the OpenCMISS test database standard defined below.

OpenCMISS test database standard
================================

This framework currently supports a single standard of test database.  In the future we would like to extend this to be able to handle an RDF annotated test database that is compatible with PMR.

The database must consist of individual test description files or be a single test description file. Each test description file that defines a functional test must have the suffix '.cmake'. Each test description file must contain valid text that can be 'included' by CMake.  Each file must define two variables:

#. TEST_GIT_REPO
#. TEST_BRANCH

The *TEST_GIT_REPO* variable must specify the location of a git repository.  The *TEST_BRANCH* variable must specify a branch within the repository specified by *TEST_GIT_REPO*. 

Additionally you must define either a

3. (a) TEST_TARGETS

or a

3. (b) PYTEST_TARGETS

variable.  The *TEST_TARGETS* variable must specify the name of the executable to test.  The name of the executable must be a target as CMake understands targets.  The *TEST_TARGETS*  variable may be specified as a list of executable names.  The *PYTEST_TARGETS* variable must be specified as the name of the python script to execute.  This *PYTEST_TARGETS* variable must be defined relative to the root directory of the repository.  The *PYTEST_TARGETS* variable may be specified as a list of python scripts defined relative to the root directory of the repository.

The following variables are all optional, they are used to add additional functionality.  Each of the following variables has two forms one for compiled targets and one for Python scripts.  The Python scripts variant of the variables have *PY* prefixed to the name of the variable but otherwise they perform the same function as their compiled targets counterpart.

* TEST_EXPECTED_RESULTS

The *TEST_EXPECTED_RESULTS* variable, if defined, must specify the location of the expected results relative to the root of the repository.  The *TEST_EXPECTED_RESULTS* may be specified as a list of expected results locations.  The number of entries in the *TEST_EXPECTED_RESULTS* variable must match the number of entries in the *TEST_TARGETS* variable.  The entries in the *TEST_EXPECTED_RESULTS* variable may be either a location of a single file or a single directory.  In the case where an entry in the *TEST_EXPECTED_RESULTS* variable specifies a directory every file found in that directory will be tested against the files output by the target executable specified in the corresponding entry in the *TEST_TARGETS* variable.

* TEST_TARGETS_ARGS

The *TEST_TARGET_ARGS* variable, if defined, must specify the arguments to be passed to the the executable to test.  If the executable requires multiple arguments each argument must be separated with the '|' symbol.  Like the *TEST_EXPECTED_RESULTS* variable the number of entries in the *TEST_TARGET_ARGS* variable must match the number of entries in the *TEST_TARGETS* variable.

* TEST_TOLERANCE

The *TEST_TOLERANCE* variable, if defined, must specify the relative error allowed for numerical comparisons in the output.  The default value is `1e-14`.

* TEST_MULTI_PROCESS
* TEST_NP

The *TEST_MULTI_PROCESS* variable, if defined, specifies whether the example is to be run using multi-processes or not.  The variable must be defined as either *TRUE* or *FALSE*.  This variable applies to all the targets specified in the *TEST_TARGETS* variable.  If the *TEST_MULTI_PROCESS* variable is defined then the *TEST_NP* variable must be defined.  The value of the *TEST_NP* variable is an integer value that represents the number of processes to use when executing the program.

How to use
==========

To use the framework execute the following commands from a terminal application (Windows users will have to determine the equivalent commands as an exercise)::

  git clone https://github.com/OpenCMISS/functional_test_framework.git
  mkdir functional_test_framework-build
  cd functional_test_framework-build
  cmake -DOpenCMISSLibs_DIR=/location/where/opencmiss/libraries/are/installed ../functional_test_framework
  make

.. note:: The OpenCMISSLibs_DIR should be set with a value which is an actual directory accessible from your machine where the OpenCMISS libraries have been installed.

This will configure, build, and run the test(s) defined by the test database.  You can re-run just the tests (once the intial configure, build, and run has successfully completed) with the `ctest` command::

   ctest

Framework configuration
=======================

The framework must be configured with *OpenCMISSLibs_DIR* set to the location of an OpenCMISS libraries installation install directory.

You can also optionally set the location of the test database with the *TEST_DB_REPO_URL* variable and also set the branch from the test database repository with the *TEST_DB_REPO_BRANCH* variable.  These variables can be passed in through the command line or set using a CMake-GUI application.

Further you can set the location of the test database to use using the *TEST_DB* variable.  The test database may either point directly to a test description file as defined above or a directory containing test description files.

If the *TEST_DB* variable is defined and it is a directory or file that exists then this is the database that will be used by the framework and the database defined by the *TEST_DB_REPO_URL* will be ignored.  The *TEST_DB* variable may be used to reference a location on the local disk.  A reference to a location on the local disk must be defined as an absolute path, using a relative path will cause undefined behaviour.

An example of configuring the framework to use a local database is given below::

    cmake -DOpenCMISSLibs_DIR=/location/where/opencmiss/libraries/are/installed 
      -DTEST_DB=/absoulte/path/to/test_name.cmake ../functional_test_framework

Where the file *test_name.cmake* is a valid test description file according to the OpenCMISS test database standard.  In the above example only a single example *test_name* is tested.

Test description examples
=========================

The following are examples of test description files, some of which are complete examples that require no changes to use.  The examples with local paths are not complete for obvious reasons.

Below is a basic example of a test description file that meets the requirements of the test framework::

   set(TEST_GIT_REPO https://github.com/OpenCMISS-Examples/burgers_static.git)
   set(TEST_BRANCH develop)
   set(TEST_TARGETS burgers_static_fortran)

This example defines a single executable program with the CMake target name *burgers_static_fortran*.  The framework will test that this example builds and executes against the defined OpenCMISS libraries.

Below is an example of a test description file that defines a Python script meets the requirements of the test framework::

   set(TEST_GIT_REPO https://github.com/OpenCMISS-Examples/nonlinear_poisson_equation.git)
   set(TEST_BRANCH develop)
   set(PYTEST_TARGETS src/python/nonlinear_poisson_equation.py)

Below is an example of running a test that is on the local disk the *\*_GIT_REPO* variable is defined as an absolute path::

    set(TEST_GIT_REPO /path/to/opencmiss-software/example_framework/examples/diffusion_equation)
    set(TEST_BRANCH develop)
    set(TEST_TARGETS diffusion_equation)
    set(TEST_EXPECTED_RESULTS src/fortran/expected_results/)
    set(TEST_TOLERANCE 1e-12)

Below is an example of several executable programs with arguments using multiple processors::

    set(TEST_GIT_REPO https://github.com/OpenCMISS-Examples/bioelectrics_monodomain.git)
    set(TEST_BRANCH master)

    set(TEST_TARGETS monodomain_2d_f monodomain_2d_f)
    set(TEST_TARGETS_ARGS "0.001|0.1|1|src/fortran/n98.xml" "0.01|0.05|1|src/fortran/n98.xml")
    set(TEST_EXPECTED_RESULTS src/fortran/expected_results_1 src/fortran/expected_results_2)

    set(TEST_MULTI_PROCESS TRUE)
    set(TEST_NP 4)

    set(PYTEST_TARGETS src/python/Monodomain2DSquare.py)
    set(PYTEST_TARGETS_ARGS "src/python/n98.xml")
    set(PYTEST_EXPECTED_RESULTS src/python/expected_results)

    set(PYTEST_MULTI_PROCESS TRUE)
    set(PYTEST_NP 4)

When the executables have been successfully run the outputs given in the *\*_EXPECTED_RESULTS* variable will be compared against the actual outputs from the program, the test will be marked as a failed test if the outputs do not match to the default tolerance.
