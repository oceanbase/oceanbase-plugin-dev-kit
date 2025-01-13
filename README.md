[OceanBase](https://github.com/oceanbase/oceanbase) 插件开发包打包

使用脚本打包
```bash
cd tools
export OCEANBASE_GIT_REPO=git@gitlab.oceanbase-dev.com:oceanbase/oceanbase.git
export OCEANBASE_GIT_TAG=fts4
# build-rpm.sh <sourcepath> <package> <version> <release>
bash build-rpm.sh $PWD/.. oceanbase-plugin-dev-kit 0.1.0 1
```

使用cmake打包
```bash
mkdir build
cd build
cmake .. -DOCEANBASE_GIT_REPO=git@gitlab.oceanbase-dev.com:oceanbase/oceanbase.git -DOCEANBASE_GIT_TAG=fts4
cpack -G RPM
```
