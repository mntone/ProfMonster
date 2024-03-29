#!/bin/zsh

# Build Number Offset
INTERNAL_SHORT_VERSION_OFFSET=13

if [ "$CI" = "TRUE" ]; then
	git fetch --tags --depth 50
fi

SCRIPT_DIR=$(cd $(dirname $0); pwd)
XCCONFIG_DIR=$SCRIPT_DIR/../src/build
XCCONFIG_PATH=$XCCONFIG_DIR/Versioning.xcconfig

mkdir -p $XCCONFIG_DIR

if [ -v CI_TAG ]; then
	GIT_TAG=$CI_TAG
else
	GIT_TAG=$(git describe --tags --abbrev=0 || echo "0.8")
fi

GIT_HASH_SHORT=$(git rev-parse --short HEAD)
VERSION=$GIT_TAG-$GIT_HASH_SHORT
echo "Current version: $VERSION"

if [ "$CI" != "TRUE" ] && [ "$1" != "-f" ]; then
	CACHED_VERSION="`cat $XCCONFIG_PATH | grep -m1 'INTERNAL_VERSION' | cut -d'=' -f2 | tr -d ';' | tr -d ' '`"
	if [ "$VERSION" = "$CACHED_VERSION" ]; then
		echo "Skipped to update \"Versioning.xcconfig\"."
		exit 0
	fi
fi

GIT_HASH=$(git rev-parse HEAD)
GIT_HASH_ORIGIN=$(git rev-parse $GIT_TAG^{})
if [ "$GIT_HASH" = "$GIT_HASH_ORIGIN" ]; then
	GIT_CURRENT=$GIT_TAG
	GIT_TAG_ORIGIN=$(git describe --abbrev=0 $GIT_TAG^)
	GIT_HASH_ORIGIN=$(git rev-parse $GIT_TAG_ORIGIN^{})
else
	GIT_CURRENT=$GIT_HASH
	GIT_TAG_ORIGIN=$GIT_TAG
fi
GIT_DATE=$(git log -1 --format='%cI')

if [ "$CI" = "TRUE" ]; then
	SHORT_VERSION=$CI_BUILD_NUMBER
else
	SHORT_VERSION=$(($(git tag | wc -l | tr -d '[:space:]') + $INTERNAL_SHORT_VERSION_OFFSET))
fi

{
	echo "CURRENT_PROJECT_VERSION = $GIT_TAG;"
	echo "GIT_CURRENT             = $GIT_CURRENT;"
	echo "GIT_DATE                = $GIT_DATE;"
	echo "GIT_ORIGIN              = $GIT_TAG_ORIGIN;"
	echo "INTERNAL_VERSION        = $VERSION;"
	echo "INTERNAL_SHORT_VERSION  = $SHORT_VERSION;"
	echo "MARKETING_VERSION       = $GIT_TAG;"
} > "$XCCONFIG_PATH"
