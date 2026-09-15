Two answers to the same task are in this directory. One was produced without the
`{{skill_name}}` skill, one with it. Work out what the skill changed.

- `task.md` - the task both were given
- `baseline/response.md` - answer produced without the skill
- `styled/response.md` - answer produced with the skill
- `{{skill_dir}}/` - the skill itself, SKILL.md and its references

Read SKILL.md first, then open only the reference files whose subject matches this task -
a deck reference is irrelevant to a code task, and reading it costs time and finds
nothing. From those, pull out at most ten rules that could plausibly apply here. Judging
every rule in the skill is not the goal; judging the ones this task exercises is.

Then judge those rules against both answers, with a short verbatim quote as evidence.
Where neither answer differs on a rule, say so - a rule the model already followed by
default is a rule the skill does not need to carry.

Return markdown, in this order, and nothing else. Two sentences per entry at most; this
is read in a terminal.

**Applied** - a table, one row per rule the styled answer follows and the baseline does
not: the rule in a few words, a quote from each answer, and whether the change makes
the answer easier or harder to read.

**Missed** - rules that clearly applied and the styled answer did not follow. These are
the actionable ones: for each, say in one clause whether the rule is buried, vaguely
worded, or in a reference file the agent had no reason to open.

**No difference** - rules both answers already satisfy, one line each, no quotes needed.
Do not pad this section; it exists so the skill can be trimmed.

**Regressions** - anywhere the styled answer is worse: information dropped, an example
that no longer makes sense, a rule followed where it should have yielded to correctness
or to the conventions of the thing being produced. Say none if there are none.

**Verdict** - two or three sentences. Whether the skill earned its place on this task,
and the single change to the skill that would have helped most.

Judge the style, not the substance. If one answer is technically better for reasons
unrelated to the skill, note it in one line under Verdict and move on. Quote both
answers rather than characterising them - a claim without a quote cannot be checked.
