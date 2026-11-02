# Workflows

## Create local code

1. Create and check all code in the local directory.
2. Build the `files` map from the UTF-8 text files.
3. Call `artifact-create` with `type: "import"` and `files`.
4. Return the `playgroundUrl` or `previewUrl` to the user.

## Start from a template

1. Call `artifact-list_templates` and pick the template that matches the request.
2. Call `artifact-create_from_template` with its `templateId` and an optional `name`.
3. Clone it with `artifact-get_git_token`, change it, commit, and push.
4. Return `artifactUrl` to the user.

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
