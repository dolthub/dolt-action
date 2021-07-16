#!/bin/sh

set -eo pipefail

starting_directory=$(pwd)
doltdb="${GITHUB_WORKSPACE}/doltdb"

_main() {
    _configure
    _clone
    _before
    _commit
    _tag
    _after
    _push
    _cleanup
}

_configure() {
    user="$(stat -c "%u" $GITHUB_WORKSPACE)"
    echo $user
    #chmod +x "$(which su)"
    #su $user

    dolt config --global --add user.name "${INPUT_COMMIT_USER_NAME}"
    dolt config --global --add user.email "${INPUT_COMMIT_USER_EMAIL}"

    # DoltHub JWT
    if [ ! -z "${INPUT_DOLTHUB_CREDENTIAL}" ]; then
        echo "${INPUT_DOLTHUB_CREDENTIAL}" | dolt creds import
        echo "Authenticated DoltHub credentials"
    fi

    # AWS credentials -- set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION

    # GCP Service Account Credentials
    if [ ! -z "${INPUT_GOOGLE_CREDENTIAL}" ]; then
        echo "${INPUT_GOOGLE_CREDENTIAL}" >> /tmp/gcp_creds.json
        export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp_creds.json
        echo "Autheniticated gcloud credentials"
    fi
}

_clone () {
    if [ "${INPUT_CLEAR}" = true ]; then
        rm -rf "${doltdb}"
    fi

    if [ ! -d "${doltdb}" ]; then
        dolt clone "${INPUT_REMOTE}" -b "${INPUT_BRANCH}" "${doltdb}" \
        || dolt clone "${INPUT_REMOTE}" -b master "${doltdb}"
    fi

    cd "${doltdb}"

    current_branch="$(dolt sql -q "select active_branch()" -r csv | head -2 | tail -1)"
    target_branch="$(dolt sql -q "select count(*) from dolt_branches where name = '${INPUT_BRANCH}'" -r csv | head -2 | tail -1)"
    if [ "${current_branch}" != "${INPUT_BRANCH}" ]; then
        if [ "${target_branch}" == "0" ]; then
            echo "Creating new branch: ${INPUT_BRANCH}"
            dolt checkout -b "${INPUT_BRANCH}"
        else
            dolt checkout "${INPUT_BRANCH}"
        fi
    fi
}

_before() {
    /bin/bash -c "${INPUT_BEFORE}"
}

_commit() {
    if [ -n "${INPUT_COMMIT_MESSAGE}" ]; then
        dolt add .
        dolt status
        status="$(dolt sql -q "select * from dolt_status where staged = true limit 1" -r csv | wc -l)"
        if [ "${status}" -ge 2 ]; then
            echo "committing changes"
            dolt commit -m "${INPUT_COMMIT_MESSAGE}"
            head="$(dolt sql -q "select hashof('HEAD')" -r csv | head -2 | tail -1)"
            echo "::set-output name=commit::${head}"
        fi
    fi
}

_tag() {
    if [ -n "${INPUT_TAG_NAME}" ]; then
        echo "dolt tag configuration: name - ${INPUT_TAG_NAME}, message - ${INPUT_TAG_MESSAGE}, ref - ${INPUT_TAG_REF}"
        if [ -n "${INPUT_TAG_MESSAGE}" ]; then
            dolt tag -m "${INPUT_TAG_MESSAGE}"  "${INPUT_TAG_NAME}" "${INPUT_TAG_REF}"
        else
            dolt tag "${INPUT_TAG_NAME}" "${INPUT_TAG_REF}"
        fi
    fi
}

_after() {
    /bin/bash -c "${INPUT_AFTER}"
}


_push() {
    if [ "${INPUT_PUSH}" = true ]; then
        dolt push origin "${INPUT_BRANCH}"
    fi
}

_cleanup() {
    chmod 777 -R "${doltdb}"
    cd "${starting_directory}"
}

_force_cleanup() {
    rm -rf "${doltdb}"
    cd "${starting_directory}"
}

_main || ( _force_cleanup && false )
