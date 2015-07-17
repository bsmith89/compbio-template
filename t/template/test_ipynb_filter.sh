#!/usr/bin/env bash
# Initialize a new project and then try adding an ipynb.
# Make sure the filtering works.

IPYNB_SOURCE=$(dirname "$0")/notebook.ipynb

setup() {
    TEST_REPO=`mktemp -d "$TEST_PREFIX"/XXXX.tmp.d`
    git clone . "$TEST_REPO"
    cd "$TEST_REPO"  # {
    cat > requirements.txt <<EOF
ipython[notebook]
EOF
    make INITIAL_COMMIT_OPTIONS='' init
    cd - # }
    cp "$IPYNB_SOURCE" "$TEST_REPO"/ipynb/notebook.ipynb
}

teardown() {
    rm -rf "${TEST_REPO}"
}
trap teardown EXIT

setup

cd "$TEST_REPO"
cp ipynb/notebook.ipynb pre-add.ipynb
git add ipynb/notebook.ipynb
cp ipynb/notebook.ipynb post-add.ipynb
git commit -m "Committing the notebook."
cp ipynb/notebook.ipynb post-commit.ipynb
rm ipynb/notebook.ipynb
git checkout HEAD ipynb/notebook.ipynb
cp ipynb/notebook.ipynb committed.ipynb
# Pre-add shoud not differ from either post-add nor post-commit,
# but should differ from post-hard-reset
diff pre-add.ipynb post-add.ipynb
diff pre-add.ipynb post-commit.ipynb
! diff pre-add.ipynb committed.ipynb
