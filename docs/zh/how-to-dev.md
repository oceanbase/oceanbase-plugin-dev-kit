---
title: 开发者文档
---

**修订记录**

| **版本** | **日期** | **变更内容** | **变更原因** |
| --- | --- | --- | --- |
| 1.0 | 2024-12-23 | | 创建 |
| 1.1 | 2025-03-04 | 下载开发套件 | 开发套件已发布 |


本篇文档介绍如何使用OceanBase的开发套件开发插件。

# 快速开始
下面以全文检索分词插件为例介绍如何开发OceanBase插件。

## 安装开发基础环境
```bash
yum install -y cmake make glibc-devel glibc-headers gcc gcc-c++
```

## 下载oceanbase plugin开发套件

```bash
yum install -y yum-utils
yum-config-manager --add-repo https://mirrors.aliyun.com/oceanbase/OceanBase.repo
yum install -y oceanbase-plugin-dev-kit
```

## 复制examples/ftparser到自己的开发目录
> 这里假设你的开发目录是 `/your/work/path`，你可以修改为自己的目录。
>

```bash
# 复制分词插件的样例代码，如果开发其它插件，需要复制其它插件的样例代码
cp -rf /usr/local/share/examples/ObPlugin/ftparser /your/work/path/ftparser
```

## 修改CMakeLists.txt
当前的工程目录下包含了CMakeLists.txt和一个CPP文件，你可以先修改 CMakeLists.txt，符合自己的需求。

CMakeLists.txt 文件中使用 "TODO" 指明了需要修改的内容，包括：

+ PLUGIN_NAME 当前插件的名字，也是项目和链接库的名称，你应该修改成自己需要的名称；
+ SOURCES 实现文件，可以是C代码文件或C++代码文件，这里是一个列表，可以写多个。当你增加了新的实现文件时，应该修改这里的代码。注意不要把头文件放到这里。

