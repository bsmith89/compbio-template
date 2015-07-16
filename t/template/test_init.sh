#!/usr/bin/env bash
# Clone the template and initialize it.

setup() {
    cd "$TEST_START_DIR"
    TEST_REPO=`mktemp -d "$TEST_PREFIX"/XXXX.tmp.d`
    git clone . "$TEST_REPO"
}

setup

teardown() {
    rm -rf "$TEST_REPO"
}

trap teardown EXIT

cd "$TEST_REPO"
rm requirements.txt
make INITIAL_COMMIT_OPTIONS='' init
