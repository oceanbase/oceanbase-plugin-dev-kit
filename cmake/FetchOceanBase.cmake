include(FetchContent)

set(OCEANBASE_GIT_REPO "https://github.com/oceanbase/oceanbase.git" CACHE STRING "OceanBase git repository")
set(OCEANBASE_GIT_TAG  "8d5a187da1dd96d1cac5b13c1af2616f2019250c"   CACHE STRING "OceanBase git tag or commit id to package")

FetchContent_Populate(
  oceanbase
  GIT_REPOSITORY ${OCEANBASE_GIT_REPO}
  GIT_TAG ${OCEANBASE_GIT_TAG}
  GIT_PROGRESS TRUE
  SOURCE_DIR ${PROJECT_SOURCE_DIR}/deps/oceanbase)
