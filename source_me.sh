
UNAME="$(uname -s)"
case "$UNAME" in
    Darwin*)  HOST=macos;;
    *)        HOST=linux;;
esac
echo "Host is $HOST"


pushd `dirname "$BASH_SOURCE"` > /dev/null

export BI_BUILDER_ROOT=`pwd`
export PATH=$BI_BUILDER_ROOT/build/${HOST}/bisdk/bin:$PATH

echo BI_BUILDER_ROOT=$BI_BUILDER_ROOT
echo PATH=$PATH

popd > /dev/null
