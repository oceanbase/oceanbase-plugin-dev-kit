[OceanBase](https://github.com/oceanbase/oceanbase) 插件开发包打包

使用脚本打包
```bash
cd tools
export OCEANBASE_GIT_REPO=https://github.com/oceanbase/oceanbase.git
export OCEANBASE_GIT_TAG=fts4
# build-rpm.sh <sourcepath> <package> <version> <release>
bash build-rpm.sh $PWD/.. oceanbase-plugin-dev-kit 0.1.0 1
```

使用cmake打包
```bash
mkdir build
cd build
cmake .. -DOCEANBASE_GIT_REPO=https://github.com/oceanbase/oceanbase.git -DOCEANBASE_GIT_TAG=fts4 -DPACKAGE_RELEASE=123456 -DPACKAGE_VERSION=0.1.0
cpack -G RPM
```

**NOTE**: 打包时会自动下载指定的oceanbase源码，放到 deps/oceanbase 目录下。但是如果 deps/oceanbase 已经有内容，即使目录下的代码与指定的信息不一致，那么也不会重新下载代码。
