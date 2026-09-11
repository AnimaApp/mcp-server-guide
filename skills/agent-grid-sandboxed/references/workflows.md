# Workflows

## Create local code

1. Create all code in the current agent context.
2. Build the `files` map from the UTF-8 text files.
3. Call `artifact-create` with `files`. Do not pass `type` on the sandboxed surface.
4. Return `artifactUrl` to the user.

## Create a knowledge artifact

1. Call `artifact-create_knowledge` with no arguments or an optional `name`.
2. Return `artifactUrl` to the user.
3. Use the returned `revision` as `baseRevision` if you edit it next.

## Change an artifact

1. Get the `sessionId` from the URL or `workspace-list_artifacts()`.
2. Use `artifact-explore` to find and read the files.
3. Use its `revision` as the next `baseRevision`.
4. Call `artifact-edit` with an ordered change list.
5. Use the returned `revision` for the next edit.

## Address review comments

1. Call `review-list`, optionally with the artifact's `sessionId`.
2. Read the comment replies and inspect the anchored content.
3. Make the requested changes with `artifact-edit`.
4. Copy the addressed comments' `resolveTrailer` lines into `commitMessage`.
5. Use `review-reply` instead when the discussion or another party's work must remain open.

## Publish an artifact

Call `artifact-publish(sessionId: "<sessionId>", mode: "webapp")` only after an explicit request.

Publishing makes the app public. Sharing the `playgroundUrl` does not need publishing.
