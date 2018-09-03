
pushd `dirname "$BASH_SOURCE"` > /dev/null

export BI_BUILDER_ROOT=`pwd`
export PATH=$BI_BUILDER_ROOT/build/host/bin:$PATH

echo BI_BUILDER_ROOT=$BI_BUILDER_ROOT
echo PATH=$PATH

popd > /dev/null
