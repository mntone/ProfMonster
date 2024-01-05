#!/bin/sh

if [ "$CI" = "TRUE" ]; then
	git fetch origin --tags
fi

SCRIPT_DIR=$(cd $(dirname $0); pwd)
XCCONFIG_PATH=$SCRIPT_DIR/../src/App/Versioning.xcconfig

GIT_TAG=$(git describe --tags --abbrev=0 || echo "0.8")
GIT_HASH_SHORT=$(git rev-parse --short HEAD)
VERSION=$GIT_TAG-$GIT_HASH_SHORT
echo "Current version: $VERSION"

if [ "$CI" != "TRUE" ]; then
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
	GIT_ORIGIN=$(git describe --abbrev=0 --tags --exclude=$GIT_TAG)
	GIT_HASH_ORIGIN=$(git rev-parse $GIT_ORIGIN^{})
else
	GIT_CURRENT=$GIT_HASH
	GIT_ORIGIN=$GIT_TAG
fi
GIT_DATE=$(git log -1 --format='%ci')

{
	echo "CURRENT_PROJECT_VERSION = $GIT_TAG;"
	echo "GIT_CURRENT             = $GIT_CURRENT;"
	echo "GIT_DATE                = $GIT_DATE;"
	echo "GIT_HASH                = $GIT_HASH;"
	echo "GIT_HASH_ORIGIN         = $GIT_HASH_ORIGIN;"
	echo "GIT_ORIGIN              = $GIT_ORIGIN;"
	echo "INTERNAL_VERSION        = $VERSION;"
	echo "MARKETING_VERSION       = $GIT_TAG;"
} > "$XCCONFIG_PATH"
