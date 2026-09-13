# wikictl-claude-plugin

Claude Code から [wikictl](https://github.com/roamer7038/wikictl) で wiki を参照・記録するためのプラグイン。中身はスキル `wikictl` と、利用状況を記録する薄いスクリプト。

前提: `wikictl` が PATH 上にあり（`go install github.com/roamer7038/wikictl/cmd/wikictl@latest`）、`~/.config/wikictl/config.yaml` が設定済みであること。

## 導入

開発中（ローカル）:

    claude --plugin-dir /path/to/wikictl-claude-plugin

マーケットプレイスとして登録して導入（Claude Code 内で）:

    /plugin marketplace add roamer7038/wikictl-claude-plugin
    /plugin install wikictl@wikictl-claude-plugin

## 計測

スキルはすべての呼出しを `${XDG_DATA_HOME:-~/.local/share}/wikictl/usage.log` に「日時、サブコマンド、終了コード」で追記する。参照回数と put 数の推移を見るためのもので、wikictl 本体は何も記録しない。

## 方針

- CLAUDE.md は触らない。スキルの説明文が入口。
- フック（SessionStart の一覧注入、Stop の促し）と MCP は入れていない。使われ方を計測して必要なら同じプラグインに足す。
