---
name: update-version
description: Bumps the my-style-gen plugin version and writes the matching changelog
  entry. Use after changing anything the plugin ships - skills/my-style-gen/, its
  references, templates or A/B assets, the plugin manifest, or the README - and whenever
  someone asks to bump the version, cut a release, or update the changelog in this
  repository.
---

# update-version

Every change to what the plugin ships gets a version bump and a changelog entry, in the
same commit as the change itself. Do it without being asked.

## What counts as a shipped change

Anything under `skills/my-style-gen/`, `.claude-plugin/plugin.json`,
`.claude-plugin/marketplace.json`, `README.md` or `LICENSE`.

Repository-internal files - `AGENTS.md`, `CLAUDE.md`, `.agents/`, `.gitignore` - do not.
Neither does the changelog itself.

## Pick the number

Semantic versioning, read from the point of view of someone who already has the skill
installed:

| Bump | When |
|---|---|
| Patch | Wording, typos, a rule clarified, a factual correction, README edits |
| Minor | A new rule, reference file, template, asset or capability; anything that changes what a generated skill contains |
| Major | The skill is renamed or split, the invocation changes, or a generated skill lands somewhere new |

Choose the higher of two when a change spans both.

## Make the edits

1. `version` in `.claude-plugin/plugin.json`. It is the only version field in the
   repository - `marketplace.json` carries none, and neither does any SKILL.md.
2. A new section at the top of `CHANGELOG.md`, directly under the intro paragraph:

   ```markdown
   ## [1.2.3] - YYYY-MM-DD

   ### Changed

   - One line per user-visible change.
   ```

   Today's date, ISO format. Keep a Changelog headings only - `Added`, `Changed`,
   `Deprecated`, `Removed`, `Fixed`, `Security` - and drop the ones with nothing under
   them.
3. A link reference at the foot of `CHANGELOG.md`, newest first:

   ```markdown
   [1.2.3]: https://github.com/marcotrinelli/my-style-gen/releases/tag/v1.2.3
   ```

Write entries for the reader who installed the skill, not the one reading the diff:
what changed for them, not which files moved. Wrap at 88 characters like the rest of the
repository's prose.

## Leave alone

Do not tag, do not push, do not open a release. Say which version you landed on and let
the user cut the release themselves.
