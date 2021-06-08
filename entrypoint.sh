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

    # AWS credentials -- set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION

    # GCP
    if [ ! -z "${INPUT_GCP_CREDENTIALS}" ]; then
        #echo "${INPUT_GCP_CREDENTIALS}" | gcloud auth activate-service-account --key-file /dev/stdin
        echo "${INPUT_GCP_CREDENTIALS}" >> /tmp/gcp_creds.json
        export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp_creds.json
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
    if [ -n "${INPUT_COMMIT_MESSAGE}" ]; then
        dolt add .
        status="$(dolt sql -q "select * from dolt_status where staged = true limit 1" -r csv | wc -l)"
        if [ "${status}" -ge 2 ]; then
            dolt commit -m "${INPUT_COMMIT_MESSAGE}"
            head="$(dolt sql -q "select hashof('HEAD')" -r csv | head -2 | tail -1)"
            echo "::set-output name=commit::${head}"
        else
          echo "dolt status is clean"
        fi
    fi
}

_tag() {
    if [ -n "${INPUT_TAG_NAME}" ]; then
        if [ -n "${INPUT_TAG_MESSAGE}" ]; then
            dolt tag -m "${INPUT_TAG_MESSAGE}"  "${INPUT_TAG_NAME}" "${INPUT_TAG_REF}"
        else
            dolt tag "${INPUT_TAG_NAME}" "${INPUT_TAG_REF}"
        fi
    fi
}

_push() {
    if [ "${INPUT_PUSH}" = true ]; then
        dolt push origin "${INPUT_BRANCH}"
    fi
}

_main
