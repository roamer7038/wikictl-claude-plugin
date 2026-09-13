---
name: wikictl
description: 環境固有の値（パス・版数・設定）、過去の判断や規則、コマンドの失敗と回避策を扱うとき、および再利用できる事実を得たときに使う。Git ホスト上の Markdown wiki を wikictl CLI で検索・取得・記録する。
allowed-tools: Bash
---

# wikictl で wiki を参照・記録する

wiki は Git ホスト上の Markdown リポジトリ。`wikictl` は常駐しない CLI で、`git` だけで読み書きする。
すべてのコマンドは `${CLAUDE_PLUGIN_ROOT}/scripts/wikictl-logged.sh` 経由で呼ぶ（利用状況を記録するだけで、引数と出力は `wikictl` と同じ）。`--json` を付けて機械可読にする。

## いつ使うか

- 環境固有の値（パス、版数、設定）、過去の判断、規則を答える前
- コマンドや手順が失敗したとき（既知の回避策を探す）
- 新しいページを書く前（同じ問いのページが無いか）
- 作業で再利用できる事実（失敗と回避策、環境固有の値、判断と理由、規約の変更）を得たとき

会話の要約、常時注入すべき指示（CLAUDE.md）、繰り返し実行する手順（Skills）は書かない。基準は「再取得コスト × 再利用確率」。

## 参照

```bash
W=${CLAUDE_PLUGIN_ROOT}/scripts/wikictl-logged.sh
$W search --json <語>...          # AND。語は固有名詞・コマンド名・パス。--any で OR
$W get --json <path>              # 本文・links・backlinks・sha。読むのは要るものだけ
$W ls --json                      # 既定 dirs（global, projects/<現在>, machines/<このマシン>）の一覧
$W context                        # 既定 dirs と設定の確認
```

- 検索結果の `summary` で読む対象を選ぶ。`updated` が古い、または `links` に `contradicts` があれば値を疑い、両論併記する。
- 既定の検索対象外を見るには `--dirs a,b`。`status: deprecated` を含めるには `--all`。

## 記録

1. `search` で同じ問いのページを探す。
2. あれば `get --json` で `sha` と内容を取り、一時ファイルに書き出して編集し、`put --base <sha>` で全文を置換する。無ければ `put`（`--base` 無し）で新規作成。

```bash
printf -- '---\nsummary: <問いへの答えを 1 文、100 字程度>\ntype: <concept|procedure|decision|policy|observation|event|index|source>\n---\n# <問い、または名詞句>\n\n<本文>\n\n## Links\n- part_of: [<題>](<相対パス>.md)\n- cites: <URL> | <何の根拠か>\n' | $W put --json <dir>/<slug>.md
$W put --json --base <sha> <path> < edited.md
```

- 終了コード 3 は衝突。出力の `content` と `sha` を読み直し、同じ変更を再適用して `--base <新しい sha>` で再度 `put`。
- 終了コード 4 は形式違反（summary 欠落、フロントマターの YAML 不正、slug 違反）。直して再実行。
- 置き場: 環境に依らない知識は `global/`、プロジェクト固有は `projects/<name>/`、マシン固有は `machines/<name>/`。迷えば狭い方。
- slug は小文字英数字とハイフン。リンクは当該ファイルからの相対パスで `.md` を含める。関係は末尾の `## Links` 節に `- <type>: [題](path) | 注記`。
- 未確定の結論は `summary: "仮: …"`。秘密は書かず参照名を書く。原典は URL（コミット固定の permalink）で引用する。

## 移動・削除・検査

```bash
$W mv <path> <newpath>            # 参照元のリンクも 1 コミットで書き換える
$W mv <dir>/ <newdir>/            # ディレクトリ単位
$W rm <path>
$W lint --json                    # summary 欠落、Links 節文法、内部リンク切れ
```
