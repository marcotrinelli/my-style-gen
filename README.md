# my-style-gen

**Your agent writes well. It just doesn't write like you.**

So every reply, every commit message, every spec lands in a stranger's idiom, and you
rewrite it before you can use it. This fixes that once.

Point it at work you already produced — git repositories, specs, decks, spreadsheets,
contracts, notes. It reads each source, works out how you work and how you write, and
installs a skill called `my-style` that every future agent session follows.

- **Faster review** — the work and the prose explaining it read the way you write, and
  need fewer corrections
- **Shared language** — your vocabulary and shorthand travel with the skill, so a terse
  request is decoded the way a long-time colleague would decode it
- **Personal touch** — what you make with an agent still reads like your work

Works for any line of work, not just engineering (an engineer's sources are
repositories, a product manager's are specs and decks, a lawyer's are filings — same
method, same output). And it adopts the style, not the weakness: a modern model already
writes a cleaner first draft than most of us, so each analysis agent filters as it
reads. The goal is legibility, not forgery.

## Install

One command, any agent — Claude Code, Copilot, Codex, Cursor, Windsurf and 75 others:

```bash
npx skills add marcotrinelli/my-style-gen
```

Add `-g` to install for every project rather than just this one.

Then ask for it in plain words:

> build a style skill from my work

<details>
<summary>Other ways to install</summary>

Claude Code, as a plugin:

```
/plugin marketplace add marcotrinelli/my-style-gen
/plugin install my-style-gen@marcotrinelli
```

By hand: clone and copy `skills/my-style-gen` into `~/.claude/skills/`,
`~/.copilot/skills/`, or wherever your agent keeps its skills.

</details>

## Companion skills

`my-style-gen` works on its own, but hands off to and leans on a few skills that live
upstream in [`anthropics/skills`](https://github.com/anthropics/skills). Install the
ones that match your sources:

| Skill | When you need it | Why |
|---|---|---|
| `skill-creator` | Recommended | `my-style-gen` hands off to it for iterating on a skill's *description* and triggering rather than its content |
| `docx` | Sources are Word documents | Reads `.docx` properly, tracked changes and comments included |
| `pptx` | Sources are decks | Reads `.pptx` properly, speaker notes included |
| `pdf` | Sources are PDFs | Extracts text and tables rather than guessing at layout |
| `xlsx` | Sources are spreadsheets | Reads formulas and structure, not just rendered values |

All five in one go:

```bash
npx skills add anthropics/skills -g --skill skill-creator docx pptx pdf xlsx
```

In Claude Code `skill-creator` is also carried by the official marketplace, so
`/plugin install skill-creator@claude-plugins-official` works just as well.

Without the format skills the analysis still runs — it falls back to `unzip`,
`pdftotext`, `pandoc` or `markitdown` — but the read is lossier, and tracked changes and
comments are where the best anti-pattern evidence lives. Plain text and git repositories
need none of them.

## Use

Asking in plain words is enough. Or give it what it needs up front — what you do, and
where your material is:

```
/my-style-gen
/my-style-gen backend engineer ~/src/api ~/src/cli
/my-style-gen product manager ~/Documents/specs ~/Documents/decks
/my-style-gen patent attorney ~/matters/filings
/my-style-gen https://github.com/me/project
```

Whatever is missing, it asks for in one message — what you do, which sources to read,
how to tell your material from everyone else's, your name and pronouns — then goes. As a
Claude Code plugin the skill is namespaced, so it answers to `/my-style-gen:my-style-gen`.

Reading the sources is the expensive part (one agentic exploration per source), so
prefer two or three substantial sources over many thin ones. Sources from unrelated
contexts are worth more than two from the same team — agreement across them is what
separates your habits from the house style.

The result installs as `my-style`, under `~/.claude/skills/` by default. Ask for another
name where two people's skills have to sit side by side. Installed inside a git
repository — the usual choice for a technical user — its path is added to that
repository's `.gitignore`, because it describes you and not the project.

## How it works

Three steps, one agent run per source. No tool to install, no state kept between runs.

| Step | What happens |
|---|---|
| Settle the inputs | What kind of work you do, which sources to read, how your material is identified in each |
| Read the sources | One agent per source, launched in parallel, each returning evidenced findings on voice, vocabulary, standards, craft and workflow |
| Write the skill | Merge the findings, keep what two or more sources agree on as firm rules, hedge the rest, install `my-style` alongside three A/B tasks written from the same findings |

Voice, vocabulary and standards carry the most weight. The first two serve legibility
and shared language directly; the third comes from what you push back on in other
people's work — review comments, tracked changes, redlines — the only source that yields
genuine anti-patterns. What someone sends back says more about their standards than
their own finished work does.

If a rule in the generated skill is wrong, edit the installed skill. A bad rule is
nearly always a wording problem, and re-reading the sources is the only expensive part.

## Seeing what it bought you

A style skill is hard to judge by reading it — the rules all look reasonable on the
page. So the generator also writes three tasks, from the same findings as the rules: one
that produces the thing you make, one that asks for work to be explained back, and one
terse request leaning on your shorthand. They land in `my-style/ab-test/tasks/`, and the
harness runs each twice, once without the skill and once with it:

```bash
skills/my-style-gen/assets/ab-test/ab-test.sh \
  --skill ~/.claude/skills/my-style --compare
```

Each arm runs headless in a throwaway workspace created outside any project (an arm
sitting under a repository would inherit that repository's skills, which is exactly what
is being measured), so the skill is the only difference between them. `--compare` adds a
pass that sorts the rules that applied into **applied**, **missed**, **no difference**
and **regressions**. Applied is the demonstration; missed and no-difference are the edit
list — a rule the model would have followed anyway costs attention in every session and
buys nothing. Re-run it after editing a rule; it takes no arguments beyond the skill.

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

## Contributing

Contributions are very welcome. Feature requests, bug reports and support all go through
[GitHub issues](https://github.com/marcotrinelli/my-style-gen/issues) — open one and
let's talk. Pull requests just as welcome.

## License

[MIT](LICENSE) © Marco Trinelli
