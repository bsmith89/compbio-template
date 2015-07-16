#!/usr/bin/env bash
# Set flags to make an effective test script.
# Make a commit of the current repository state
# (so you can test before you commit for real).
# Setup a trap to revert the commit.
set -o nounset -o errexit -o pipefail

TEST_BRANCH_NAME=_test
TEST_TEARDOWN=teardown
TEST_START_DIR=`pwd`
TEST_PREFIX="$TEST_START_DIR"/build

base_setup() {
    cd "$TEST_START_DIR"
    TEST_START_BRANCH=`git rev-parse --abbrev-ref HEAD`
    git stash save --include-untracked
    git checkout -B "$TEST_BRANCH_NAME"
    git stash apply
    git add -A
    git commit -m "[TEST COMMIT; TO BE REMOVED]"
    mkdir -p "$TEST_PREFIX"
}

function_exists() {
    declare -f $1 > /dev/null
    return $?
}

base_teardown() {
    cd "$TEST_START_DIR"
    git checkout "$TEST_START_BRANCH"
    git stash pop
    git branch -D "$TEST_BRANCH_NAME"
    function_exists "$TEST_TEARDOWN" && "$TEST_TEARDOWN"
}

trap base_teardown EXIT
base_setup
