# wikictl-claude-plugin

[English](README.md)

Claude Code から [wikictl](https://github.com/roamer7038/wikictl) で Markdown wiki を参照・記録するためのプラグイン。中身はスキル 2 つだけで、フック・MCP・スクリプトはありません。

## 導入

Claude Code 内で:

    /plugin marketplace add roamer7038/wikictl-claude-plugin
    /plugin install wikictl@wikictl-claude-plugin

その後 `/wikictl:setup` を一度実行します。開発中は `claude --plugin-dir /path/to/wikictl-claude-plugin`。

wikictl v0.1.0 で確認しています。

## 構成

```
.claude-plugin/
  plugin.json          プラグインのマニフェスト
  marketplace.json     マーケットプレイスのマニフェスト（このリポジトリ自身がマーケットプレイス）
skills/
  wikictl/SKILL.md     ページの参照と記録。Claude が自分の判断で使う
  setup/SKILL.md       wikictl の導入、設定、wiki の作成。/wikictl:setup で実行
```

## フロー

```mermaid
flowchart TD
    subgraph setup["/wikictl:setup"]
        S1[wikictl version] -->|無い| S1a[install.sh]
        S1 --> S2[config.yaml] -->|無い| S2a[repo URL と author を確認して書き出す]
        S2 --> S3[リモートリポジトリ] -->|無い| S3a[gh repo create か利用者が作成]
        S3 --> S4[wikictl init] --> S5[wikictl context]
    end
    subgraph use["wikictl スキル（通常の作業中）"]
        U1[質問・失敗・新しい事実] --> U2[wikictl search --json]
        U2 --> U3[wikictl get --json]
        U3 --> U4[回答、または wikictl put --json]
        U4 -->|exit 3| U3
        U4 -->|exit 2| setup
    end
```

## スキル

### wikictl

いつ wiki を見るか、どう読み書きするかを Claude に伝えます。

- 環境固有の値、過去の判断や規則を答える前、コマンドが失敗したとき、新しいページを書く前に読む。
- 作業で再利用できる事実が得られたら書く。会話の要約、常時守る指示（CLAUDE.md）、手順（スキル）は書かない。
- 既存ページは `put --base <sha>` で更新し、終了コード 3 なら読み直して変更を再適用する。
- 置き場所は `global/`、`projects/<name>/`、`machines/<name>/` のうち狭い方。

書式の細則は `wikictl help` と wikictl の README に委ね、スキルには判断に必要なことだけを書いています。

### setup

導入を順に進め、確認が通る段階は飛ばします。バイナリ（wikictl のリリースから `install.sh`）、`~/.config/wikictl/config.yaml`（リポジトリ URL と `claude-code@<hostname>` のような author）、リモートリポジトリ（`gh` があれば `gh repo create`）、`wikictl init`、最後に `wikictl context`。インストール・書き込み・push を伴う段階は毎回利用者に確認します。引数にリポジトリ URL を渡すと質問を省けます: `/wikictl:setup git@github.com:you/wiki.git`。

## ライセンス

[MIT](LICENSE)
