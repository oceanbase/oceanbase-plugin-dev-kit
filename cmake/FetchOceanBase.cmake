include(FetchContent)

FetchContent_Declare(
  oceanbase
  GIT_REPOSITORY git@gitlab.oceanbase-dev.com:oceanbase/oceanbase.git
  GIT_TAG 8d5a187da1dd96d1cac5b13c1af2616f2019250c)

#FetchContent_MakeAvailable(oceanbase)

FetchContent_Populate(
  oceanbase
  SOURCE_DIR ${PROJECT_SOURCE_DIR}/deps/oceanbase
  BINARY_DIR "")
