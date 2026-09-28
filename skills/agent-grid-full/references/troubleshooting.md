# Troubleshooting

## The Git token expired

Call `artifact-get_git_token` again. Set `origin` to the new `gitRemoteUrl`. Then push again.

## Git reports read-only access

Check the `access` value. Ask the user for write access when the value is `ro`.

## The create call rejects `files`

Make sure every value contains UTF-8 text. The limit is 1000 files and 10 MB of decoded text.

## A duplicate call lost its response

Call `workspace-list_artifacts()` before you retry. The first call can create the copy.

## A published artifact cannot be deleted

Call `artifact-unpublish`. Then call `artifact-delete` again.
