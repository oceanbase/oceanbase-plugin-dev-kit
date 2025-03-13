include(FetchContent)

set(error_code 1)
set(SOURCE_DIR ${PROJECT_SOURCE_DIR}/deps/oceanbase)
if (EXISTS ${SOURCE_DIR})
  file(GLOB _source_dir_content "${SOURCE_DIR}/*")
  if (_source_dir_content)
    message(STATUS "Source dir is not empty, downloading source code skipped: ${SOURCE_DIR}")
    set(OCEANBASE_SOURCE_DIR ${SOURCE_DIR})
    return()
  endif()
endif()

execute_process(
  COMMAND sh -c "mkdir -p ${SOURCE_DIR} \
                 && cd ${SOURCE_DIR} \
                 && git init \
                 && git remote add origin ${OCEANBASE_GIT_REPO} \
                 && git fetch --progress --depth 1 origin ${OCEANBASE_GIT_TAG} \
                 && git checkout FETCH_HEAD"
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  RESULT_VARIABLE error_code
  COMMAND_ECHO STDOUT)
if(error_code)
  message(FATAL_ERROR "Failed to clone repository: ${OCEANBASE_GIT_REPO}. error_code is ${error_code}")
endif()

set(OCEANBASE_SOURCE_DIR ${SOURCE_DIR})
