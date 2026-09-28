# Git workflow

## Get the remote

Call `artifact-get_git_token(sessionId: "<sessionId>")`. The result contains `gitRemoteUrl` and `access`.

Treat `gitRemoteUrl` as a secret. Do not echo, log, share, or commit it.

The token applies to one artifact. Your artifact access sets `access` to `ro` or `rw`.

## Change the artifact

```bash
git clone <gitRemoteUrl> my-artifact
cd my-artifact
# edit files
git add -A
git commit -m "Update artifact"
git push
```

The push updates the artifact preview.

## Recover from expiry

The token expires. You cannot renew it.

Call `artifact-get_git_token` again after a token-expired error. Then set the new remote URL.

```bash
git remote set-url origin <newGitRemoteUrl>
git push
```

Do not retry the old token.