## 实现功能
接下来可以按照特定的接口来实现你的插件，每个插件都有自己特定的接口，需要按照约定来实现。各个插件接口的定义可以在 oceanbase-plugin-dev-kit 开发包中的头文件中找到，也可以参考[文档](https://hnwyllmm.github.io/oceanbase-plugin-dev-kit/doxy/html/topics.html)。

需要特别注意的是，一个链接库可以实现一到多个插件，在实现文件中定义，示例：

```c
OBP_DECLARE_PLUGIN(example_ftparser)
{
  OBP_AUTHOR_OCEANBASE,       // 作者
  OBP_MAKE_VERSION(0, 1, 0),  // 当前插件库的版本
  OBP_LICENSE_MULAN_PSL_V2,   // 该插件的license
  plugin_init, // init        // 插件的初始化函数，在plugin_init中注册各个插件功能
  nullptr, // deinit          // 插件的析构函数
} OBP_DECLARE_PLUGIN_END;
```

## 编译插件
```bash
cd /your/work/path/ftparser
mkdir -p build
cd build
cmake ..
make
```

如果不出现问题，你可以在build下找到一个动态链接库，假设名字叫 libexample_ftparser.so，稍后可以把这个链接库安装到OceanBase集群中。

## 安装测试
请参考[使用手册](./user-guide.md)。

# 说明
## 自行编写CMake/Makefile文件
开发编译插件时，仅依赖了OceanBase插件开发库中的头文件，CMake的依赖是可选项，如果需要，你可以编写自己的Makefile文件或直接用编译器编译插件库。

## oceanbase-plugin-devel 提供哪些内容
默认情况下，开发包会安装在 /usr/ 目录下，在这里可以看到

```bash
.
├── include
│   └── oceanbase
│       └── ob_plugin_xxx.h                 # 头文件
├── lib64
│   └── cmake
│       └── ObPlugin                        # CMake辅助文件
│           ├── ObPluginConfig.cmake
│           ├── ObPluginLib.cmake
│           ├── ob_plugin_libmain.c
│           └── ObPluginTargets.cmake
└── share
    └── examples
        └── ObPlugin                       # 样例代码
            └── ftparser
                ├── CMakeLists.txt
                └── space_ftparser.cpp
```



## 可执行的链接库
默认情况下，编译出来的动态链接库是可执行的，会输出编译信息、插件信息等，比如：

```cpp
OceanBase Plugin Library: example_ftparser
COMPILED BY: GCC 9.4.0
COMPILED ON: Linux 3.10.0-327.ali2019.alios7.x86_64 #1 SMP Sun Jan 19 18:21:42 CST 2020 x86_64

AUTHOR: OceanBase Corporation
LIBRARY VERSION: 1.0.0
PLUGIN API VERSION: 0.1.0
LICENSE: Mulan PSL v2
REVISION: 15ee043a402fa07390a4d0d62a26b638ec4eb7ed
BUILD_BRANCH: task/2024112500105253120
BUILD_TIME: Dec 17 2024 15:37:33
```

在编译动态链接库时，使用链接选项给链接库指定入口函数("-e,_ob_plugin_lib_main")，在代码中指定ELF interpret（可能是 /lib64/ld-linux-x86-64.so.2），这样编译的动态链接库就可以执行了。入口函数`_ob_plugin_lib_main`在 `oceanbase-plugin-devel`开发包的 `ob_plugin_libmain.c`文件中提供。

如果动态库在一个平台上编译在另一个平台上运行，但是遇到"Bad interpreter" 或 "No such file or directory"，可能是运行时平台的ELF Interpreter与编译环境上的不同，可以直接使用运行平台上的ELF Interpreter运行动态链接库：

```bash
/path/to/interpreter ./your/library
# 比如
/lib64/ld-linux-x86-64.so.2 ./libexample_ftparser.so
```



## 跨平台兼容
动态链接库通常不具备良好的跨平台兼容性，比如在高版本的操作系统上编译，在低版本的系统上运行，最常见的是libc版本不兼容。因此建议在不同的系统上，都进行一次编译。



## C++ 异常
不要抛出C++异常，OceanBase不会捕获插件库抛出的异常。



## 内存分配
OceanBase 是一个多租户系统，内存资源是受租户配置限制的，因此我们在分配内存时，是比常规的应用程序更大可能遇到内存不足分配失败的情况，所以建议分配内存后检测结果，并合理的处理错误，比如返回 OBP_ALLOCATE_MEMORY_FAILED。

可以使用系统内存分配器，比如 malloc/free，或者C++的new/delete，在new分配内存时建议使用new(std::nothrow)。也可以使用开发库提供的 obp_malloc/obp_free或 obp_allocate/obp_deallocate函数。不管使用哪种，最终分配的内存都会被统计到对应的运行时租户。

# FAQ
## 如何在插件中打印日志
可以参考插件开发库 oceanbase-plugin-devel 中的头文件 ob_plugin_log.h，使用 `OBP_LOG_TRACE`、`OBP_LOG_INFO`或`OBP_LOG_WARN`打印日志，打印风格与 `printf`类似。

## 如何链接新的链接库
在 CMakeLists.txt 中，可以使用下面的命令增加新的链接库：

```cpp
TARGET_LINK_LIBRARIES (${PLUGIN_NAME} PRIVATE library1 library2)
```

注意，新的链接库需要使用静态链接库。如果依赖动态链接库，那么在安装插件时，也需要把依赖的动态链接库安装到observer机器的系统目录。

其它的依赖项，比如链接时链接库查找目录、头文件目录、编译选项等，也可以使用 `TARGET_XXX(${PLUGIN_NAME} PRIVATE option1 option2)`添加。

## 如何不安装开发库oceanbase-plugin-dev-kit到系统目录
使用下面的命令可以将RPM包安装到当前目录的 ./usr/ 下，也就是 $PWD/usr/

```bash
# pkgname 是 oceanbase-plugin-devel 的RPM包文件名
rpm2cpio `pkgname` | cpio -ivd
```

也可以使用下面的命令安装到指定目录（需要sudo权限）：

```bash
# pkgname 是 oceanbase-plugin-dev-kit 的RPM包文件名
# /your/install/path 是你想要安装的目录
rpm -ivh `pkgname` --prefix `/your/install/path`
```

如果安装的最终路径不是系统目录，也就是不在CMake的查找列表中（参考[CMake文档](https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_PREFIX_PATH.html)），在编译执行cmake命令时需要手动指定，比如：

```bash
mkdir build
cd build
# 使用 -DCMAKE_PREFIX_PATH 参数指定安装目录
cmake -DCMAKE_PREFIX_PATH=`/oceanbase-plugin-dev-kit/install/prefix` ..
make
```

## 可以不使用开发包oceanbase-plugin-dev-kit开发插件吗
如果要基于比较新的插件接口开发，而OceanBase还没有发包，或者没有对应某个操作系统的包，也可以基于OceanBase源码开发，步骤如下：

```bash
# 下载源码
git clone https://github.com/oceanbase/oceanbase-plugin-dev-kit
# 初始化
cd oceanbase-plugin-dev-kit
# 执行安装命令，使用 --prefix 参数指定安装的目录，这里使用 build_debug/usr/local
mkdir build && cd build
cmake -DOCEANBASE_GIT_TAG=master ..
cmake --install . --prefix ./usr/local

# 编译自己的开发库
cd `/your/plugin/dev/path`
mkdir build
cd build
# 使用 -DCMAKE_PREFIX_PATH 参数指定 OceanBase插件开发库安装目录
cmake -DCMAKE_PREFIX_PATH=`/your/oceanbase-plugin-dev-kit/build/usr/local` ..
make
```

注意，基于源码开发要找稳定版本的接口或联系OceanBase开发人员。


