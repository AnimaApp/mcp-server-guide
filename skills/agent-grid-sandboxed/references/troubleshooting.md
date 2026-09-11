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

Do not pass `type: "import"`. The sandboxed tool supplies that value and does not expose a `type` parameter.

## The workspace list is empty or missing an artifact

The list is a bounded sweep of artifacts readable under the current consent grant, not a complete inventory. Report what the tool returned. If the human expected more, they must widen the grant; there is no other workspace parameter to try.

## A duplicate call lost its response

Call `workspace-list_artifacts()` before you retry. The first call can create the copy.

## A published artifact cannot be deleted

Call `artifact-unpublish`. Then call `artifact-delete` again.
