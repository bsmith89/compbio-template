#!/usr/bin/env bash
# Run all test scripts found recursively below $1
# Place a semaphore during testing
set -o nounset -o errexit -o pipefail

LOCKDIR=.testing
mkdir -p dirname "$LOCKDIR"
if ! mkdir "$LOCKDIR"; then
    echo "Cannot acquire lock. '$LOCKDIR' exists.  Exiting." >&2
    exit 1
fi

[ -z "$1" ] && TEST_SCRIPT_DIR="$1" || TEST_SCRIPT_DIR='.'
export TEST_START_DIR=$(pwd)
export TEST_PREFIX=$(realpath build)
# Save the original branchname so we can revert
START_BRANCH=`git rev-parse --abbrev-ref HEAD`
# Switch to a random branchname (not quite threadsafe) so we don't mess up
# history
TEST_BRANCH=$(mktemp -u _test_XXXXXXX)
# Commit everything in the working directory
git stash save --include-untracked
git checkout -B "$TEST_BRANCH"
git stash apply
git add -A
git commit --allow-empty -m "[TEST COMMIT; TO BE REMOVED]"
mkdir -p "$TEST_PREFIX"
ALL_TESTS=$(find "$TEST_SCRIPT_DIR" -name test_*)

teardown() {
    cd "$TEST_START_DIR"
    git checkout "$START_BRANCH"
    git stash pop
    git branch -D "$TEST_BRANCH"
    rm -r "$LOCKDIR"
}

trap teardown EXIT

for t in "$ALL_TESTS"; do
    echo "$t"
    bash "$t"
done
