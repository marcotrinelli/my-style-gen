# The per-source brief

One agent run per source, all launched together. Substitute the placeholders below
and pass the whole block as the agent's prompt.

| Placeholder | Value |
|---|---|
| `{{profile}}` | one or two lines on what the user does and what they produce |
| `{{source_path}}` | absolute path to the repository or folder |
| `{{source_name}}` | short name for the source, used in the report |
| `{{authorship}}` | how to tell the user's material from everyone else's |
| `{{access_notes}}` | the block below that matches this source's type |

`{{authorship}}` is a list of git identities for a repository, a folder or filename
rule for a document set, or simply "everything here is theirs".

## Source type notes

Paste the matching block into `{{access_notes}}`. Use both when one source holds code
and documents together.

### Git repository

```
This source is a git repository. These git identities all belong to the user:

{{identities}}

    git log --no-merges {{author_flags}} --oneline
    git log --no-merges {{author_flags}} -p -- <path>
    git log --no-merges {{author_flags}} --name-only --format= | sort | uniq -c | sort -rn | head -40
    git log --no-merges {{author_flags}} --format='%H%n%s%n%b%n---'
    git log --no-merges {{author_flags}} --shortstat --format='%h %s' -n 120
    git log --no-merges {{author_flags}} --diff-filter=AR --name-status --format='%h %s'

`--author` takes several flags at once and matches on substring, so passing every
identity's email in one command catches all of the user's aliases.

Other contributors' work is useful only as contrast.
```

When `gh` is authenticated, append:

```
`gh` is authenticated, so pull requests are reachable. Scope every query to this
repository with `--repo {{repo_owner_slug}}`:

    gh pr list --repo {{repo_owner_slug}} --author @me --state merged --limit 50
    gh pr view <n> --repo {{repo_owner_slug}} --comments
    gh search prs --repo {{repo_owner_slug}} --reviewed-by @me --limit 30

Stay inside this repository. `gh` will happily answer about the whole account, and a
later step counts how many sources support each finding - evidence borrowed from
elsewhere would let one source impersonate several.
```

### Folder of documents

```
This source is a folder of files the user produced.

Start with the shape of it - `ls -R` and a count by extension - then read the files
that carry the most of the user in them: the longest, the most recent, and anything
they named directly. File names, folder layout and dates are evidence before a single
file is opened; naming and versioning conventions live there.

Office files are zip archives of XML and PDFs need a converter. Check your own tools
and skills first - a session configured with document skills (docx, pptx, xlsx, pdf)
can read these files directly, and that beats anything below. Otherwise check what is
installed (`command -v pandoc markitdown pdftotext libreoffice`) before assuming, and
fall back to unzip only when nothing else is available:

    unzip -p file.docx word/document.xml | sed 's/<[^>]*>/ /g'
    unzip -p file.pptx 'ppt/slides/slide*.xml' | sed 's/<[^>]*>/ /g'
    unzip -p file.xlsx xl/sharedStrings.xml | sed 's/<[^>]*>/ /g'
    unzip -p file.docx docProps/core.xml
    pdftotext -layout file.pdf -

`docProps/core.xml` carries the author and revision count, which settles authorship
when a folder is mixed.

Stripping tags loses structure, and structure is half of what makes a deck or a
spreadsheet theirs. Use a document skill or a real converter where one exists; where
none does, read the XML itself for heading levels, slide layouts, formulas and tracked
changes as well as the words.
```

---

## The brief

