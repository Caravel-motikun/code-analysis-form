# Multi-View Analysis Context

Pattern C Multi-View V3、sessionlog_mentalmodel_builder、Agent Builder用Instructionsの設計思想を再利用するコンテキスト一式。

## 読む順序

1. [引き継ぎ](docs/design-handoff.md)：目的、到達点、未取得物、次の作業
2. [設計判断](agents/module-analysis/design-rationale.md)：変更理由と再検討しない前提
3. [共通モデル](docs/architecture/multiview-analysis-model.md)：情報構造と整合性
4. [V3生成仕様](templates/pattern-c-v3-spec.md)
5. [セッション生成仕様](templates/sessionlog-spec.md)

## 出力HTMLサンプル

- [モジュール解析サンプル](examples/scores_analysis.html)：架空の点数集計コードを解析した7ビュー。
- [セッション整理サンプル](examples/demo_sessionlog.html)：架空ログの判断・未解決事項・Handoff。

どちらも元会話のHTML原本ではなく、新規生成した完成例。コードの実行試験は未実施。
入力はexamples/inputs、共通モデルはexamples/dataに保存。node scripts/build-examples.mjsで再生成する。
GitHub Pages入口にも掲載。各HTMLはダウンロードして単体で閲覧できる。

## Instructionsの利用

- モジュール解析：[Agent Builder Instructions](agents/module-analysis/instructions.md) を単一プロンプトとして使用。
- セッション整理：[Session Instructions](agents/sessionlog/instructions.md) を使用。
- 対象・範囲・実行条件：[TASK.md](TASK.md) をコピーして埋める。

InstructionsはAgent Builderの実行可能ワークフロー定義ではなく、Instructions欄に渡すテキスト。解析対象へのアクセスや保存機能は実行環境側で用意する。

## 出典と復元範囲

[設計議論の抜粋](docs/sources/design-discussion.md) は参照会話「HTML参照例提案」の9件を収録。全21ターンを確認済み。
最終モジュールInstructionsは会話のwriting block本文を取得して保存した。
その他の仕様・引き継ぎ・Session Instructionsは会話から今回再構成したもの。

[旧Pattern C HTML](references/pattern-c-review-cognitive-original.html) は取得できた添付原本。V3ではない。
V3およびsessionlogの完成HTML本体は未取得であり、この一式に同名の原本があるとは扱わない。
旧HTML内のstatsは見本であり、解析対象リポジトリの実装事実ではない。

## Gitへの保存

既存リポジトリの規則と変更を確認し、専用ブランチでこの一式を配置する。
対象ファイルだけをstageし、diffと検証結果を確認してcommit・pushする。
mainへ直接pushしない。mergeやGitHub Pages公開はこの作業に含めない。
