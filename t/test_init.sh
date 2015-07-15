#!/usr/bin/env bash
# Clone the template and initialize it.
source t/base.sh


test_init_setup() {
    TEST_REPO=`mktemp -d "$TEST_PREFIX"/XXXX.tmp.d`
    git clone . "$TEST_REPO"
}

test_init_setup
cd "$TEST_REPO"
rm requirements.txt
make INITIAL_COMMIT_OPTIONS='' init

test_init_teardown() {
    cd "$TEST_START_DIR"
    rm -rf "${TEST_REPO}"
}
# So the base EXIT trap will run it:
teardown() { test_init_teardown; }
