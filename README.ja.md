# wikictl-claude-plugin

[English](README.md)

Claude Code から [wikictl](https://github.com/roamer7038/wikictl) で Markdown wiki を参照・記録するためのプラグイン。中身はスキル `wikictl` と、利用状況を記録する薄いスクリプトです。

## 前提

- `wikictl` が `PATH` 上にあること。導入は
  `curl -fsSL https://raw.githubusercontent.com/roamer7038/wikictl/main/install.sh | sh`
  または `go install github.com/roamer7038/wikictl/cmd/wikictl@latest`。
- `~/.config/wikictl/config.yaml` に wiki リポジトリを設定し、そこへの `git push` が対話なしで通り、`wikictl init` で初期化済みであること。手順は wikictl の README にあります。
- wikictl v0.1.0 で確認しています。

## 導入

マーケットプレイスから（Claude Code 内で）:

    /plugin marketplace add roamer7038/wikictl-claude-plugin
    /plugin install wikictl@wikictl-claude-plugin

開発中（ローカル）:

    claude --plugin-dir /path/to/wikictl-claude-plugin

## スキルの内容

いつ wiki を見るべきか（環境固有の値、過去の判断、コマンドの失敗、新規ページを書く前）と、`wikictl` でページを検索・取得・記録する手順、書込みの衝突の解き方を Claude に伝えます。すべての呼出しは `scripts/wikictl-logged.sh` を経由します。

## 利用記録

スクリプトは 1 回の呼出しごとに `${XDG_DATA_HOME:-~/.local/share}/wikictl/usage.log` へ「日時、サブコマンド、終了コード」を 1 行追記します。wiki が実際に参照・記録されているかを時系列で見るためのもので、wikictl 本体は何も記録しません。ログはローテーションしないので、不要になったら削除してください。

## 範囲

- CLAUDE.md は触りません。スキルの説明文が入口です。
- フック（SessionStart の一覧注入、Stop の促し）と MCP は入れていません。利用状況を見て必要なら同じプラグインに足します。

## ライセンス

[MIT](LICENSE)
