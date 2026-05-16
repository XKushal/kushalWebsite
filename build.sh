#!/bin/bash

set -m

fail() {
    echo "Build failed"
    exit 1
}

tw() {
    echo "Building Tailwind CSS to dist/index.css"
    pnpm tailwindcss -i ./src/index.css -o ./dist/index.css --minify || fail
}

html() {
    echo "Building HTML files to dist"
    if [ -n "$VIRTUAL_ENV" ]; then
        python src/build.py --output dist --no-clean || fail
    elif command -v uv >/dev/null 2>&1; then
        uv run python src/build.py --output dist --no-clean || fail
    elif [ -x .venv/bin/python ]; then
        .venv/bin/python src/build.py --output dist --no-clean || fail
    else
        python3 src/build.py --output dist --no-clean || fail
    fi
}

static() {
    for ent in public/*; do
        echo "Copying $ent to dist/${ent##*/}"
        cp -r $ent dist/${ent##*/} || fail
    done
}

opt_imgs() {
    # ./src/optimize-images.sh || fail
    if [ -n "$VIRTUAL_ENV" ]; then
        python src/optimize_images.py || fail
    elif command -v uv >/dev/null 2>&1; then
        uv run python src/optimize_images.py || fail
    elif [ -x .venv/bin/python ]; then
        .venv/bin/python src/optimize_images.py || fail
    else
        python3 src/optimize_images.py || fail
    fi
}

my_wait() {
    local failed=0
    local pids=("$@")

    # If no PIDs are provided, get all background job PIDs
    if [ ${#pids[@]} -eq 0 ]; then
        pids=($(jobs -p))
    fi

    for pid in "${pids[@]}"; do
        wait "$pid"
        if [ $? -ne 0 ]; then
            failed=1
        fi
    done

    if [ $failed -eq 1 ]; then
        fail
    fi
}

html_static() {
    html &
    hpid=$!

    static

    my_wait $hpid

    opt_imgs
}

rm -rf dist && mkdir dist

tw &
html_static &

my_wait
