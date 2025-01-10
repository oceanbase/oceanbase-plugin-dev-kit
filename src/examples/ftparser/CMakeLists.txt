CMAKE_MINIMUM_REQUIRED(VERSION 3.22)

# TODO set `PLUGIN_NAME` to yours
SET(PLUGIN_NAME example_ftparser)

# TODO The list below are your implementention files
SET(SOURCES
    space_ftparser.cpp)

# You also should set the information below
PROJECT(${PLUGIN_NAME}
        DESCRIPTION "OceanBase ftparser plugin example"
        HOMEPAGE_URL "https://open.oceanbase.com/"
        LANGUAGES CXX C ASM) # remove CXX if this is a pure C project


# Don't touch me
FIND_PACKAGE(ObPlugin REQUIRED)

# Macro OB_ADD_PLUGIN is defined in ObPluginConfig.cmake which provided by oceanabse-plugin-devel
OB_ADD_PLUGIN(${PLUGIN_NAME}
  ${SOURCES}
)

# TARGET_INCLUDE_DIRECTORIES (${PLUGIN_NAME} PRIVATE include1 include2)
# TARGET_LINK_LIBRARIES (${PLUGIN_NAME} PRIVATE library1 library2)
# TARGET_XX (${PLUGIN_NAME} PRIVATE xxx)
