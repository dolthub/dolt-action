# Dolt Action

This GitHub Action plugin faciliates mutating Dolt repos in GitHub
Action workflows.

## Usage

```yml
name: Test

jobs:
  hello_world_job:
    runs-on: ubuntu-latest
    name: A job to say hello
    steps:
      - name: Dolt Import
        uses: ./ # Uses an action in the root directory
        id: 'dolt_import'
        with:
          remote: max-hoffman/dolt_action_test
          dolthub_credential: ${{ secrets.DOLTHUB_CREDENTIAL }}
          message: 'Dolt action commit'
          branch: 'master'
          commit_user_email: max@dolthub.com
          commit_author: 'Max Hoffman'
          push: false
          run: |
            dolt sql -q "insert into aminals (12, 'hummingbird', 61)"
```

## Parameters

The main parameters are those involveded in configuring, pulling and
pushing a Dolt repository.

- `remote`: DoltHub, S3, GCS remote endpoint. Each has a different
    credentialing technique.
- `branch`: Indicate the branch to shallow-clone.
- `run`: Bash script executed between pull and commit, push steps.
- `push`: Whether to persist changes or discard at the step conclusion.
- `commit_` options: Automate a commit following the run script.
- `tag_` options: Tag HEAD or another ref at the end of the workflow.


