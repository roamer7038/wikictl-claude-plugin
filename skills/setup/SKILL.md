---
name: setup
description: Install or update the wikictl CLI, write its configuration or add a profile for another wiki, and create the initial pages of a wiki. Use when the user asks to set up wikictl or a wiki, or when a wikictl command exits with code 2 because no configuration exists.
allowed-tools: Bash
---

# Set up wikictl

Goal: `wikictl context` succeeds with the intended repository and the repository has its initial pages. Arguments, if given, are the wiki repository URL: `$ARGUMENTS`.

Work through the steps in order and skip any step whose check already passes. Show each command before running it; installing or updating a binary, writing the config file, creating a repository and pushing are all confirmed with the user first.

## 1. Binary

Check: `wikictl version` prints v0.3.0 or later.

If it is missing or older, install the latest release into `~/.local/bin` (Linux and macOS, needs `curl` and `git`):

```bash
curl -fsSL https://raw.githubusercontent.com/roamer7038/wikictl/main/install.sh | sh
```

`WIKICTL_INSTALL_DIR` changes the directory, `WIKICTL_VERSION` pins a tag. If an older `wikictl` elsewhere on `PATH` still wins, point that out. If `~/.local/bin` is not on `PATH`, tell the user what to add to their shell profile. `go install github.com/roamer7038/wikictl/cmd/wikictl@latest` is the alternative when Go is available.

`install.sh` checks the binary against `checksums.txt`. When the user wants to verify where a release binary was built and `gh` has the `attestation` command (older `gh` releases lack it), download it and run `gh attestation verify <file> -R roamer7038/wikictl`; releases before v0.3.0 have no attestation.

After updating from a version before v0.3.0, the first command creates a new mirror under `~/.cache/wikictl/`, named after a hash of `repo`. The old mirror directories, named after `repo` with `/ : @ \` replaced by `_` (such as `https___github.com_you_wiki.git`), are no longer used: list them and offer to delete them.

## 2. Configuration

Check: `wikictl context`.

- Exit code 0 and `repo` is the intended repository: go to step 4.
- Exit code 0 and `repo` is another wiki: add a profile as below.
- Exit code 2 with a missing config file: write one as below.
- Exit code 2 with another message (unknown key, undefined profile, several matching profiles): fix what the message names.
- Exit code 5: the config was read but the repository is not reachable; go to step 3.

After writing or fixing the file, run the check again until it reaches step 3 or 4.

The file is `$WIKICTL_CONFIG` if that variable is set, otherwise `${XDG_CONFIG_HOME:-~/.config}/wikictl/config.yaml`. For a new file collect:

- `repo`: URL of the wiki repository. Ask if not given as an argument. `git push` to it must work without prompting (SSH key or credential helper); the push in step 4 is the test. Never put a password or token in the URL (`https://user:token@...`): git saves it in the mirror as it is. If an existing `repo` has one (`context` shows it as `***@`), propose moving it to a credential helper or an SSH URL.
- `author.name` / `author.email`: propose `claude-code@<host>` and `claude-code@<host>.invalid`, where `<host>` is the hostname up to the first `.`, so the agent's commits are distinguishable from the user's. Without `author`, wikictl uses `git config user.name` / `user.email`.

```yaml
repo: git@github.com:you/wiki.git
author:
  name: claude-code@laptop
  email: claude-code@laptop.invalid
```

If the file already points at another wiki that must keep working, do not overwrite `repo`. Move both wikis into `profiles` and choose how each is selected: `default_profile`, `match.remotes` (globs over the `origin` remote of the current directory, such as `github.example.com/team/*`) or `match.paths` (absolute paths or paths starting with `~`, including everything below them). Unless the user says otherwise, the wiki that was already configured becomes `default_profile`.

```yaml
author:
  name: claude-code@laptop
  email: claude-code@laptop.invalid
default_profile: personal
profiles:
  personal:
    repo: git@github.com:you/wiki.git
  work:
    repo: git@github.example.com:team/wiki.git
    match:
      remotes: ["github.example.com/team/*"]
      paths: ["~/work"]
```

When a profile was added, run every `wikictl` command from the step 2 re-check to step 5 with `--profile <name>`: without it, the profile selected for the current directory is used, which may be the other wiki. The only exception is the final `profile_source` check in step 5.

An unknown key is an error, so copy key names exactly. The other keys (`branch`, `machine`, `dirs`, `projects`) and the profile rules are in the [wikictl README](https://github.com/roamer7038/wikictl#configuration).

If several people will share the wiki, mention that everyone searches the same `personal/`: either leave it unused or set `dirs`.

## 3. Repository

Check: `git ls-remote <repo>` succeeds.

If the repository does not exist: on GitHub with `gh` logged in, offer `gh repo create <owner>/<name> --private`, where `<owner>/<name>` are the last two path segments of the URL without `.git`; otherwise ask the user to create an empty repository on their Git host and continue when done. A private repository is the safe default for a knowledge base.

## 4. Initial pages

Check: `git ls-remote --heads <repo>` prints a branch.

If it prints nothing, run `wikictl init`. It commits `README.md` and `global/index.md` and pushes them. `init` exits with code 1 when the branch already exists; that means nothing needs to be done only if `wikictl context` shows the intended `repo`.

## 5. Verify

```bash
wikictl context      # exit 0; profile, repo, author and search dirs with page counts
wikictl dirs         # directories of the whole wiki
```

If `wikictl dirs` shows that the knowledge for the current project already lives under another `projects/<name>/` (for example, the project is a plugin or a fork of a tool whose pages are in `projects/<tool>/`), `projects/<current project>/` in the search dirs misses it. Propose mapping the project in the config, keyed by the last path segment of the `origin` remote without `.git`:

```yaml
projects:
  wikictl-claude-plugin: wikictl
```

Report the config path, the selected profile and how it was selected, the repository, the author name and the search dirs. When profiles are used, also run `wikictl context` without `--profile` from a directory each profile should match and confirm `profile_source`. From here on the `wikictl` skill of this plugin handles reading and recording.
