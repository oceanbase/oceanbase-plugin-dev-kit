SET (_TEST_COMPILE_OPTIONS
     -g
     # -fno-exceptions # plugin library should be able to catch exceptions
     -fcolor-diagnostics
     -fdiagnostics-color=auto
     -fmax-type-align=8
     -fno-omit-frame-pointer
     -Wall -Wextra)

SET (_PLUGIN_C_FLAGS)
SET (_PLUGIN_CXX_FLAGS)

INCLUDE (CheckCCompilerFlag)
INCLUDE (CheckCXXCompilerFlag)
FOREACH (_TEST_COMPILE_OPTION ${_TEST_COMPILE_OPTIONS})
  STRING(REGEX REPLACE "[-.+/:= ]" "_" _FLAG_ESC "${_TEST_COMPILE_OPTION}")
  CHECK_C_COMPILER_FLAG("${_TEST_COMPILE_OPTION}" _HAVE_C_COMPILE_OPTION_${_FLAG_ESC})
  IF (_HAVE_C_COMPILE_OPTION_${_FLAG_ESC})
    SET (_PLUGIN_C_FLAGS "${_PLUGIN_C_FLAGS} ${_TEST_COMPILE_OPTION}")
  ENDIF()
  CHECK_CXX_COMPILER_FLAG("${_TEST_COMPILE_OPTION}" _HAVE_CXX_COMPILE_OPTION_${_FLAG_ESC})
  IF (_HAVE_CXX_COMPILE_OPTION_${_FLAG_ESC})
    SET (_PLUGIN_CXX_FLAGS "${_PLUGIN_CXX_FLAGS} ${_TEST_COMPILE_OPTION}")
  ENDIF()
ENDFOREACH()

