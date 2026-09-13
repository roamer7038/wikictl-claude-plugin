---
name: wikictl
description: Use when an answer depends on environment-specific values (paths, versions, settings), past decisions or rules, when a command fails and a known workaround may exist, and whenever a reusable fact is learned. Searches, reads and records pages in a Markdown wiki on a Git host through the wikictl CLI.
allowed-tools: Bash
---

# Read and record knowledge with wikictl

The wiki is a Markdown repository on a Git host. `wikictl` is a CLI that reads and writes it using only git; it runs no server.
Call every command through `${CLAUDE_PLUGIN_ROOT}/scripts/wikictl-logged.sh`: it records usage and otherwise behaves exactly like `wikictl`. Add `--json` for machine-readable output.

## When to use

- Before answering with environment-specific values (paths, versions, settings), past decisions, or rules
- When a command or procedure fails (look for a known workaround)
- Before writing a new page (is there already a page for the same question?)
- When work yields a reusable fact: a failure and its workaround, an environment-specific value, a decision and its reason, a changed convention

Do not record conversation summaries, standing instructions (those belong in CLAUDE.md), or repeatable procedures (those belong in Skills). The test is "cost to obtain again × probability of reuse".

## Reading

```bash
W=${CLAUDE_PLUGIN_ROOT}/scripts/wikictl-logged.sh
$W search --json <word>...        # all words must match; use proper nouns, command names, paths. --any for any word
$W get --json <path>              # body, links, backlinks, sha. Read only what you need
$W ls --json                      # pages in the default dirs: global, projects/<current>, machines/<this machine>
$W context                        # the resolved dirs, machine and project names, and config
$W help [<command>]               # exact flags and behaviour
```

- Pick what to read from `summary` in the search results. Doubt a value when `updated` is old or `links` contains `contradicts`; present both sides.
- `--dirs a,b` searches outside the default dirs. `--all` includes pages with `status: deprecated`.

## Recording

1. `search` for a page that answers the same question.
2. If one exists, `get --json` it, write the content to a temporary file, edit it, and replace it with `put --base <sha>`. Otherwise create it with `put` (no `--base`).

```bash
printf -- '---\nsummary: <the answer in one sentence, about 100 characters>\ntype: <concept|procedure|decision|policy|observation|event|index|source>\n---\n# <a question, or a noun phrase>\n\n<body>\n\n## Links\n- part_of: [<title>](<relative path>.md)\n- cites: <URL> | <what it supports>\n' | $W put --json <dir>/<slug>.md
$W put --json --base <sha> <path> < edited.md
```

- Exit code 3 is a conflict: read `content` and `sha` from the output, reapply the change, and `put` again with `--base <new sha>`. Writing to an existing page without `--base` is also a conflict.
- Exit code 4 is a format violation (missing summary, invalid frontmatter YAML, bad slug). Fix and retry.
- Placement: knowledge independent of any environment goes in `global/`, project-specific in `projects/<name>/`, machine-specific in `machines/<name>/`. When unsure, choose the narrower one.
- Slugs are lowercase letters, digits and hyphens. Links are relative paths from the page itself and include `.md`. Relations go at the end in a `## Links` section as `- <type>: [title](path) | note`.
- Mark tentative conclusions with `summary: "draft: ..."`. Never write secrets; write the name of the secret instead. Cite sources by URL (a commit-pinned permalink for code).

## Moving, deleting, checking

```bash
$W mv <path> <newpath>            # rewrites links in referring pages in the same commit
$W mv <dir>/ <newdir>/            # whole directory; both arguments end with /
$W rm <path>
$W lint --json                    # missing summary, Links syntax, broken internal links
```
