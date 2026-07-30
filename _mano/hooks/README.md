# Mano Hooks

Hooks are optional reminders for post-skill checks.

They do not run automatically.

A hook becomes active only when you copy or rename an `.example.md` file to remove `.example`.

Example:

```text
hooks/post-spec.example.md  -> inactive
hooks/post-spec.md          -> active
```

When an active hook exists, Mano should mention it after the related skill finishes and ask whether to run it.

Hooks are useful for optional external review, validation, or specialist checks that are specific to your project.

## Suggest-only mode

For now, hooks use suggest-only mode.

This means Mano should:
- detect the active hook
- mention it in the final chat response
- explain its purpose briefly
- ask whether to run it
- wait for explicit user confirmation

Mano should not:
- run hooks automatically
- print the hook's suggested prompt unless the user asks
- mention specific external skill names in generic output
- modify files through a hook unless the user explicitly asks

## Writing project-specific hooks

The `.example.md` files are generic templates.

To use a third-party or specialist skill, copy an example file and replace `[external-review-command]` with your chosen command in the active project hook.

Keep hooks advisory. Do not put mandatory hidden workflow steps here.
