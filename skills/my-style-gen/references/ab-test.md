# Showing the difference

An installed style skill is hard to judge by reading it. The rules all look reasonable
on the page; what matters is whether an agent following them produces something the
user reads faster. So run one task twice - once without the skill, once with it - and
put the two answers next to each other.

This is a demonstration and a diagnostic, not a benchmark. Three tasks tell you whether
the skill bites and which rules are dead weight. They do not give you a score, and a
run that comes back identical usually means the tasks were wrong, not that the skill is
empty. Triggering accuracy - whether the description fires in the right conversations -
is a different question, and `skill-creator` is what answers it.

Run this after installing, or after editing a rule the user pushed back on.

## Write the tasks

Write them in the same pass that writes the skill, while the analysis reports are still
in context. The reports are thrown away at the end of the run, and they are what tells
you which artefact the user actually makes and which shorthand phrase carries weight -
reconstructing that later from the skill alone produces blander tasks.

They go in `ab-test/tasks/` inside the skill folder, so they travel with it and a
re-run after an edit needs no arguments:

```
{{skill_name}}/
  SKILL.md
  references/
  ab-test/
    tasks/
      01-artefact.md
      02-report-back.md
      03-shorthand.md
```

Nothing in `ab-test/` is linked from SKILL.md and nothing reads it as part of the
skill - it is material for the harness, kept where it will still be findable in six
months.

Three, no more. Each is a short prompt, three to ten lines, and each targets one of the
three areas the analysis put the most weight on:

1. **Produce an artefact** - the main thing the user makes. A function, a spec, a
   memo, a model, a clause. Pick the artefact type the `craft-` references cover in
   most depth, and set it up so the craft rules have something to bite on: a choice to
   make, a failure case to handle, a number to state.
2. **Explain work back** - hand over a small set of facts and ask for the update,
   summary or hand-off note that goes out. This is the pure voice test, and it is the
   one users notice most, because it is what they read on every interaction.
3. **A terse request using their shorthand** - phrased the way they would phrase it,
   with at least one lexicon term carrying real weight. A baseline agent guesses or
   asks; an agent with the lexicon acts. This is the clearest single demonstration
   there is. Take the term from the lexicon's action shorthand, and give the task a
   shape where acting on the wrong reading is visibly wrong.

Rules for writing them:

- Self-contained. No repository to clone, no file to open, nothing the agent has to be
  told twice. Everything it needs is in the prompt.
- Reply-sized. The harness tells both arms to deliver the work in the reply and gives
  them no write access, so the tasks do not have to say it - but a task that only makes
  sense as a whole repository or a fifteen-page document produces two answers too big to
  compare. One function, one page, one section, one message.
- Say nothing about style. No "in my voice", no "be concise" - the whole point is to
  see what the skill does unprompted. A task that asks for the outcome you are testing
  for proves nothing.
- Invented material, in the user's domain but about nothing real. Generic domain nouns
  and a plausible situation. The provenance rule that governs the skill governs these
  too: no source, repository, client or project names, and nothing pasted out of a real
  spec, diff or document. The user's own vocabulary is the one exception, exactly as it
  is in the lexicon - task three does not work without it.
- Enough room to have a style. "What does this error mean" has one right answer and no
  idiom in it; "write the spec for X" has a hundred shapes and the user prefers one.
- Match the user's register in the framing of the task, not just its subject. A request
  written the way their colleague would write it gets an answer worth comparing.

`assets/ab-test/example-tasks/` holds the three, rendered for a fictional product
manager, as a shape to copy - not a template to fill in for anyone else.

Show the user the three tasks when you show them the rule list. A task they would never
send is a sign the profile was read too narrowly, and it is cheaper to hear that now
than after a run.

## Run it

```bash
skills/my-style-gen/assets/ab-test/ab-test.sh \
  --skill ~/.claude/skills/my-style --compare
```

With no `--task`, it runs the three tasks in `<skill>/ab-test/tasks`. Pass `--task` to
point at one file or another folder.

Each arm runs headless in its own throwaway workspace, created outside any project the
user has and carrying its own project marker, with only project settings loaded. That
isolation is the whole experiment: an arm whose working directory sits under a
repository inherits that repository's skills, and a baseline that quietly picked up the
skill under test measures nothing. Results are written to `--out`; the workspaces are
deleted at the end.

Both arms are told, in the same words, to deliver the work in the reply and to write
nothing. The styled arm additionally gets the skill copied into its workspace and a line
telling it to follow it. `--natural` drops that line and leaves the skill to trigger on
its own description, which tests triggering at the cost of a noisier signal.

Results land one directory per task, with `task.md`, `baseline/response.md`,
`styled/response.md` and, with `--compare`, a `comparison.md`.

## Read the result

The comparison pass sorts the applicable rules into applied, missed, no-difference and
regressions. What to do with each:

- **Applied** is the demonstration. Show the user two or three of these quoted side by
  side rather than the whole file.
- **Missed** is the useful half. A rule that clearly applied and was ignored is buried,
  vaguely worded, or sitting in a reference file the agent had no reason to open. Fix
  the wording or move the rule up into SKILL.md. Do not add a second rule saying the
  same thing louder.
- **No difference** is where a skill gets fat. A rule the model follows anyway costs
  attention in every future session and buys nothing. Cut it.
- **Regressions** are the ones to take seriously. A style rule that drops information,
  or that got followed where the conventions of the thing being produced should have
  won, is a precedence or quality-floor failure - the fix belongs in SKILL.md, not in
  the rule that misfired.

Model output varies run to run, so treat a single difference as a hint and a difference
that repeats across all three tasks as real. When a run comes back with nothing in
either Applied or Missed, suspect the tasks first: too small, too closed, or written in
a domain the skill has no rules for.
