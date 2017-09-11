
# Acquire test using external project

include(ExternalProject)

function(ACQUIRE_TEST TEST_NAME TEST_LOCATION TEST_REPO_URL TEST_BRANCH)

    ExternalProject_Add(${TEST_NAME}
        SOURCE_DIR ${TEST_LOCATION}
        GIT_REPOSITORY ${TEST_REPO_URL}
        GIT_TAG ${TEST_BRANCH}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND "")


endfunction()
