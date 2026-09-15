# my-style-gen

A meta-skill that builds a personal style skill for one person, whatever they do for a
living.

Point it at material you produced — git repositories, folders of specs, decks,
spreadsheets, contracts, reports, notes. One agent reads each source, works out how you
work and how you write, drops anything below a competent baseline, and writes an
installable skill — `my-style` — that a future agent follows so its work, its documents
and its replies land in your idiom.

The goal is legibility, not forgery. Reviewing agent work in a foreign style is slower
than reviewing a colleague's work in a familiar one, so what this buys you is:

- **Faster review** — the output, the work *and* the prose explaining it, reads the way
  you write and needs fewer corrections.
- **Mutual understanding, both directions** — the generated skill carries your
  vocabulary and shorthand, so a terse request is decoded the way a long-time
  colleague would decode it rather than guessed at.
- **Personal touch** — what you make with AI still reads like your work.

Two constraints shape it. Nothing about any particular person or profession is
hardcoded: every prompt resolves at run time, so the output is personal and the tool is
not. And **style is adopted, weakness is not** — a modern model already writes a
cleaner first draft than most, so each analysis agent filters as it reads. Adopt the
voice, never the mistakes.

## Install

Any agent — Claude Code, Copilot, Codex, Cursor, Windsurf and 75 others:

```bash
npx skills add marcotrinelli/my-style-gen
```

Add `-g` to install for every project rather than just this one.

Claude Code, as a plugin:

```
/plugin marketplace add marcotrinelli/my-style-gen
/plugin install my-style-gen@marcotrinelli
```

Or by hand — clone and copy `skills/my-style-gen` into `~/.claude/skills/`,
`~/.copilot/skills/`, or wherever your agent keeps its skills.

## Companion skills

`my-style-gen` works on its own, but it hands off to and leans on a few skills that live
upstream in [`anthropics/skills`](https://github.com/anthropics/skills). They are not
bundled here — install the ones that match your sources:

| Skill | When you need it | Why |
|---|---|---|
| `skill-creator` | Recommended | `my-style-gen` hands off to it when you want to iterate on a skill's *description* and triggering rather than its content |
| `docx` | Sources are Word documents | Reads `.docx` properly, tracked changes and comments included |
| `pptx` | Sources are decks | Reads `.pptx` properly, speaker notes included |
| `pdf` | Sources are PDFs | Extracts text and tables rather than guessing at layout |
| `xlsx` | Sources are spreadsheets | Reads formulas and structure, not just rendered values |

All five in one go:

```bash
npx skills add anthropics/skills -g --skill skill-creator docx pptx pdf xlsx
```

Without the format skills the analysis still runs — it falls back to `unzip`,
`pdftotext`, `pandoc` or `markitdown` — but the read is lossier, and tracked changes and
comments are where the best anti-pattern evidence lives. If your sources are plain text
and git repositories, you need none of them.

## Use

Ask for it in plain words:

> build a style skill from my work

Or give it what it needs up front — what you do, and where your material is:

```
/my-style-gen
/my-style-gen backend engineer ~/src/api ~/src/cli
/my-style-gen product manager ~/Documents/specs ~/Documents/decks
/my-style-gen patent attorney ~/matters/filings
/my-style-gen https://github.com/me/project
```

Installed as a Claude Code plugin the skill is namespaced, so it answers to
`/my-style-gen:my-style-gen`. Installed as a plain skill it is just `/my-style-gen`.
Either way you can skip the slash command and ask for it in words.

Whatever is missing, the skill asks for in one message — what you do, which sources to
read, how to tell your material from everyone else's, your name and pronouns — then
goes.

The result installs as `my-style`, under `~/.claude/skills/` by default. Ask for another
name if two people's skills have to sit side by side. When it is installed inside a git
repository instead — the usual choice for a technical user — its path is added to that
repository's `.gitignore`, because it describes you and not the project.

## How it works

Three steps, one agent run per source.

| Step | What happens |
|---|---|
| Settle the inputs | What kind of work you do, which sources to read, how your material is identified in each |
| Read the sources | One agent per source, launched in parallel, each returning evidenced findings on voice, vocabulary, standards, craft and workflow |
| Write the skill | Merge the findings, keep what two or more sources agree on as firm rules, hedge the rest, install `my-style` alongside three A/B tasks written from the same findings |

The first three areas carry the most weight: voice and vocabulary serve legibility and
shared language directly, and what you push back on in other people's work — review
comments, tracked changes, redlines — is the only source that yields genuine
anti-patterns. What someone sends back says more about their standards than their own
finished work does.

There is no tool to install, no code to maintain, and no state kept between runs. If a
rule in the generated skill is wrong, edit the installed skill — a bad rule is nearly
always a wording problem, and re-reading the sources is the only expensive part.

## Seeing what it bought you

A style skill is hard to judge by reading it — the rules all look reasonable on the
page. So the generator also writes three tasks for you, from the same findings as the
rules: one that produces the thing you make, one that asks for work to be explained
back, and one terse request leaning on your shorthand. They land in
`my-style/ab-test/tasks/` and the harness runs each of them twice, once without the
skill and once with it:

```bash
skills/my-style-gen/assets/ab-test/ab-test.sh \
  --skill ~/.claude/skills/my-style --compare
```

Each arm runs headless in a throwaway workspace created outside any project — an arm
sitting under a repository would inherit that repository's skills, which is exactly what
is being measured — so the skill is the only difference between them. `--compare` adds a
pass that sorts the rules that applied into **applied**, **missed**, **no difference**
and **regressions**. Applied is the demonstration; missed and no-difference are the edit
list — a rule the model followed anyway costs attention in every session and buys
nothing. Re-run it after editing a rule; it takes no arguments beyond the skill.

## Cost

Reading the sources is the expensive part: one agentic exploration per source. Prefer
two or three substantial sources over many thin ones — a source you barely touched
costs a full run and yields little. Sources from unrelated contexts are worth more than
two from the same team, because agreement across them is what separates your habits
from the house style.

## Layout

```
skills/my-style-gen/
  SKILL.md                                the three steps and how to drive them
  references/
    analysis.md       the per-source brief, ready to substitute and spawn
    output.md         generated skill layout, frontmatter rules, checklist
    ab-test.md        writing the three tasks and reading the comparison
  assets/
    generated-skill-template/             starting point for the rendered skill
    ab-test/                              the comparison script and example tasks
```

## License

[MIT](LICENSE) © Marco Trinelli
