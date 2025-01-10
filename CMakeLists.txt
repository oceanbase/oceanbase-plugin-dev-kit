cmake_minimum_required(VERSION 3.20)

if (NOT DEFINED PACKAGE_VERSION)
  set (PACKAGE_VERSION 0.1.0)
endif()

project("oceanbase-plugin-dev-kit"
        VERSION ${PACKAGE_VERSION}
        DESCRIPTION "OceanBase Plugin Development Kit"
        LANGUAGES C CXX ASM)

include(cmake/FetchOceanBase.cmake)

add_subdirectory(src)

include(cmake/Pack.cmake)