```
You are profiling how one specific person works, by reading material they produced:
{{source_path}}. Work from that directory.

What the user does:

{{profile}}

The goal is not to catalogue this source. It is to describe *this person* well enough
that an AI agent could produce work and prose that reads as though they produced it,
so that when the agent reports back to them they can read it quickly and recognise it
as their own idiom.

## Whose work to look at

{{authorship}}

{{access_notes}}

## Three rules that decide whether this is worth anything

**Attribute correctly.** Much of what you see was not a personal choice: a framework
dictated the layout, a formatter enforced the quotes, a corporate template fixed the
fonts and the section order, a regulator or a client specified the format. Those say
nothing about the person. Look for the thing that would explain a habit - config files,
linters, pre-commit hooks, `CONTRIBUTING`, style guides, document templates, boilerplate
repeated verbatim across files - before recording anything it could explain. When you
cannot tell, mark the finding "possibly imposed" rather than guessing.

**Quote the evidence.** Every finding carries a verbatim quote with a reference - a
commit sha, a file path, a slide number, a PR number. A claim without evidence cannot be
checked, and you will not be able to tell your inference from your invention once the
moment has passed. If you cannot find evidence for something you believe is true, leave
it out.

**Adopt the voice, never the mistakes.** Record register, rhythm, vocabulary and
structure - a non-native speaker's voice is a real signature worth keeping. Do not
record spelling mistakes, grammatical slips, swallowed errors, or anything else a
competent professional in their field would call a defect. An agent reproducing those
would be harder to read and would do worse work, which defeats the point. The one
exception is the vocabulary section below, which records everything exactly as they say
it.

## Calibration

Prefer a handful of well-evidenced, specific findings over a long list of generic ones.
"Writes clearly" is worthless - it describes everyone and tells an agent nothing it
would not already do. "Opens every deck with the decision being asked for, on slide 1,
before any context" is worth having. So is "names booleans as questions (`is_stale`,
`has_pending_writes`) and never prefixes them with `flag`".

Look for what is *distinctive*: what this person does that another competent person in
the same job plausibly would not.

## What to cover

Five areas. The first three are the highest-value - do them first and in most depth.

**1. Voice** - how they write prose. An agent will use this to explain its work back to
them, and to draft anything that goes out under their name. Read whatever prose this
source holds: commit bodies, PR descriptions and review comments; the written sections
of documents; summaries, intros and conclusions; comments and notes inside decks and
spreadsheets; anything addressed to a person rather than a machine.

Record register (formal or casual, sentences or fragments, first person or imperative);
density (reasoning explained or conclusion stated); structure (prose or bullets,
headings, conclusion first or last); formatting habits (emphasis, code formatting,
emoji, terminal punctuation in lists); and characteristic moves - do they flag
uncertainty, name tradeoffs, say what they did *not* do, hedge, apologise, quantify?

Note separately what they consider worth saying at all. Their terseness is a habit
formed with full context in their head; record *how* they say things.

**2. Vocabulary** - the mirror of voice: this exists so an agent can *understand* them.
Collect the terms they use without expanding: domain and project terms with a
one-clause definition; abbreviations; terms they use in a non-standard sense, with both
readings; names for parts of their workflow (stages, environments, review rounds,
recurring meetings, document types).

Highest-value entry type: **recurring shorthand for actions** - "clean this up", "wire
it in", "tighten it", "make it proper" - because that is the kind of instruction they
will give an agent directly. Method: find the phrase where it names a piece of work,
then look at what that work actually changed - the diff, the next revision of the file.
What was done is the definition. Quote both.

A definition, not a listing. "Uses the term `bullseye`" is worthless. "`bullseye` is the
detection engine, not the repo or the team - 'bullseye is slow' means the engine's query
path" is worth having. Record idiosyncratic and grammatically odd phrasing here exactly
as they use it; this section is exempt from the quality filter, because the job is to
*understand* an unusual construction perfectly, never to reproduce one.

**3. Standards and judgment** - what they consider worth stopping a piece of work for.
The richest source is what they say about *other people's* work: review comments on pull
requests, comments and tracked changes in documents, redlines, feedback threads. Their
own output shows what they produced under deadline; their corrections show what they
hold the line on.

Record what they consistently ask to be changed, what they wave through (equally
informative), how they signal blocking versus optional, and the *reasons* they give - a
reason generalises far better than the specific fix. For each recurring push-back,
record the inverse too: "never do X" is almost impossible to infer from reading finished
work.

Distinguish substance from housekeeping. "Rebase on main" and "fix the header margin"
are process. "This swallows the error - if the write fails we will never know" and
"this number is not sourced, do not put it on a customer slide" are standards. Where
there is no feedback on others' work in this source, say so; second-best is a revision
where they went back and corrected their own.

**4. Craft, per artefact type** - how they build the things they build. Tag every
finding with the artefact it applies to (Go code, API spec, slide deck, board memo,
model spreadsheet, patent claim, discharge summary), because a convention that holds
for one and not another is two findings, and a single untagged list is unusable.

For each artefact type this source holds, cover: the skeleton they reach for and the
order its parts come in; granularity (how much goes in one unit, and when they split);
naming; the level of detail and where it is spent; how evidence, numbers, citations or
errors are handled; what is always present and what is conspicuously always absent; and
a size threshold an agent can actually apply.

Go deep in the terms of the craft rather than in generic ones. For code, that means
naming per construct, error handling, typing, control flow, when a function gets
extracted, when a dependency gets added, test granularity and what goes untested, and
what triggers a comment. For a deck, it means slide count, one idea per slide or not,
title style as assertion or label, where the ask sits, how data is shown, builds and
appendices. For a spreadsheet, it means sheet layout, named ranges, hardcoded inputs
versus parameters, formula style, colour and unit conventions. Use the craft that fits
the source; do not force a checklist written for a different one.

**5. Workflow and packaging** - how the work is chunked, named, versioned and handed
over. In a repository: commit subject style, body policy, commit granularity from the
`--shortstat` distribution, whether refactors are separated from behaviour changes,
branch naming, PR size and shape. In a document set: file and version naming, what gets a new file versus a new revision,
folder structure, what ships as a draft and what does not, how reviewers are brought in,
what they send versus what they file. Note what they habitually do first and last - an
outline before prose, a summary written after the body, a cleanup pass at the end.

## Output

Return your findings as your final message, in markdown, grouped under the five
headings above. Drop any heading you found nothing for - an honest gap beats padding.

Each finding is one bullet:

- **The rule, as an imperative instruction to a future agent.** "Return early instead
  of nesting past three levels", not "tends to avoid deep nesting". "Put the ask on
  slide 1", not "decks are usually structured around a request".
- Why you believe it is their own choice, in a clause. Mark "possibly imposed" where
  that is a live possibility.
- One or two short verbatim quotes with refs (`a1b2c3d`, `path/to/file.py:42`, `#214`,
  `Q3-review.pptx slide 4`).

Quote generously here. This report is read by one merging step and then thrown away -
none of the quotes, refs or source names reach the skill that gets written, so nothing
is lost by being specific and a finding without evidence cannot be weighed at all.

If the report runs long, write it to a file in a scratch directory and return the path
plus a one-paragraph summary instead.
```