GET_PROPERTY (_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
IF ("CXX" IN_LIST _ENABLED_LANGUAGES)
  SET(CMAKE_CXX_STANDARD 11)
  SET(_CXX_LANGUAGE_ENABLED ON)
  MESSAGE (STATUS "Use 11 as the default cxx standard.")
ELSE()
  SET(_CXX_LANGUAGE_ENABLED OFF)
ENDIF()

EXECUTE_PROCESS(
  COMMAND sh -c "git rev-parse HEAD"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_QUIET
  RESULT_VARIABLE _GIT_REVISION_COMMAND_RESULT
  OUTPUT_VARIABLE _GIT_REVISION)
EXECUTE_PROCESS(
  COMMAND sh -c "git rev-parse --abbrev-ref HEAD"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_QUIET
  RESULT_VARIABLE _GIT_BRANCH_COMMAND_RESULT
  OUTPUT_VARIABLE _GIT_BRANCH)

IF (EXISTS ${CMAKE_CURRENT_LIST_DIR}/ob_plugin_libmain.c)
  SET (_OB_PLUGIN_LIBMAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/ob_plugin_libmain.c)
ENDIF()

FUNCTION (get_ld_library_path)
  # get the ld library path
  # Compile an executable file and use `readelf` to get the ld library path
  # @return _LD_LIBRARY_PATH
  SET (_LD_LIBRARY_PATH "" PARENT_SCOPE)

  SET (_TMP_PATH "${CMAKE_BINARY_DIR}/ld_library_tmp")
  SET (_TMP_SOURCE_CONTENT "int main() {return 0;}")
  FILE (WRITE "${_TMP_PATH}/tmp_source.c" "${_TMP_SOURCE_CONTENT}")
  TRY_COMPILE(_TMP_COMPILE_RESULT "${_TMP_PATH}/" "${_TMP_PATH}/tmp_source.c"
              COPY_FILE "${_TMP_PATH}/tmp.out")

  IF (NOT _TMP_COMPILE_RESULT)
    MESSAGE (WARNING "Failed to get ld library path: compile failed. The library will not be executabled")
    RETURN()
  ENDIF()

  EXECUTE_PROCESS (COMMAND sh -c "readelf -l ${_TMP_PATH}/tmp.out | grep --max-count=1 --color=never -oP \"(?<=Requesting program interpreter: )(.+)(?=])\""
      # COMMAND_ECHO STDOUT
      OUTPUT_STRIP_TRAILING_WHITESPACE
      RESULT_VARIABLE _LD_LIBRARY_RESULT
      OUTPUT_VARIABLE _LD_LIBRARY_PATH)

  MESSAGE (DEBUG "ld library path result is " ${_LD_LIBRARY_RESULT})
  IF (_LD_LIBRARY_RESULT EQUAL 0)
    MESSAGE(STATUS "The ld-library is " ${_LD_LIBRARY_PATH})
    SET (_LD_LIBRARY_PATH ${_LD_LIBRARY_PATH} PARENT_SCOPE)
  ELSE()
    MESSAGE(WARNING "Failed to get _LD_LIBRARY_PATH: " ${_LD_LIBRARY_RESULT} ". The library will not be executabled")
  ENDIF()

  FILE (REMOVE_RECURSE ${_TMP_PATH})
ENDFUNCTION(get_ld_library_path)

get_ld_library_path()
MESSAGE (DEBUG "_LD_LIBRARY_PATH is " ${_LD_LIBRARY_PATH})

# OB_ADD_PLUGIN(plugin sources... options/keywords...)
MACRO(OB_ADD_PLUGIN plugin_arg)
  SET(PLUGIN_OPTIONS
      MODULE          # build only as shared library
     )

  SET(PLUGIN_ONE_VALUE_KW
      # MODULE_OUTPUT_NAME
     )
  SET(PLUGIN_MULTI_VALUE_KW
      # If you need variables below, you can use statements such as
      # TARGET_INCLUDE_DIRECTORIES(target dir1 dir2) which `target` is the lower name of the first argument
      # INCLUDE_DIRECTORIES
      # LINK_LIBRARIES # lib1 ... libN
     )

  CMAKE_PARSE_ARGUMENTS(ARG
    "${PLUGIN_OPTIONS}"
    "${PLUGIN_ONE_VALUE_KW}"
    "${PLUGIN_MULTI_VALUE_KW}"
    ${ARGN}
    )

  SET(plugin ${plugin_arg})
  SET(SOURCES ${ARG_UNPARSED_ARGUMENTS})


  SET (target ${plugin})

  ADD_LIBRARY(${target} SHARED ${SOURCES})
  TARGET_COMPILE_DEFINITIONS (${target} PRIVATE OBP_DYNAMIC_PLUGIN)

  IF (_GIT_REVISION_COMMAND_RESULT EQUAL 0)
    TARGET_COMPILE_DEFINITIONS (${target} PRIVATE BUILD_REVISION="${_GIT_REVISION}")
  ENDIF ()
  IF (_GIT_BRANCH_COMMAND_RESULT EQUAL 0)
    TARGET_COMPILE_DEFINITIONS (${target} PRIVATE BUILD_BRANCH="${_GIT_BRANCH}")
  ENDIF ()

  IF (NOT "x${_LD_LIBRARY_PATH}" STREQUAL "x" AND _OB_PLUGIN_LIBMAIN_FILE)
    MESSAGE (DEBUG "library path is " "x${_LD_LIBRARY_PATH}")
    TARGET_COMPILE_DEFINITIONS (${target} PRIVATE LD_LIBRARY_PATH="${_LD_LIBRARY_PATH}")
    TARGET_LINK_OPTIONS (${target} PRIVATE LINKER:-e,_ob_plugin_lib_main)
    TARGET_SOURCES (${target} PRIVATE ${_OB_PLUGIN_LIBMAIN_FILE})
  ENDIF()

  TARGET_LINK_LIBRARIES (${target} PRIVATE ObPlugin::ob_plugin_devkit)
  SET (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${_PLUGIN_C_FLAGS}")
  SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${_PLUGIN_CXX_FLAGS}")
  MESSAGE (STATUS "CMAKE_C_FLAGS is " ${CMAKE_C_FLAGS})
  MESSAGE (STATUS "CMAKE_CXX_FLAGS is " ${CMAKE_CXX_FLAGS})

  SET_TARGET_PROPERTIES(${target} PROPERTIES
                        C_VISIBILITY_PRESET hidden
                        CXX_VISIBILITY_PRESET hidden
                        VISIBILITY_INLINES_HIDDEN 1
                        POSITION_INDEPENDENT_CODE ON)


  SET (ARG_MODULE_OUTPUT_NAME ${target})

  SET_TARGET_PROPERTIES(${target} PROPERTIES OUTPUT_NAME "${ARG_MODULE_OUTPUT_NAME}")

  IF (ARG_LINK_LIBRARIES)
    TARGET_LINK_LIBRARIES(${target} PUBLIC ${ARG_LINK_LIBRARIES})
  ENDIF(ARG_LINK_LIBRARIES)

ENDMACRO(OB_ADD_PLUGIN)
