# Workflows

## Create local code

1. Create and check all code in the local directory.
2. Build the `files` map from the UTF-8 text files.
3. Call `artifact-create` with `type: "import"` and `files`.
4. Return the `playgroundUrl` or `previewUrl` to the user.

## Change an artifact

1. Get the `sessionId` from the URL or `workspace-list_artifacts()`.
2. Call `artifact-get_git_token`.
3. Clone the returned remote.
4. Edit and check the local code.
5. Commit the changes.
6. Push the commit.

## Publish an artifact

Call `artifact-publish(sessionId: "<sessionId>", mode: "webapp")` only after an explicit request.

Publishing makes the app public. Sharing the `playgroundUrl` does not need publishing.
