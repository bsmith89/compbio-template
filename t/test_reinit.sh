#!/usr/bin/env bash
# After sourcing test_init.sh,
# clone new-project and reinitialize.
source t/base.sh

setup() {
    TEST_REPO=`mktemp -d "$TEST_PREFIX"/XXXX.tmp.d`
    git clone . "$TEST_REPO"
    cd "$TEST_REPO"  # {
    rm requirements.txt
    make INITIAL_COMMIT_OPTIONS='' init
    cd "$TEST_START_DIR" # }
    TEST_REPO_CLONE=`mktemp -d "$TEST_PREFIX"/XXXX.tmp.d`
    git clone "$TEST_REPO" "$TEST_REPO_CLONE"
}

setup
cd "$TEST_REPO_CLONE"  # {
make reinit
cd "$TEST_START_DIR"  # }

teardown() {
    rm -rf "$TEST_REPO_CLONE" "$TEST_REPO"
}
