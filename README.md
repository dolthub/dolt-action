# Dolt Action

This GitHub Action helps mutate Dolt repos in GitHub
Action workflows.

## Example Usage

```yml
name: Test

jobs:
  hello_world_job:
    runs-on: ubuntu-latest
    name: A job to say hello
    steps:
      - name: Dolt Import
        uses: dolthub/dolt-action@v0.16
        id: 'dolt_import'
        with:
          remote: max-hoffman/dolt_action_test
          dolthub_credential: ${{ secrets.DOLTHUB_CREDENTIAL }}
          branch: 'main'
          commit_message: 'Dolt action commit'
          commit_user_email: max@dolthub.com
          commit_author: 'Max Hoffman'
          push: false
          before: |
            dolt sql -q "insert into aminals (12, 'hummingbird', 61)"
```

### Generate Auth Key with DoltHub

1. Run `ls ~/.dolt/creds` to see existing keys.
2. Run `dolt creds new` to generate a new keypair.
3. Copy the Public Key that gets printed to stdout.
4. Paste the public key into https://www.dolthub.com/settings/credentials to authorize it.
5. Run `cat ~/.dolt/creds/<new_jwt_file_that_appeared_after_step_2>.jwk`
6. In the GitHub Secrets configuration for the repository, create a new secret named `DOLTHUB_CREDENTIAL`. Paste in the JSON value from Step 5.

## Parameters

The main parameters are those involveded in configuring, pulling and
pushing a Dolt repository.

- `remote`: DoltHub, S3, GCS remote endpoint. Each has a different
    authentication technique.
- `branch`: Indicate the branch to shallow-clone.
- `before`: Bash script executed after the pull stage and before commit stage.
- `after`: Bash script executed between commit and push stages.
- `dolthub_credential`: A JWT that grants access to DoltHub remotes.
- `google_credential`: A `service_account.json` that grants access to
    Google Cloud remotes.
- `push`: Whether to persist changes or discard at the step conclusion.
- `clear` : A `dolt-action` deletes the local database during the
    cleanup step. If concatenating multiple `dolt-action` steps,
    `clear=False` will avoid unnecessarily re-cloning the database.
- `commit_` options: Automate a commit following the before script.
- `tag_` options: Tag HEAD or another ref at the end of the workflow.

Outputs:

- `commit`: If the script persisted a commit, this output stores the
    associated commit hash.
