#!/bin/sh

GIT_TAG=$(git describe --tags --abbrev=0 || echo "0.8")
GIT_HASH_SHORT=$(git rev-parse --short HEAD)
VERSION=$GIT_TAG-$GIT_HASH_SHORT
echo "Current version: $VERSION"

CACHED_VERSION="`cat $SCRIPT_OUTPUT_FILE_0 | grep -m1 'CURRENT_PROJECT_VERSION' | cut -d'=' -f2 | tr -d ';' | tr -d ' '`"
if [ "$VERSION" = "$CACHED_VERSION" ]; then
	echo "Skipped to update \"versioning.xcconfig\"."
	exit 0
fi

GIT_HASH=$(git rev-parse HEAD)
GIT_DATE=$(git log -1 --format='%ci')

{
	echo "CURRENT_PROJECT_VERSION = $VERSION;"
	echo "GIT_DATE                = $GIT_DATE;"
	echo "GIT_HASH                = $GIT_HASH;"
	echo "MARKETING_VERSION       = $GIT_TAG;"
} > "$SCRIPT_OUTPUT_FILE_0"
