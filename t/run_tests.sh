#!/usr/bin/env bash
# Run all test scripts found recursively below $1
# Place a semaphore during testing
set -o nounset -o errexit -o pipefail

if [ -z "${1:-}" ]; then
    TEST_SCRIPT_DIR='.'
else
    TEST_SCRIPT_DIR="$1"
    [ -d "$TEST_SCRIPT_DIR" ]
fi

setup() {
    LOCKDIR=.testing
    mkdir -p $(dirname "$LOCKDIR")
    if ! mkdir "$LOCKDIR"; then
        echo "Cannot acquire testing lock. '$LOCKDIR' exists.  Exiting." >&2
        exit 1
    fi

    export TEST_START_DIR=$(pwd)
    export TEST_PREFIX=$(realpath build)
    # Save the original branchname so we can revert
    START_BRANCH=`git rev-parse --abbrev-ref HEAD`
    # Switch to a random branchname (not quite threadsafe) so we don't mess up
    # history
    TEST_BRANCH=$(mktemp -u _test_XXXXXXX)

    git add -A
    git commit --allow-empty --quiet -m "[TEST COMMIT; TO BE REMOVED]"
    git checkout -B --quiet "$TEST_BRANCH"

    mkdir -p "$TEST_PREFIX"
    ALL_TESTS=$(find "$TEST_SCRIPT_DIR" -name test_*)
}

setup

teardown() {
    cd "$TEST_START_DIR"
    git reset --quiet --hard HEAD
    git checkout --quiet "$START_BRANCH"
    git reset --quiet HEAD^
    git branch --quiet -D "$TEST_BRANCH"
    rm -r "$LOCKDIR"
}

trap teardown EXIT

for t in $ALL_TESTS; do
    bash "$t"
done
