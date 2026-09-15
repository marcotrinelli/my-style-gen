# Writing the generated skill

Start from `assets/generated-skill-template/` - it carries the sections that are easy
to lose and consequential when missing. Copy, substitute, drop the `.template` suffix.

Write it where the user's agent looks for skills - `~/.claude/skills/my-style/` by
default. `my-style` is the folder name unless the user asked for another; everything
below calls it `{{skill_name}}`.

## Layout

```
{{skill_name}}/
  SKILL.md                  voice first, then the rules that cut across everything
  references/
    voice.md                chat replies, written work, messages, summaries
    lexicon.md              the user's vocabulary - read to interpret a request
    anti-patterns.md        never do this, from what they push back on
    craft-<artefact>.md     one per artefact type actually found
    workflow.md             how work is chunked, named, versioned, handed over
  ab-test/
    tasks/                  the three A/B tasks - see references/ab-test.md
```

Nothing under `ab-test/` is linked from SKILL.md or read as part of the skill; it sits
there so the tasks stay with the skill they were written for.

`<artefact>` is named after the thing, in kebab-case, whatever that thing is:
`craft-go.md`, `craft-slide-decks.md`, `craft-model-spreadsheets.md`,
`craft-patent-claims.md`. Emit one only for artefact types the sources actually
evidenced.

Emit only files that have content. A `craft-rust.md` with two thin rules is worse than
no file: it spends the reader's attention and implies a confidence the findings do not
have. Fold a thin topic into SKILL.md or drop it.

## What goes in SKILL.md

In this order:

1. **Precedence and the quality floor.** First, because they bound everything below.
2. **Voice.** First among the content: it is what the user reads on every single
   interaction, which makes it the highest-leverage thing in the file.
3. **A pointer to `references/lexicon.md`**, with an instruction to read it *before
   interpreting a request*, not before writing one.
4. **Cross-cutting work rules** - the ones that hold whatever is being produced.
5. **Pointers to each reference file**, each with a sentence on when to read it.

Everything else is a reference. Keep SKILL.md under 5000 words; if it is crowding, the
cross-cutting rules are what move out, never precedence or voice.

## The four things that must survive

**Precedence, at the very top.** A personal style skill is near-always-on, so blast
radius is controlled by precedence rather than by narrowing the description: an explicit
instruction in the conversation wins over everything here; the conventions of the thing
being worked on - the repository, the client's template, the house style guide, the
required filing format - win over personal preference; the skill fills the remaining
freedom; material the user did not author is never restyled.

**The quality floor.** These are stylistic preferences and never override correctness,
accuracy, safety, compliance or clarity. If following one would make the work worse,
don't follow it. Without this, a rule written for one context gets applied where it
actively harms, and the user's first experience of their own style skill is it making
something worse.

**The brevity guardrail.** Terseness in the user's own writing is a habit formed with
full context in their head. An agent reporting on work the user has not yet seen does
not share that context. Match the register and vocabulary, but never drop information
the reader needs - brevity applies to how something is said, not to what is omitted.

**Read the lexicon before interpreting, not before writing.** The instinct is to file
vocabulary under "how to write". It belongs where a request is being understood, and
the generated SKILL.md has to say so explicitly or it gets read too late to matter.

## Frontmatter

Templated, never literal. Rendered for Priya Raman, a product manager:

```yaml
---
name: my-style
description: Applies Priya Raman's personal working and communication conventions -
  how she structures specs, decks and written updates, the standards she holds work to,
  and the tone and level of detail she expects when work is explained back to her. Also
  carries her domain vocabulary and shorthand, so her requests are interpreted the way
  she means them. Use whenever producing, revising or reviewing work in Priya's product
  work, when summarizing or explaining what you just did, and when a request uses
  shorthand or team terms. Existing templates, house style and explicit instructions
  always take precedence.
---
```

- `name` is `my-style`, or the override the user chose, kebab-case, matching the folder
  name exactly, and must not begin with `claude` or `anthropic` - both are reserved.
- `description` states what it does *and* when to use it, stays under 1024 characters,
  and contains no angle brackets - `<` and `>` are forbidden in frontmatter because it
  is injected into a system prompt.
- Name the person in the `description` even though the skill is named `my-style`. The
  name is what makes it obvious whose conventions these are once the file is open.
- No colon-space inside an unquoted value, or the YAML parses as a mapping. The
  template uses dashes where a colon would be natural.
- Name the artefacts the user actually produces. A description listing things they never
  make triggers the skill in the wrong places and misses the right ones.
- The "when" half must cover both producing the work and *explaining* it. A description
  mentioning only the work produces a skill that never triggers when the user asks for a
  summary, which is half the value gone.

Two cases to handle: no resolvable display name - fall back to "the user" throughout
and drop the possessives - and unknown pronouns, which is what the they/them default is
for.

## Nothing about the sources reaches the output

