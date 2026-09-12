#!/usr/bin/env sh
# wikictl を実行し、利用状況を 1 行記録する（成功基準「参照される」の計測用）。
# 記録: 日時 TAB サブコマンド TAB 終了コード
set -u
log_dir="${XDG_DATA_HOME:-$HOME/.local/share}/wikictl"
mkdir -p "$log_dir"
sub=""
for a in "$@"; do
  case "$a" in
    -*) ;;
    *) sub="$a"; break ;;
  esac
done
wikictl "$@"
rc=$?
printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$sub" "$rc" >> "$log_dir/usage.log"
exit $rc
