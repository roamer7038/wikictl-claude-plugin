# wikictl-claude-plugin

[日本語版](README.ja.md)

A Claude Code plugin for reading and recording knowledge in a Markdown wiki through [wikictl](https://github.com/roamer7038/wikictl). It consists of one skill, `wikictl`, and a thin script that logs how often the skill is used.

## Prerequisites

- `wikictl` on `PATH`. Install it with
  `curl -fsSL https://raw.githubusercontent.com/roamer7038/wikictl/main/install.sh | sh`
  or `go install github.com/roamer7038/wikictl/cmd/wikictl@latest`.
- `~/.config/wikictl/config.yaml` pointing at your wiki repository (see the wikictl README).

## Install

From the marketplace, inside Claude Code:

    /plugin marketplace add roamer7038/wikictl-claude-plugin
    /plugin install wikictl@wikictl-claude-plugin

For local development:

    claude --plugin-dir /path/to/wikictl-claude-plugin

## What the skill does

It tells Claude when to consult the wiki (environment-specific values, past decisions, failing commands, before writing a new page) and how to search, read and record pages with `wikictl`, including how to resolve write conflicts. Every call goes through `scripts/wikictl-logged.sh`.

## Usage log

The script appends one line per call to `${XDG_DATA_HOME:-~/.local/share}/wikictl/usage.log`: timestamp, subcommand, exit code. It exists to see whether the wiki is actually consulted and written to over time. wikictl itself records nothing.

## Scope

- The plugin does not touch CLAUDE.md; the skill description is the entry point.
- No hooks (SessionStart listing, Stop reminder) and no MCP server yet. They will be added to this plugin if usage shows they are needed.

## License

[MIT](LICENSE)
