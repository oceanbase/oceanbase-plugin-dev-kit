#!/bin/bash
# Usage: build-rpm.sh <sourcepath> <package> <version> <release>

if [ $# -ne 4 ]
then
    echo "Usage: build-rpm.sh <sourcepath> <package> <version> <release>"
    exit 1
else
    CURDIR=$PWD
    TOP_DIR=`pwd`/../
    REDHAT=$(grep -Po '(?<=release )\d' /etc/redhat-release)
    ID=$(grep -Po '(?<=^ID=).*' /etc/os-release | tr -d '"')
    PACKAGE_VERSION=${3}
    if [[ "${ID}"x == "alinux"x ]]; then
	      RELEASE="$4.al8"
    else
        RELEASE="$4.el${REDHAT}"
    fi

    export BUILD_NUMBER=${4}
fi

GIT_REPO_ARG=""
GIT_TAG_ARG=""
if [ -n "$OCEANBASE_GIT_REPO" ]; then
  GIT_REPO_ARG="-DOCEANBASE_GIT_REPO=${OCEANBASE_GIT_REPO}"
fi

if [ -n "$OCEANBASE_GIT_TAG" ]; then
  GIT_TAG_ARG="-DOCEANBASE_GIT_TAG=${OCEANBASE_GIT_TAG}"
fi

echo "[BUILD] args: TOP_DIR=${TOP_DIR} RELEASE=${RELEASE} BUILD_NUMBER=${BUILD_NUMBER}"

cd ${TOP_DIR}

# comment dep_create to prevent t-abs from involking it twice.
rm -rf deps/oceanbase
mkdir -p build &&
  cd build &&
  cmake --debug-output --log-level=TRACE ${GIT_REPO_ARG} ${GIT_TAG_ARG} -DBUILD_NUMBER=$BUILD_NUMBER -DPACKAGE_VERSION=${PACKAGE_VERSION} -DCPACK_RPM_PACKAGE_RELEASE=$RELEASE .. &&
  cpack -G RPM &&
  mv *.rpm $CURDIR
