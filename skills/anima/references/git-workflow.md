# Git workflow

Every artifact is a real git repository. Cloning and pushing is the **only** supported way to change an artifact's content — not browser automation, not re-generating it.

## Getting a remote

```
artifact-get_git_token(sessionId: "mr25vsjppVtbMx")
→ { gitRemoteUrl: "https://<token>@..." }
```

```bash
anima get-git-token https://app.agentgrid.io/artifacts/mr25vsjppVtbMx
```

The CLI accepts a full artifact URL or a bare session id.

## Edit and push

```bash
git clone <gitRemoteUrl> my-artifact
cd my-artifact
# make changes
git add -A && git commit -m "Update hero copy"
git push
```

Pushing updates the live artifact immediately.

## Token rules

- The token is **embedded in the URL**. Treat `gitRemoteUrl` as a secret: don't echo it, log it, paste it into chat, or commit it.
- Lifetime is `ttlSeconds` — default and maximum **3600** (1 hour), minimum **300**.
- Access is read-only or read-write depending on your access to the artifact.
- **Tokens cannot be renewed.** When git reports an expired token, mint a fresh one and repoint the remote:

```bash
git remote set-url origin <new gitRemoteUrl>
git push
```

## After creating an artifact

`artifact-create` with type `empty` or `import` already returns a `gitRemoteUrl` with a read-write token in the same response. Use it directly — calling `artifact-get_git_token` right after a create is a wasted round trip.

## Choosing a starting point

| Situation | Type | Then |
|---|---|---|
| You have code on disk | `import` (`--from`) | Clone the returned remote to keep working |
| You want to push from an existing local repo | `empty` | Add the remote and push |
| You want Agent Grid to write the first version | `p2c` / `l2c` / `f2c` | Wait for `ready`, then `artifact-get_git_token` |

For `empty`, `framework` is required — declare `react` if you'll push React code, `html` otherwise.

## Finding the artifact

If you have a URL, the `sessionId` is the last path segment. If you don't, list them:

```
workspace-list_artifacts()
```

```bash
anima list
```
