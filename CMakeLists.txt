cmake_minimum_required(VERSION 3.20)

if (NOT DEFINED PACKAGE_VERSION)
  set (PACKAGE_VERSION 0.1.0)
endif()

project("oceanbase-plugin-dev-kit"
        VERSION ${PACKAGE_VERSION}
        DESCRIPTION "OceanBase Plugin Development Kit"
        LANGUAGES C CXX ASM)

set(OCEANBASE_GIT_REPO "https://github.com/oceanbase/oceanbase.git" CACHE STRING "OceanBase git repository")
set(OCEANBASE_GIT_TAG  "f7ea42bff11e19ad1c48e594d8ac24f1145c8bb9"   CACHE STRING "OceanBase git tag or commit id to package")

include(cmake/FetchOceanBase.cmake)

add_subdirectory(src)

include(cmake/Pack.cmake)
