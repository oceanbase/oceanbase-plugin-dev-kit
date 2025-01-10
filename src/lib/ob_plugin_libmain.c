#include <unistd.h>
#include <stdio.h>
#include "oceanbase/ob_plugin.h"

#ifdef __linux__
#include <sys/utsname.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef LD_LIBRARY_PATH
const char __plugin_service_interp[] __attribute__((section(".interp"))) = LD_LIBRARY_PATH;
#endif

void __print_version(ObPluginVersion version)
{
  printf("%ld.%ld.%ld",
         version / OBP_VERSION_FIELD_NUMBER / OBP_VERSION_FIELD_NUMBER,
         version / OBP_VERSION_FIELD_NUMBER % OBP_VERSION_FIELD_NUMBER,
         version % OBP_VERSION_FIELD_NUMBER);
}

void __print_compiler_info()
{
  const char *compiled_by = "COMPILED BY: ";

#ifdef __clang__
  printf("%sclang %s\n", compiled_by, __clang__version__);
#elif defined(__GNUC__)
  printf("%sGCC %s\n", compiled_by, __VERSION__);
#else
  printf("Unknown compiler\n");
#endif
}

void __print_os_info()
{
#ifdef __linux__
  struct utsname uname_info;
  if (0 == uname(&uname_info)) {
    printf("COMPILED ON: %s %s %s %s\n",
           uname_info.sysname, uname_info.release, uname_info.version, uname_info.machine);
  }
#endif
}

void _ob_plugin_lib_main()
{
  extern const char *OBP_DYNAMIC_PLUGIN_NAME_VAR;
  extern const char *OBP_DYNAMIC_PLUGIN_BUILD_REVISION_VAR;
  extern const char *OBP_DYNAMIC_PLUGIN_BUILD_BRANCH_VAR;
  extern const char *OBP_DYNAMIC_PLUGIN_BUILD_DATE_VAR;
  extern const char *OBP_DYNAMIC_PLUGIN_BUILD_TIME_VAR;
  extern ObPlugin    OBP_DYNAMIC_PLUGIN_PLUGIN_VAR;

  ObPlugin *plugin = &OBP_DYNAMIC_PLUGIN_PLUGIN_VAR;

  printf("OceanBase Plugin Library: %s\n", OBP_DYNAMIC_PLUGIN_NAME_VAR);
  __print_compiler_info();
  __print_os_info();
  printf("\n");
  printf("AUTHOR: %s\n", plugin->author);
  printf("LIBRARY VERSION: ");
  __print_version(plugin->version);
  printf("\n");
  printf("PLUGIN API VERSION: ");
  __print_version(OBP_PLUGIN_API_VERSION_CURRENT);
  printf("\n");
  printf("LICENSE: %s\n", plugin->license);
  printf("REVISION: %s\n", OBP_DYNAMIC_PLUGIN_BUILD_REVISION_VAR);
  printf("BUILD_BRANCH: %s\n", OBP_DYNAMIC_PLUGIN_BUILD_BRANCH_VAR);
  printf("BUILD_TIME: %s %s\n", OBP_DYNAMIC_PLUGIN_BUILD_DATE_VAR, OBP_DYNAMIC_PLUGIN_BUILD_TIME_VAR);
  printf("\n");

  _exit(0);
}

#ifdef __cplusplus
} // extern "C"
#endif
