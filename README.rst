
======================================
OpenCMISS Functional Testing Framework
======================================

The OpenCMISS functional testing framework has been designed to run examples as functional tests. The framework has been written using the CMake scripting language.

For a quick start guide to using the framework you can read the short documentation below.  For more detailed documentation read the full guide available `here <docs/index.rst>`_.

Usage (brief)
=============

To use the framework execute the following commands from a terminal application (Windows users will have to determine the equivalent commands as an exercise)::

  git clone https://github.com/OpenCMISS/functional_test_framework.git functional_test_framework
  mkdir functional_test_framework-build
  cd functional_test_framework-build
  cmake -DOpenCMISSLibs_DIR=/location/where/opencmiss/libraries/are/installed ../functional_test_framework
  make

.. note:: The OpenCMISSLibs_DIR should be set with a value which is an actual directory accessible from your machine where the OpenCMISS libraries have been installed.

This will configure, build, and run the test(s) defined by the test database.  You can run just the tests (once the intial configure, build, and run has successfully completed) with the `ctest` command::

   ctest

Documentation
=============

The documentation has been written using reStructured text and it is available in the docs directory.  The documentation can be read directly in its' reStructured text form or it can be built using Sphinx to render the documentation in a different format.  For example, we can render the documentation as html by running the following command from the command line inside the **docs** directory (for unix based operating systems)::

   make html

The html rendering of the documentation will be available in the *_build/html* directory relative to the *docs* direcotory.
