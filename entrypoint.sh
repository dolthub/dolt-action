#!/bin/sh

set -eox pipefail

doltdb="${GITHUB_WORKSPACE}/doltdb"

_main() {
    _configure
    _clone
    _run
    _commit
    _tag
    _push
}

_configure() {
    dolt config --global --add user.name "${INPUT_COMMIT_USER_NAME}"
    dolt config --global --add user.email "${INPUT_COMMIT_USER_EMAIL}"

    # DoltHub password
    if [ ! -z "${INPUT_DOLTHUB_CREDENTIAL}" ]; then
        echo "${INPUT_DOLTHUB_CREDENTIAL}" | dolt creds import
    fi

    # AWS
    if [ ! -z "${INPUT_AWS_CREDENTIALS}" ]; then
        echo "aws creds not properly handled yet"
    fi

    # GCP
    if [ ! -z "${INPUT_GCP_CREDENTIALS}" ]; then
        echo "gcp creds not properly handled yet"
    fi
}

_clone () {
    dolt clone "${INPUT_REMOTE}" -b "${INPUT_BRANCH}" "${doltdb}" \
        || dolt clone "${INPUT_REMOTE}" -b master "${doltdb}"
    cd "${doltdb}"

    current_branch="$(dolt sql -q "select active_branch()" -r csv | head -2 | tail -1)"
    if [ "${current_branch}" -ne "${INPUT_BRANCH}" ]; then
        dolt checkout -b "${INPUT_BRANCH}"
    fi
}

_run() {
    /bin/bash -xc "${INPUT_RUN}"
}

_commit() {
    dolt add .
    status="$(dolt sql -q "select * from dolt_status where staged = true limit 1" -r csv | wc -l)"
    if [ "${status}" -.github/workflows/test_plugin.ymlge 2 ]; then
        dolt commit -m "${INPUT_MESSAGE}"
        head="$(dolt sql -q "select hashof('HEAD')" -r csv | head -2 | tail -1)"
        echo "::set-output name=commit::${head}"
    else
      echo "dolt status is clean"
    fi
}

# TODO tagging
_tag() {
    echo "todo: tagging"
}

_push() {
    if [ "${INPUT_PUSH}" = true ]; then
        dolt push origin "${INPUT_BRANCH}"
    fi
}

_main
