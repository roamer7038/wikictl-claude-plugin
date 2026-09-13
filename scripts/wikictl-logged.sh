#!/usr/bin/env sh
# Run wikictl and append one line of usage to the log (to measure whether the wiki is consulted).
# Log format: timestamp TAB subcommand TAB exit code
set -u
log_dir="${XDG_DATA_HOME:-${HOME:-/tmp}/.local/share}/wikictl"
mkdir -p "$log_dir"
# The subcommand is the first argument that is neither a flag nor the value of --config / --dirs.
sub=""
skip=0
for a in "$@"; do
  if [ "$skip" = 1 ]; then skip=0; continue; fi
  case "$a" in
    --config|-config|--dirs|-dirs) skip=1 ;;
    -*) ;;
    *) sub="$a"; break ;;
  esac
done
wikictl "$@"
rc=$?
printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$sub" "$rc" >> "$log_dir/usage.log"
exit $rc
