# Troubleshooting

## The read result is truncated

Read one file with an explicit `range`. Do not send partial content to a `write` operation.

## The read result is deferred

Read the deferred file in a new call. Do not send unseen content to a `write` operation.

## The edit returns `REVISION_CONFLICT`

Read the listed files again. Use the new `revision` as `baseRevision`. Then rebuild the edit.

## A replacement is not unique

Add nearby exact lines to `oldText`. Or use `replaceAll` with `expectedReplacements`.

## The create call rejects `files`

Make sure every value contains UTF-8 text; `artifact-create` cannot take binary files. Inline projects are limited to roughly 100 KB of decoded text, and there is no ZIP or external-upload path.

## A duplicate call lost its response

Call `workspace-list_artifacts()` before you retry. The first call can create the copy.

## A published artifact cannot be deleted

Call `artifact-unpublish`. Then call `artifact-delete` again.
