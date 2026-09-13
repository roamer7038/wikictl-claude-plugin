---
name: setup
description: Install the wikictl CLI, write its configuration and create the initial pages of a wiki. Use when the user asks to set up wikictl or a wiki, or when a wikictl command exits with code 2 (not configured).
allowed-tools: Bash
---

# Set up wikictl

Goal: `wikictl context` succeeds and the wiki repository has its initial pages. Arguments, if given, are the wiki repository URL: `$ARGUMENTS`.

Work through the steps in order and skip any step whose check already passes. Show each command before running it; installing a binary, writing a config file, creating a repository and pushing are all confirmed with the user first.

## 1. Binary

Check: `wikictl version`.

If missing, install the latest release into `~/.local/bin` (Linux and macOS, needs `curl` and `git`):

```bash
curl -fsSL https://raw.githubusercontent.com/roamer7038/wikictl/main/install.sh | sh
```

`WIKICTL_INSTALL_DIR` changes the directory, `WIKICTL_VERSION` pins a tag. If `~/.local/bin` is not on `PATH`, tell the user what to add to their shell profile. `go install github.com/roamer7038/wikictl/cmd/wikictl@latest` is the alternative when Go is available.

## 2. Configuration

Check: `wikictl context`. Exit code 2 means there is no usable config: continue here. Exit code 5 means the config was read but the repository is not reachable yet: go to step 3.

The file is `$WIKICTL_CONFIG` if that variable is set, otherwise `${XDG_CONFIG_HOME:-~/.config}/wikictl/config.yaml`. If it exists, show it and fix only what is wrong. Otherwise collect:

- `repo`: URL of the wiki repository. Ask if not given as an argument. `git push` to it must work without prompting (SSH key or credential helper); the push in step 4 is the test.
- `author.name` / `author.email`: propose `claude-code@<hostname>` and `claude-code@<hostname>.invalid` so wiki commits by the agent are distinguishable from the user's. Without `author`, wikictl uses `git config user.name` / `user.email`.

```yaml
repo: git@github.com:you/wiki.git
author:
  name: claude-code@laptop
  email: claude-code@laptop.invalid
```

The optional keys (`branch`, `machine`, `dirs`, `projects`) are described in the Configuration section of the [wikictl README](https://github.com/roamer7038/wikictl#configuration).

## 3. Repository

Check: `git ls-remote <repo>` succeeds.

If the repository does not exist: on GitHub with `gh` logged in, offer `gh repo create <owner>/<name> --private`, where `<owner>/<name>` are the last two path segments of the URL without `.git`; otherwise ask the user to create an empty repository on their Git host and continue when done. A private repository is the safe default for a knowledge base.

## 4. Initial pages

Check: `git ls-remote --heads <repo>` prints a branch.

If it prints nothing, run `wikictl init`. It commits `README.md` and `global/index.md` and pushes them. If a branch already exists, `init` fails with exit code 1 and nothing needs to be done.

## 5. Verify

```bash
wikictl context      # exit 0; resolved config, machine, project and search dirs
wikictl ls --json    # the pages in the default dirs
```

Report the config path, the author, the repository and the search dirs. From here on the `wikictl` skill of this plugin handles reading and recording.
