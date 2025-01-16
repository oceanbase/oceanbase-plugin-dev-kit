include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

add_library(ob_plugin_devkit INTERFACE)
target_include_directories(ob_plugin_devkit INTERFACE
                           $<INSTALL_INTERFACE:include>
                           $<BUILD_INTERFACE:${OCEANBASE_SOURCE_DIR}/src/plugin/include>)

target_compile_definitions(ob_plugin_devkit INTERFACE OBP_DYNAMIC_PLUGIN)
target_link_options(ob_plugin_devkit INTERFACE
                    -static-libgcc -static-libstdc++)

set (OBPLUGIN_VERSION ${PACKAGE_VERSION})
set (component_name plugin-devkit)
set (cmake_package_name ObPlugin)
set (targets_export_name ${cmake_package_name}Targets)
set (generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")
set (cmake_files_install_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${cmake_package_name}")
set (version_file "${generated_dir}/${cmake_package_name}ConfigVersion.cmake")
set (config_file "${generated_dir}/${cmake_package_name}Config.cmake")
write_basic_package_version_file (${version_file} VERSION ${OBPLUGIN_VERSION} COMPATIBILITY SameMajorVersion)
configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/lib/Config.cmake.in"
                              "${config_file}" INSTALL_DESTINATION ${cmake_files_install_dir})

install (EXPORT ${targets_export_name}
         NAMESPACE ${cmake_package_name}::
         DESTINATION ${cmake_files_install_dir}
         COMPONENT ${component_name})

install (FILES ${version_file} ${config_file}
               ${CMAKE_CURRENT_SOURCE_DIR}/lib/ob_plugin_libmain.c
               ${CMAKE_CURRENT_SOURCE_DIR}/lib/ObPluginLib.cmake
         DESTINATION ${cmake_files_install_dir}
         COMPONENT ${component_name})
install (DIRECTORY "${OCEANBASE_SOURCE_DIR}/src/plugin/include/"
         DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
         COMPONENT ${component_name})
install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/examples/"
         DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/examples/${cmake_package_name}"
         COMPONENT ${component_name})
install(TARGETS ob_plugin_devkit
        EXPORT ${targets_export_name}
        COMPONENT ${component_name})
