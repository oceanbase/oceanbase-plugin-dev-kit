---
title: 如何打包
---

**修订记录**

| **版本** | **日期** | **变更内容** | **变更原因** |
| --- | --- | --- | --- |
| 1.0 | 2025-02-17 | | 创建 |

# 说明
开发包打包后可以发布到yum、deb源，开发者可以直接下载开发包后开发。

这里使用了CMake/CPack程序进行打包，可以根据需求打包出RPM、DEB安装包。

# 打包
提供了两种打包的方法，一种是使用脚本打包，一个是直接使用cmake命令打包。

打包需要的参数是类似的，需要指定
- OceanBase源码仓库的地址(`OCEANBASE_GIT_REPO`)；
- OceanBase源码分支、TAG或Commit Id其中之一(`OCEANBASE_GIT_TAG`)；
- 版本号(`PACKAGE_VERSION`)；
- RELEASE 编号(`PACKAGE_RELEASE`)。同一个版本可以发布多次，使用这个编号来区分。

## 使用脚本打包
```bash
cd tools
export OCEANBASE_GIT_REPO=https://github.com/oceanbase/oceanbase.git
export OCEANBASE_GIT_TAG=fts4
# build-rpm.sh <sourcepath> <package> <version> <release>
bash build-rpm.sh $PWD/.. oceanbase-plugin-dev-kit 0.1.0 1
```

## 使用cmake打包
```bash
mkdir build
cd build
cmake .. -DOCEANBASE_GIT_REPO=https://github.com/oceanbase/oceanbase.git -DOCEANBASE_GIT_TAG=fts4 -DPACKAGE_RELEASE=123456 -DPACKAGE_VERSION=0.1.0
cpack -G RPM
```

**NOTE**: 打包时会自动下载指定的oceanbase源码，放到 deps/oceanbase 目录下。但是如果 deps/oceanbase 已经有内容，即使目录下的代码与指定的信息不一致，那么也不会重新下载代码。
