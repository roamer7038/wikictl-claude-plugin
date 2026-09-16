# wikictl-claude-plugin

[English](README.md)

Claude Code から [wikictl](https://github.com/roamer7038/wikictl) で Markdown wiki を参照・記録するためのプラグイン。中身はスキル 2 つだけで、フック・MCP・スクリプトはありません。

## 導入

Claude Code 内で:

    /plugin marketplace add roamer7038/wikictl-claude-plugin
    /plugin install wikictl@wikictl-claude-plugin

その後 `/wikictl:setup` を一度実行します。開発中は `claude --plugin-dir /path/to/wikictl-claude-plugin`。

wikictl v0.4.1 以降が必要です。`/wikictl:setup` で導入・更新できます。

## 構成

```
.claude-plugin/
  plugin.json          プラグインのマニフェスト
  marketplace.json     マーケットプレイスのマニフェスト（このリポジトリ自身がマーケットプレイス）
skills/
  wikictl/SKILL.md     ページの参照と記録。Claude が自分の判断で使う
  setup/SKILL.md       wikictl の導入・更新、設定、最初のページの書き込み。/wikictl:setup で実行
```

## フロー

```mermaid
flowchart TD
    subgraph setup["/wikictl:setup"]
        S1[wikictl version] -->|無い、または v0.4.1 未満| S1a[install.sh]
        S1 --> S2[wikictl context] -->|設定が無い| S2a[repo URL と author を確認して書き出す]
        S2 -->|別の wiki が設定済み| S2b[プロファイルを追加]
        S2 --> S3[リモートリポジトリ] -->|無い| S3a[gh repo create か利用者が作成]
        S3 -->|空| S4[wikictl put で最初のページ] --> S5[wikictl context と tree -d]
        S3 --> S5
    end
    subgraph use["wikictl スキル（通常の作業中）"]
        U1[質問・失敗・新しい事実] --> U2[wikictl tree -d で範囲を決める]
        U2 --> U3[wikictl grep -il と ls -lt]
        U3 --> U4[wikictl cat・stat・links]
        U4 --> U5[回答]
        U4 --> U6[wikictl tree -d で置き場所を決める]
        U6 --> U7[wikictl put --json --base]
        U7 -->|exit 3| U4
        U7 -->|exit 2| setup
    end
```

## スキル

### wikictl

いつ wiki を見るか、どう読み書きするかを Claude に伝えます。

- 環境固有の値、利用者の規約、過去の判断や規則を答える前、コマンドが失敗したとき、新しいページを書く前に読む。
- wikictl はカレントディレクトリから対象のディレクトリを選ばない。そのため `wikictl tree -d` を見て、当てはまる `global`・`personal`・`projects/<name>`・`machines/<name>` を `grep -il --all-match -e <語> -e <語>` に渡し、`ls -lt` の `summary` で読むページを選ぶ。答えが見つからなければ、同義語や別の言語、次に wiki 全体で再検索してから wiki に無いと判断する。
- 作業で再利用できる事実が得られたら書く。会話の要約と手順（スキル）は書かない。毎回の会話で守る規則は、wiki ではなく CLAUDE.md への追加を提案する。
- 既存ページは `cat --json` の `content` と `sha` から `put --base <sha>` で更新し、終了コード 3 なら読み直して変更を再適用する。
- 置き場所は `projects/<name>/`、`machines/<name>/`、`personal/`、`global/` のうち最も狭いもの。この構成はこのプラグインの規約で、wikictl 自体はディレクトリ名に意味を持たせない。ディレクトリを作る前に `wikictl tree -d` を見る。名前を変えるときは `mv -T` を使う。

書式の細則は `wikictl help` と wikictl の README に委ね、スキルには判断に必要なことだけを書いています。

### setup

導入を順に進め、確認が通る段階は飛ばします。バイナリ（wikictl のリリースから `install.sh`。古い版の更新にも使う）、設定ファイル（リポジトリ URL と `claude-code@<hostname>` のような author。別の wiki が設定済みならプロファイルを追加。wikictl v0.4.0 で削除されたキーは削除を提案）、リモートリポジトリ（`gh` があれば `gh repo create`）、空のリポジトリなら `wikictl put` で最初のページ、最後に `wikictl context` と `wikictl tree -d`。インストール・書き込み・push を伴う段階は毎回利用者に確認します。引数にリポジトリ URL を渡すと質問を省けます: `/wikictl:setup git@github.com:you/wiki.git`。

## ライセンス

[MIT](LICENSE)
