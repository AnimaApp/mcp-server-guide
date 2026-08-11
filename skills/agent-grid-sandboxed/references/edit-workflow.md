# MCP edit workflow

## Read before you edit

1. Call `artifact-explore` to find the files.
2. Read each file that you will change.
3. Save the returned full `revision`.
4. Pass that value to `artifact-edit` as `baseRevision`.

Do not use `HEAD` or an abbreviated revision as `baseRevision`.

## Use edit operations

- `str_replace` uses `path`, `oldText`, and `newText`.
- `write` uses `path` and complete `content`.
- `delete` uses `path`.
- `move` uses `fromPath` and `toPath`.

For `str_replace`, `oldText` must occur exactly once. Add nearby lines until the text is unique.

Set `replaceAll: true` to replace all occurrences. Set `expectedReplacements` to check the exact count.

Do not write content from a result with `truncated: true`. Read the missing ranges first.

Do not write content from a result with `deferred: true`. Read that file in a new call first.

The response budget applies to all requested files. Later files can return `deferred: true`.

The server applies operations in order. Use the new path after a prior `move` operation.

A `move` operation does not update files that import the moved file.

A `move` operation does not update relative imports inside the moved file.

Add later `str_replace` operations to update all affected imports.

The server applies all operations or none. One successful call creates one commit.

## Recover from `REVISION_CONFLICT`

The error includes `currentRevision` and `changedSinceBase`. Another edit changed the artifact.

1. Read the changed files again with `artifact-explore`.
2. Reapply your changes to the new content.
3. Use the new `revision` as `baseRevision`.
4. Call `artifact-edit` again.

Do not reuse the old `baseRevision`.
