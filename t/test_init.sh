#!/usr/bin/env bash
# Clone the template and initialize it.
source t/base.sh

setup() {
    TEST_REPO=`mktemp -d "$TEST_PREFIX"/XXXX.tmp.d`
    git clone . "$TEST_REPO"
}

setup
cd "$TEST_REPO"  # {
rm requirements.txt
make INITIAL_COMMIT_OPTIONS='' init
cd "$TEST_START_DIR" # }

teardown() {
    rm -rf "${TEST_REPO}"
}
