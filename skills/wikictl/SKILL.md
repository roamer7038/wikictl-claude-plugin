---
name: wikictl
description: Search, read and record pages in a shared Markdown wiki with the wikictl CLI. Use before answering with values specific to a machine or project (paths, versions, settings) or with past decisions, when a command fails, and when work produces a reusable fact worth recording.
allowed-tools: Bash
---

# wikictl

The wiki is a Markdown repository on a Git host; `wikictl` reads and writes it with git alone. Run it directly and add `--json` for machine-readable output. `wikictl help <command>` lists the flags of any command.

## When

- Read before answering with environment-specific values, past decisions, or rules.
- Read when a command or procedure fails: a workaround may be recorded.
- Read before writing: a page for the same question may exist.
- Write when work yields a reusable fact: a failure and its workaround, an environment-specific value, a decision and its reason.
- Do not write conversation summaries, standing instructions (CLAUDE.md), or repeatable procedures (skills).

## Read

```bash
wikictl search --json <word>...   # pages containing all words; proper nouns, command names, paths work best
wikictl get --json <path>         # body, links, backlinks and sha of one page
wikictl ls --json                 # pages in the default dirs: global/, projects/<current>/, machines/<this>/
wikictl context                   # resolved dirs and config
```

Choose what to read from `summary` in the search results. An empty result means the wiki has nothing on it: find the answer elsewhere and consider recording it. If a page has an old `updated` or a `contradicts` link, say so instead of presenting the value as settled. `--dirs a,b` looks outside the default dirs.

## Write

1. `search` for a page answering the same question.
2. New page: `wikictl put --json <path> < page.md`.
3. Existing page: `get --json` it, rebuild the page in a temporary file, edit, then `wikictl put --json --base <sha> <path> < page.md`. `get` prints `frontmatter`, `body` and `links` separately, not the raw page: write the frontmatter as YAML between `---` lines, then the body, then `## Links` with one `- <type>: [<title>](<path>) | <note>` per link, where `<path>` is `target` made relative to the page's directory. The `sha` printed by `put` is valid for the next `--base`.

A page is frontmatter with a one-line `summary` (required) and optional `type` (concept, procedure, decision, policy, observation, event, index, source), a title, the body, and a `## Links` section last. File and directory names use lowercase letters, digits and hyphens. The full format is in the [wikictl README](https://github.com/roamer7038/wikictl#page-format).

```markdown
---
summary: Go on laptop is 1.26.5, installed with goenv under ~/.anyenv
type: observation
---
# Which Go is installed on laptop?

`go version` prints go1.26.5; goenv manages it.

## Links
- part_of: [laptop](index.md)
- cites: https://go.dev/dl/ | release list
```

Placement: `global/` for knowledge independent of any environment, `projects/<name>/` for a project, `machines/<name>/` for a machine. Prefer the narrower one. Link only to pages that exist: `put` warns about a broken link and `lint` fails on it, so create the directory's `index.md` first or leave the `part_of` line out. Never write secrets; write the secret's name instead. Cite sources by URL.

## Exit codes

| Code | Meaning | Action |
|---|---|---|
| 2 | not configured | Run the `setup` skill of this plugin (`/wikictl:setup`) |
| 3 | conflict: the page changed, or `--base` is missing | Read `content` and `sha` from the output; if `content` lacks the change, reapply it and `put` again with `--base <sha>`; if it already has the change, stop |
| 4 | format violation | Fix the page (summary, frontmatter YAML, slug) and retry |
| 5 | git failure | Report the message; do not retry blindly |

`mv`, `rm` and `lint` exist too; `mv` rewrites links to the moved page, `lint` reports broken links and format violations (exit code 4 when any are found).
