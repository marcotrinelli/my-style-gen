# AGENTS.md

`my-style-gen` is a single skill, installable into any agent that reads skills and
packaged as a Claude Code plugin as well. It reads material one person authored and
writes an installable `my-style` skill in return. The repository is prose and JSON -
there is no build, no test suite and no runtime.

## Layout

| Path | What it is |
|---|---|
| `skills/my-style-gen/SKILL.md` | The skill itself - the thing that ships |
| `skills/my-style-gen/references/` | Loaded on demand by the skill, one file per topic |
| `skills/my-style-gen/assets/` | Templates and the A/B harness, copied or run, never loaded as context |
| `.claude-plugin/` | Plugin manifest and marketplace catalogue, for the Claude Code install route |
| `.agents/skills/` | Skills for working *on* this repository, not shipped with it |

`.claude` is a symlink to `.agents`, so either path reaches the same skills.

## Rules

- Any change to `skills/my-style-gen/` bumps `version` in `.claude-plugin/plugin.json`,
  the only version field in the repository. Patch for wording and corrections,
  minor for a new rule, reference or asset, major for a rename or a changed invocation.
  Add the matching `CHANGELOG.md` section and its link reference in the same change,
  written for the reader who installed the skill. Repository-internal files do not count.
- Keep `SKILL.md` under 5000 words. Move anything longer into `references/` and link it
  from `SKILL.md` with a note on when to read it.
- Wrap markdown at 88 characters. Leave long links and table rows alone.
- Nothing in the skill may name a real person, employer, repository or file path. The
  skill is written against "the user" and resolved at run time.
- Update `README.md` in the same change whenever the skill's behaviour or invocation
  changes.
- Conventional commits: `docs:`, `fix:`, `feat:`, `style:`.
