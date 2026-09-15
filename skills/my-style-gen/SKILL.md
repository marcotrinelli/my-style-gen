---
name: my-style-gen
argument-hint: "[what you do] [source paths or urls] - omit and you will be asked"
description: Builds a personal style skill for one person, whatever their line of work -
  engineer, product manager, seller, lawyer, clinician, researcher, anything. Reads
  material that person authored (git repos, folders of documents, decks, spreadsheets,
  notes), works out how they work and how they write, drops anything below a competent
  baseline, and writes an installable skill - my-style - so a future agent produces work
  in their idiom, reports back in their voice, and decodes their shorthand. Use whenever
  someone wants an agent to work or write like them, asks for a personal or per-user
  style skill, wants their own conventions, standards, voice or vocabulary captured
  from their own material, says my-style-gen, or asks to build, rebuild or refine
  their my-style skill. Not for authoring skills in general - that is skill-creator.
---

# my-style-gen

This skill builds another skill: read the material one person has produced, work out
how that person works and writes, and write a skill folder - `my-style` - that a future
agent installs and follows.

It is not tied to any profession. An engineer's sources are git repositories; a product
manager's are specs and decks; a lawyer's are filings and contracts. The method is the
same, and so is the shape of the output.

Three steps, and one agent run per source. Nothing is stored between runs, there is no
state to resume, and no intermediate files survive the job.

1. **Settle the inputs** - who the user is, what work they do, which sources to read.
2. **Read the sources** - one agent per source, in parallel, each returning findings.
3. **Write the skill** - merge the findings, write the skill folder and the three A/B
   tasks that go with it, then install.

Then, optionally, show the user what it bought them by running those tasks with and
without the installed skill.

## Why this exists

An agent working in its own default idiom produces output the user has to translate
before they can trust it. The goal is that the agent's *work* and the prose *explaining*
that work both land in the user's idiom, so they read fast and need fewer corrections;
and that the agent *decodes* the user's shorthand the way a long-time colleague would,
instead of guessing or asking. How the agent talks matters as much as what it produces.

The goal is legibility, not forgery. Say so if the user frames it as making output
indistinguishable from their own.

**Adopt the voice, never the mistakes.** Today's models write cleaner prose and code
than most first drafts, so faithfully cloning everything would *degrade* output.
Register, vocabulary, rhythm and structure are a real signature worth keeping - a
non-native speaker's voice included. Typos, grammar slips, swallowed errors and sloppy
reasoning are not. This filter is applied by each analysis agent as it reads, not as a
separate stage.

**Nothing about any particular person or profession is hardcoded here.** Every prompt
and template is written against "the user" and resolved at run time. The output is
personal; this skill is not.

## Step 1 - Settle the inputs

Fast, and mostly confirmation. Ask everything missing in **one** message, then go. Do
not turn it into an interview.

**What the user does.** One or two lines: their role, their field, and the kinds of
things they make with an agent's help - code, specs, decks, spreadsheets, contracts,
reports, emails, lesson plans. This is what tells the analysis what to look for, and
it is what the generated skill gets organised around. Take it from whatever the user
typed after `/my-style-gen`; ask if it is not there. Do not infer it from the
sources alone - a folder of spreadsheets looks much the same whether a financial
analyst or a nurse manager made it, and the two need different skills.

**Sources.** Anything the user authored: git repository paths or URLs, folders of
documents, an export of their notes or messages. Take them from the invocation; ask if
absent. Inside a git repository with nothing given, offer the current repository as the
default.

Prefer two or three substantial sources over many thin ones - a source the user barely
touched costs a full agent run and yields little. Ask for sources spanning more than
one context where they exist: a habit that shows up in two unrelated places is the
person, and a habit that shows up in one may be the house style.

**Authorship.** Every source needs a way to tell the user's work from everyone else's.

- *Git repository* - run `git log --format='%an <%ae>' | sort -u | head -30` and match
  against `git config user.name` / `user.email`. People commit under several addresses,
  so show the candidates and have the user confirm or correct them.
- *Document folder* - ask whether all of it is theirs. If it is mixed, Office files
  carry an author in `docProps/core.xml`, and the user can usually name a subfolder or
  a filename pattern that is all theirs.
- *Anything else* - ask how to tell, in one clause.

Sole authorship claimed by the user is good enough. Do not build a verification step.

**Name and pronouns.** Ask once, with the rest. Pronouns cannot be inferred from a
name; default to they/them if the user doesn't say.

**Skill name.** `my-style`, unless the user asks for something else. A person installs
one of these for themselves, so the generic name is the one they will recognise a year
from now; take an override where two people's skills have to coexist in the same place
- `dana-style` for Dana Ruiz. Validate an override the same way: kebab-case, no spaces
or capitals, not starting with `claude` or `anthropic`.

Confirm the plan in one line - what they do, sources, output name - then go.

## Step 2 - Read the sources

