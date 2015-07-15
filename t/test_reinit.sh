#!/usr/bin/env bash
# After sourcing test_init.sh,
# clone new-project and reinitialize.
source t/base.sh

test_reinit_setup() {
    source t/test_init.sh
    cd "$TEST_PREFIX"
    TEST_REPO_CLONE=`"$TEST_PREFIX"/XXXX.tmp.d`
    git clone "$TEST_REPO" "$TEST_REPO_CLONE"
}

test_reinit_setup
cd "$TEST_REPO_CLONE"
make reinit

test_reinit_teardown() {
    test_init_teardown
    rm -rf "$TEST_PROJ_CLONE"
}
# So that the base EXIT trap will run it:
teardown() { test_reinit_teardown; }
