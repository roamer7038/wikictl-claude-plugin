# wikictl-claude-plugin

[日本語版](README.ja.md)

A Claude Code plugin that lets Claude read and record knowledge in a Markdown wiki through [wikictl](https://github.com/roamer7038/wikictl). It contains two skills and nothing else: no hooks, no MCP server, no scripts.

## Install

Inside Claude Code:

    /plugin marketplace add roamer7038/wikictl-claude-plugin
    /plugin install wikictl@wikictl-claude-plugin

Then run `/wikictl:setup` once. For local development: `claude --plugin-dir /path/to/wikictl-claude-plugin`.

Requires wikictl v0.3.0 or later; `/wikictl:setup` installs or updates it.

## Structure

```
.claude-plugin/
  plugin.json          plugin manifest
  marketplace.json     marketplace manifest (this repository is its own marketplace)
skills/
  wikictl/SKILL.md     read and record pages; Claude invokes it on its own
  setup/SKILL.md       install or update wikictl, write the config, create the wiki; run as /wikictl:setup
```

## Flow

```mermaid
flowchart TD
    subgraph setup["/wikictl:setup"]
        S1[wikictl version] -->|missing or older than v0.2.0| S1a[install.sh]
        S1 --> S2[wikictl context] -->|no config| S2a[ask repo URL and author, write file]
        S2 -->|another wiki exists| S2b[add a profile]
        S2 --> S3[remote repository] -->|missing| S3a[gh repo create, or the user creates it]
        S3 --> S4[wikictl init] --> S5[wikictl context and dirs]
    end
    subgraph use["wikictl skill, during normal work"]
        U1[question, failure, or new fact] --> U2[wikictl search --json]
        U2 --> U3[wikictl get --json]
        U3 --> U4[answer]
        U3 --> U5[wikictl dirs, choose placement]
        U5 --> U6[wikictl put --json]
        U6 -->|exit 3| U3
        U6 -->|exit 2| setup
    end
```

## Skills

### wikictl

Tells Claude when to consult the wiki and how to read and write pages:

- Read before answering with environment-specific values, the user's conventions, past decisions or rules, when a command fails, and before writing a new page.
- Search with one term per argument and choose pages by `summary`. When nothing answers the question, retry with a synonym or the other language and then with `--dirs .` before concluding that the wiki lacks it.
- Write when work yields a reusable fact. Conversation summaries and procedures (skills) are not recorded; a rule that must hold in every conversation is suggested for CLAUDE.md instead.
- Update an existing page with `put --base <sha>`; on exit code 3 re-read the page and reapply the change.
- Place pages in the narrowest of `projects/<name>/`, `machines/<name>/`, `personal/` and `global/`. Before creating a directory, check `wikictl dirs`; give each directory an `index.md` and link its pages to it with `part_of`.

Format details are delegated to `wikictl help` and the wikictl README; the skill repeats only what Claude needs to decide.

### setup

Walks through installation in order, skipping steps whose check already passes: the binary (`install.sh` from the wikictl releases, also to update an older version), the config file (repository URL and an author such as `claude-code@<hostname>`, or a new profile when another wiki is already configured), the remote repository (`gh repo create` when available), `wikictl init`, and a final `wikictl context` and `wikictl dirs`, proposing a `projects` mapping when the current project's pages live under a different directory. Each step that installs, writes or pushes is confirmed with the user. Pass the repository URL as an argument to skip the question: `/wikictl:setup git@github.com:you/wiki.git`.

## License

[MIT](LICENSE)
