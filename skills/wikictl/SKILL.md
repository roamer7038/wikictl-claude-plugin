---
name: wikictl
description: Search, read and record pages in a shared Markdown wiki with the wikictl CLI. Use before answering with values specific to a machine, project or user (paths, versions, settings, conventions) or with past decisions, when a command fails, and when work produces a reusable fact worth recording.
allowed-tools: Bash
---

# wikictl

The wiki is a Markdown repository on a Git host; `wikictl` (v0.3.0 or later) reads and writes it with git alone. Run it directly and add `--json` for machine-readable output. Global flags (`--json`, `--dirs`, `--no-fetch`) go anywhere; command flags (`--base`, `-n`, `-m`) must come before the arguments, since a flag after an argument is taken as an argument. `wikictl help <command>` describes any command.

## When

- Read before answering with environment-specific values, the user's conventions, past decisions, or rules.
- Read when a command or procedure fails: a workaround may be recorded.
- Read before writing: a page for the same question may exist.
- Write when work yields a reusable fact: a failure and its workaround, an environment-specific value, a decision and its reason.
- Do not write conversation summaries or repeatable procedures (skills). A rule that must hold in every conversation without searching is a standing instruction: suggest adding it to CLAUDE.md instead. A user fact looked up only when relevant (which account to use, tool choices) goes in `personal/`.

## Read

```bash
wikictl search --json <word>...   # pages containing all words; proper nouns, command names, paths work best
wikictl get --json <path>         # frontmatter, body, links, backlinks and sha of one page
wikictl ls --json                 # pages in the search dirs
wikictl context                   # selected profile, repository, search dirs and their page counts
```

The search dirs are `global/`, `personal/`, `projects/<current project>/` and `machines/<this machine>/`. `--dirs a,b` searches others and `--dirs .` the whole wiki.

Words match as case-insensitive substrings with no synonyms, stemming or relevance ranking:

- Pass each term as its own argument. A quoted `"local LLM"` matches only that exact spacing.
- Avoid one- or two-letter Latin words: `go` or `ai` also match inside longer words.
- Results are ordered by last update and capped at 20 (`-n`). Choose what to read from `summary`, not from position; add a word when the list is long.

An empty result, or results whose `summary` does not answer the question, does not yet mean the wiki lacks the answer. Retry in this order, stopping when a `summary` answers the question:

1. Fewer words, a synonym, or the term in the other language of the wiki (`リランカー` / `reranker`).
2. The same queries with `--dirs .`: knowledge about a tool or another project may live outside the current search dirs.

Only when these also fail, find the answer elsewhere and consider recording it. If a page has an old `updated` or a `contradicts` link, say so instead of presenting the value as settled.

## Write

1. `search` for a page answering the same question.
2. New page: `wikictl put --json <path> < page.md`.
3. Existing page: `get --json` it, rebuild the page in a temporary file, edit, then `wikictl put --json --base <sha> <path> < page.md`. `get` prints `frontmatter`, `body` and `links` separately, not the raw page: write the frontmatter as YAML between `---` lines, then the body (it already starts with the `# title` heading), then `## Links` with one `- <type>: [<title>](<path>) | <note>` per link, where `<path>` is `target` made relative to the page's directory. The `sha` printed by `put` is valid for the next `--base`.

A page is frontmatter, a title, the body, and, when it has links, a `## Links` section last. Always write a one-line `summary`: search results show it. `type` is optional (concept, procedure, decision, policy, observation, event, index, source). Write links to pages as `[text](path)`, a path relative to the page: `mv` rewrites only that form. Name files and directories with lowercase letters, digits and hyphens.

```markdown
---
summary: Go on laptop is 1.26.5, installed with goenv under ~/.anyenv
type: observation
---
# Which Go is installed on laptop?

`go version` prints go1.26.5; goenv manages it.

## Links
- part_of: [index](index.md)
- cites: https://go.dev/dl/ | release list
```

`put` prints warnings (missing summary, broken link, name style) on standard error and still writes the page. Fix them.

## Placement

Choose the narrowest scope that fits:

| Directory | Knowledge valid |
|---|---|
| `projects/<name>/` | in one project |
| `machines/<name>/` | in one execution environment |
| `personal/` | only for this user, on every machine and in every project |
| `global/` | for everyone |

Before creating a directory, run `wikictl dirs` (whole wiki, page counts, `index.md` summaries) and reuse an existing one when it fits. When a directory is new or shows `(no index)`, create its `index.md` (`type: index`, a `summary` of what the directory holds, a title; no Links section needed) and link its pages to it with `- part_of: [index](index.md)`. `get <dir>/index.md` then lists them as `backlinks`; do not maintain a list by hand.

Never write secrets; write the secret's name instead. Cite sources by URL.

## Exit codes

| Code | Meaning | Action |
|---|---|---|
| 1 | error, such as a page that does not exist | Show the message |
| 2 | usage error, not configured, or a configuration error such as an unknown key or profile | Show the message; run `/wikictl:setup` when no config exists |
| 3 | conflict; `reason` in the output says which | `exists` from `put`: the page exists, so `get` it and update with `--base`, or choose another path. `changed` from `put`: if `content` lacks the change, reapply it and `put` again with `--base <sha>`; if it already has it, stop. Empty `sha` and `content`: the page was deleted since it was read; ask before recreating it. From `mv` or `rm`: nothing was written; re-read the page and run the command again |
| 4 | `put`, `mv` or `rm`: invalid frontmatter, a page over the size limits, or a bad path (rules in `wikictl help lint`); `lint`: any finding | Fix and retry |
| 5 | git failure while reading or writing; no partial result is printed | Report the message; do not retry blindly, and do not treat a failed `search` as an empty result |

`mv` moves a page or a directory and rewrites links to it; `rm` deletes a page; `lint` reports format findings.