One agent run per source, all launched in the same message so they run in parallel.
Each agent covers the whole picture for its source - voice, vocabulary, standards, the
craft of whatever artefacts it holds, and how work gets packaged - and returns a
findings report.

`references/analysis.md` is the brief. Substitute the placeholders and pass it as the
agent's prompt. Use a general-purpose agent; the parent session's permissions apply.
Where the session has document-reading skills or tools available, say so in the prompt
- those beat converting Office files on the command line.

Each agent returns its findings as its final message - no files, no JSON schema. If a
source is large, tell the agent to write the report to a scratch file and return the
path instead, so a long report doesn't have to fit in one message.

For headless use, write the prompt to a file first (prompts contain backticks and
newlines that shell quoting corrupts) and run the CLI with read-only tools allowed:

```bash
cd /path/to/source && claude -p "$(cat /tmp/brief-source-a.md)" \
  --model opus \
  --allowedTools "Read Glob Grep Bash(git *) Bash(gh *) Bash(ls *) Bash(unzip *)"
```

## Step 3 - Write the skill

Merge the reports, then write the folder. Read `references/output.md` for the layout,
the frontmatter rules and the checklist, and start from
`assets/generated-skill-template/` rather than composing from scratch.

**Merging is mostly corroboration.** The known failure of this method is mistaking an
imposed house style - a linter, a corporate deck template, a court's formatting rules -
for a personal habit. Agreement across sources is the fix:

- Seen in **two or more sources**: state it as a firm rule, plain imperative.
- Seen in **one source**: hedge it - "usually", "prefer". Anything an agent flagged as
  possibly imposed, drop unless another source corroborates.

Hedge in the wording alone. Do not name the source that produced a rule, in the skill or
anywhere in it - say the corroboration count out loud to the user in chat instead.

With a single source nothing can be corroborated. Say so plainly, hedge everything, and
offer to add a source rather than quietly stating one workplace's conventions as law.

**The sources do not survive into the skill.** Evidence is what you merge on, not what
you ship: no repository or client names, file paths, commit shas, PR numbers, slide
numbers, corpus counts, or examples lifted out of a real project. The skill gets read in
places those mean nothing. `references/output.md` has the rule and what to write
instead.

Drop duplicates, and drop anything generic. "Writes clearly" describes everyone and
tells an agent nothing it would not already do - cutting those matters more than
keeping the count up.

Then write the folder where the user's agent looks for skills - `~/.claude/skills/` by
default, or `.agents/skills/` inside a project when they want it next to the work -
confirming first if something is already there.

**A skill that lands inside a git repository gets gitignored.** This is the common case
for a technical user, who works in a repository and wants the skill loaded there. It
describes one person, not a convention the project imposes on everyone, so append its
path to that repository's `.gitignore` - checking first that it is not already covered -
and say that you did. Skip this when the install path is outside any repository.

**Write the three A/B tasks in the same pass**, into `ab-test/tasks/` inside the skill
folder: one that produces the user's main artefact, one that asks for work to be
explained back, and one terse request leaning on their shorthand. They are built from
the same findings as the rules, so they have to be written before those findings are
discarded - `references/ab-test.md` has what each one has to contain. The provenance
rule applies to them exactly as it does to the skill.

Show the user the rule list, the three tasks, and where it all landed.

## Show the difference

Optional, and worth offering as soon as the skill is installed: run the three tasks
twice, without the skill and with it, and put the answers side by side. It is what turns
a list of rules into something the user can judge, and the rules it fails to change are
the ones to cut.

`assets/ab-test/ab-test.sh` runs both arms headless in throwaway workspaces created
outside any project - an arm sitting under a repository would inherit that repository's
skills, and a baseline that picked up the skill under test measures nothing. With
`--compare` it adds a third pass that sorts the applicable rules into applied, missed,
no-difference and regressions. With no `--task` it picks up the tasks written alongside
the skill, so a re-run after editing a rule takes no arguments:

```bash
assets/ab-test/ab-test.sh --skill ~/.claude/skills/my-style --compare
```

Read `references/ab-test.md` before writing the tasks - what each one targets decides
whether the run shows anything at all.

## Refining afterwards

A user unhappy with the installed skill does not need a rebuild. Edit the installed
skill directly - a bad rule is nearly always a merging or wording problem, not a missing
observation, and re-reading the sources is the only expensive part of this.

Re-run the analysis only when the sources have meaningfully moved on, or when the user
wants one added.

If the user wants to iterate on the generated skill's *description* and triggering
rather than its content, hand off to `skill-creator`.

## Reference files

- `references/analysis.md` - the per-source brief, ready to substitute and spawn
- `references/output.md` - generated skill layout, frontmatter rules, checklist
- `references/ab-test.md` - writing the three tasks, running the with/without
  comparison, and what to change in the skill based on what comes back
- `assets/generated-skill-template/` - starting point for the rendered skill
- `assets/ab-test/` - the comparison script, its comparison brief, and example tasks
