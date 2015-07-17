setup() {
    if make --question NOTE.html; then
        make NOTE.html
    fi
    BIB="$TEST_OUT_DIR"/external.bib
    touch "$BIB"
}

setup

make --question NOTE.html
! make --question --what-if=NOTE.md NOTE.html
! make --question --what-if="$BIB" EXTERNAL_BIBS="$BIB" NOTE.html