The generated skill is installed once and then read everywhere the user works - other
repositories, other clients, next year's projects. Anything that points back at the
material it was built from is noise in all of those places, dates the skill, and can
carry a client or project name into a context where it does not belong.

Strip every trace of provenance as you write:

- No source, repository, client or project names. No file paths, commit shas, PR
  numbers, document or deck file names, slide numbers, dates.
- No corpus statistics - how many commits or documents were read, what share of a
  repository was theirs, how many sources agreed on a rule.
- No phrases like "seen in", "in their Q3 deck", "across both repos", "one source only".
- No examples lifted verbatim from a source. A rule illustrated with a real project's
  type names, function names, product names or slide titles is opaque to a reader
  outside that project, and reads as a template to copy when it is not one.

Illustrate rules with invented examples instead - written in the user's idiom, about
nothing real. Generic domain nouns (`order`, `invoice`, `session`, `job`), placeholder
names, a made-up title of the right shape. The example has to show the *form* of the
rule; it does not have to have happened.

The evidence still matters - it is what the analysis reports carry and what corroboration
is judged on. It stops at the moment you write a file.

The one exception is `references/lexicon.md`, whose entire purpose is the user's real
terms: those stay, exactly as they say them. Even there, define the term rather than
citing where you found it.

## Writing the rules

Imperative, second person, one instruction per bullet. The findings arrive written this
way; keep them and resist softening them into description. "Return early instead of
nesting past three levels" and "put the ask on slide 1, above the context" are
actionable; "tends to avoid deep nesting" is trivia.

Explain the why where a rule has one. A rule with its reason attached generalises to
situations its author never saw, and most of the value here comes from the agent
extending a rule sensibly rather than matching the exact case that produced it.

State confidence honestly. Plain imperative for something two or more sources agreed on;
"usually" or "prefer" for something seen once. That is not hedging, it is accurate - a
reader who finds a one-source guess stated as law and disagrees with it will distrust the
firm rules too. The hedge carries the confidence on its own; naming where the rule came
from adds nothing a future reader can use.

Avoid stacking capitalised MUSTs and NEVERs. The one place emphasis is earned is
`anti-patterns.md`, where the whole point is a hard line.

Make a rule concrete with a short invented example, not with a quotation from a source.
Don't build an evidence file - it costs a pass over everything, gets read by nobody, and
is precisely the material that should not ship.

## Placeholders

From the user: `{{skill_name}}` (`my-style` unless overridden), `{{display_name}}` (or
"the user"), `{{possessive_name}}`, `{{pronoun_subject}}`, `{{pronoun_object}}`,
`{{pronoun_possessive}}`, `{{domain}}` (a noun phrase for their field of work) and
`{{artefacts}}` (what they produce).

From the findings: `{{voice_rules}}`, `{{cross_cutting_rules}}` (rules with no single
artefact attached), `{{reference_index}}` (one bullet per emitted file with when to read
it), `{{rules}}` and `{{single_source_rules}}` in the topic template,
`{{anti_patterns}}`, and the lexicon groups `{{domain_terms}}`, `{{abbreviations}}`,
`{{action_shorthand}}`, `{{nonstandard_terms}}`, `{{workflow_terms}}`.

Where a section comes out empty, delete the whole heading. An empty heading reads as an
omission and invites the reader to wonder what was lost.

## Before telling the user it's done

- [ ] Folder name is kebab-case and matches `name` in the frontmatter
- [ ] The file is named exactly `SKILL.md` - case-sensitive, no variants
- [ ] Frontmatter delimited by `---` on its own line, top and bottom
- [ ] `name` is `my-style` or the user's chosen override, not `claude*` or `anthropic*`
- [ ] `description` has both what and when, under 1024 characters, no `<` or `>`
- [ ] `description` names the person and the artefacts they actually produce
- [ ] No `README.md` inside the skill folder
- [ ] SKILL.md under 5000 words
- [ ] Precedence, quality floor and brevity guardrail all present
- [ ] Lexicon pointer says to read it before interpreting a request
- [ ] Every `references/` file linked from SKILL.md with a note on when to read it
- [ ] No reference file empty or near-empty
- [ ] No source, repository, client or project name, file path, sha, PR number or slide
      number anywhere outside the lexicon
- [ ] No corpus statistics and no "seen in" provenance on any rule
- [ ] Every example invented, not lifted out of a source
- [ ] No real name or email anywhere the user did not supply it
- [ ] Rules imperative, not descriptive; one-source rules hedged, not attributed
- [ ] Three tasks written to `ab-test/tasks/`, and provenance-free like everything else
- [ ] Gitignored if it landed inside a git repository

Then read the rendered SKILL.md end to end as if you were the user. It is their voice
being described - if a paragraph does not sound like a person, the rules behind it are
too generic, and that is an analysis problem surfacing here rather than a writing one.
