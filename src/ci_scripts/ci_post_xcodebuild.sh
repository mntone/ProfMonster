#!/bin/zsh

LATEST_RELEASES=$(curl -s -L \
	-H "Accept: application/vnd.github+json" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/repos/mntone/ProfMonster/releases?per_page=3")

getSection() {
	local TOTAL_LINE=$(printf '%s' $2 | wc -l)
	local START=$(printf '%s' $2 | grep -n "## <!--$1-->" | head -n 1 | cut -d ':' -f1)
	if [ "$3" = "YES" ]; then
		START=$(($START + 1))
	fi
	local TAIL_LINE=$(($TOTAL_LINE - $START + 1))
	local END=$(printf '%s' $2 | tail -n $TAIL_LINE | grep -n '^## ' | head -n 1 | cut -d ':' -f1)
	if [ "$END" = "" ]; then
		END=$(($TAIL_LINE + 1))
	fi
	local RESULT=$(printf '%s' $RELEASE_NOTE_T0 | head -n $(($START + $END - 1)) | tail -n $END | perl -pe "s/^## <!--$1-->(.+?)$/[\$1]/")
	echo "$RESULT"
}

VERSION_0=$(printf '%s' "$LATEST_RELEASES" | jq -r '.[0].name')
RELEASE_NOTE_T0=$(printf '%s' "$LATEST_RELEASES" | jq -r '.[0].body' | tr -d '\r')
RELEASE_NOTE_0=$(printf '%s' $RELEASE_NOTE_T0 | head -n $(($(printf '%s' $RELEASE_NOTE_T0 | grep -n '## ' | head -n 1 | cut -d ':' -f1) - 2)) | perl -pe 's/\b([a-f0-9]{7})[a-f0-9]{33}\b/$1/ge')

MESSAGE=`getSection "MESSAGE" "$RELEASE_NOTE_T0" | grep -v '^[[:space:]]*$'`
KNOWN_ISSUES=`getSection "KNOWN_ISSUES" "$RELEASE_NOTE_T0" "YES" | perl -pe 's/^###\s+(.+?)$/$1/'`

VERSION_1=$(printf '%s' "$LATEST_RELEASES" | jq -r '.[1].name')
RELEASE_NOTE_T1=$(printf '%s' "$LATEST_RELEASES" | jq -r '.[1].body')
RELEASE_NOTE_1=$(printf '%s' $RELEASE_NOTE_T1 | head -n $(($(printf '%s' $RELEASE_NOTE_T1 | grep -n '## ' | head -n 1 | cut -d ':' -f1) - 2)) | perl -pe 's/\b([a-f0-9]{7})[a-f0-9]{33}\b/$1/ge')

VERSION_2=$(printf '%s' "$LATEST_RELEASES" | jq -r '.[2].name')
RELEASE_NOTE_T2=$(printf '%s' "$LATEST_RELEASES" | jq -r '.[2].body')
RELEASE_NOTE_2=$(printf '%s' $RELEASE_NOTE_T2 | head -n $(($(printf '%s' $RELEASE_NOTE_T2 | grep -n '## ' | head -n 1 | cut -d ':' -f1) - 2)) | perl -pe 's/\b([a-f0-9]{7})[a-f0-9]{33}\b/$1/ge')

RELEASE_NOTES=$(cat << EOS
$MESSAGE

[Release Notes]
$VERSION_0
$RELEASE_NOTE_0

$VERSION_1
$RELEASE_NOTE_1

$VERSION_2
$RELEASE_NOTE_2

[Known Issues]
$KNOWN_ISSUES
EOS
)

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
	TESTFLIGHT_DIR_PATH=../TestFlight
	mkdir $TESTFLIGHT_DIR_PATH
	echo "$RELEASE_NOTES" >! $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
else
	echo $RELEASE_NOTES
fi
