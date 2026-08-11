# Workflows

## Create local code

1. Create all code in the current agent context.
2. Build the `files` map from the UTF-8 text files.
3. Call `artifact-create` with `type: "import"` and `files`.
4. Return the `playgroundUrl` or `previewUrl` to the user.

## Change an artifact

1. Get the `sessionId` from the URL or `workspace-list_artifacts()`.
2. Use `artifact-explore` to find and read the files.
3. Use its `revision` as the next `baseRevision`.
4. Call `artifact-edit` with an ordered change list.
5. Use the returned `revision` for the next edit.

## Publish an artifact

Call `artifact-publish(sessionId: "<sessionId>", mode: "webapp")` only after an explicit request.

Publishing makes the app public. Sharing the `playgroundUrl` does not need publishing.
