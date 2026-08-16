# Mano Hooks

Hooks are optional post-skill steps that belong to your project.

A hook becomes active only when you copy or rename an `.example.md` file to remove `.example`:

```text
hooks/post-spec.example.md  -> inactive
hooks/post-spec.md          -> active
```

There is one hook slot per skill: `post-import`, `post-start`, `post-spec`, `post-rules`, `post-ux`, `post-ui`, `post-stories`, `post-review`.

## Two kinds of hook

A hook's `## Mode` section says what kind it is. The two produce different things, so they are treated differently:

| `## Mode` | Produces | When it runs | Approval |
|-----------|----------|--------------|----------|
| `suggest` (default) | findings — an opinion you have to weigh | Mano asks first in manual or unarmed runs; runs automatically during an armed auto chain | Findings need your per-item approval before anything is edited |
| `command` | an exit code — a mechanical side effect | Always, every time, in both modes | None — writing the hook file is the authorization |

A hook with no `## Mode` section is `suggest`, so hooks written before command mode existed keep working unchanged.

The line between them is *judgement vs mechanism*. A specialist review is an opinion, and an opinion arriving before you have formed your own changes what you think — so you are asked first. Syncing a tracker or regenerating an index has no opinion in it, you want it done every time, and being asked each time is just a chore.

## Suggest hooks

Use these for optional external review, validation, or specialist checks. Mano will:

- detect the active hook
- in manual mode or an unarmed run, mention it after the related skill finishes, ask whether to run it, and wait for you
- during an armed auto chain, run it after the related skill; continue when it has no findings, or pause for per-item triage when it does

Mano will not print the hook's prompt unless you ask, name specific external skills in generic output, or modify files from a hook's findings without your approval. Selected findings return to the related Mano skill and stay inside that skill's artifact boundary. `post-stories` uses its stricter immutable-story flow.

To point one at a third-party or specialist skill, copy an example file and replace `[external-review-command]` with your command.

## Command hooks

Use these for deterministic follow-up work your project always wants done — syncing a backlog to an external tracker, regenerating an index, notifying a system.

Name exactly one command in a `## Command` section:

```markdown
# post-import hook

## Mode
command

## Command
node scripts/sync-backlog.js
```

Mano runs it from the project root after the skill's artifacts are written, and reports it in one line of the execution log. To run the same script after several skills, create one hook file per skill — `post-import.md`, `post-start.md`, `post-review.md` — each naming the command.

What Mano will not do:

- ask you first, or treat it as a suggestion — the file is the authorization
- take the command from anywhere but the `## Command` section
- retry it, fix your script, or edit an artifact to compensate for what it did not do
- inspect or second-guess what it does — it is your script in your repository

If it fails, Mano reports the exact error and stops there. In `mano mode auto`, a failed command hook pauses the chain.

## Keep hooks honest

A `suggest` hook is advisory — do not hide a mandatory step in one. A `command` hook *is* a step your project always runs, which is the point, but it stays visible: you declared it in a file, and Mano reports it every time it runs.
