# 解析対象指定

実行時に以下を埋める。プレースホルダーが残る場合は対象の解析を開始しない。

- 種別：{{module / sessionlog}}
- 対象パスまたはログ：{{target}}
- 調査範囲：{{scope}}
- 対象版・commit・期間：{{version_or_period}}
- 実行条件：{{static_only / tests_allowed / execution_allowed}}
- 読者と判断したいこと：{{audience_and_goal}}
- 出力パス：{{output}}

moduleはagents/module-analysis/instructions.md、
sessionlogはagents/sessionlog/instructions.mdを使用する。
完成見本なしで、Evidence → Canonical → 整合性 → DOCUMENT → VIEW → HTML → 検証の順で進める。
未知の設計意図・caller・試験結果を補完しない。
