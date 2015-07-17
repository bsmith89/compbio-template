#!/usr/bin/env bash
# After sourcing test_init.sh,
# clone new-project and reinitialize.

setup() {
    cd "$TEST_START_DIR"
    TEST_REPO=`mktemp -d "$TEST_PREFIX"/XXXX.tmp.d`
    git clone . "$TEST_REPO"
    cd "$TEST_REPO"  # {
    rm requirements.txt
    make INITIAL_COMMIT_OPTIONS='' init
    TEST_REPO_CLONE=`mktemp -d "$TEST_PREFIX"/XXXX.tmp.d`
    git clone "$TEST_REPO" "$TEST_REPO_CLONE"
    cd "$TEST_REPO_CLONE"
}

teardown() {
    rm -rf "$TEST_REPO_CLONE" "$TEST_REPO"
}
trap teardown EXIT

setup

make reinit
