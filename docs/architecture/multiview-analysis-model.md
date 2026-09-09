# 共通解析モデル

## パイプライン

対象と調査範囲 → Evidence抽出 → Canonical構築 → 確度分類と矛盾確認 → DOCUMENT → QUICK VIEW → 単一HTML → 検証。

モデルは一つ。表示上の重複は許可するが、主張は同じIDを参照する。
新しい事実が必要になったら対象調査とCanonicalへ戻る。

## モジュールの項目

source_scope、subject、responsibilities、facts、inferences、proposals、unknowns、
symbols、relations、flows、states、errors、contracts、resources、tests、evidence。
V3で導入したview_contractsも保持する。単一Instructions内の最小モデルはこの追加を禁止していない。

- source_scope：対象root/files、版・commit（未取得ならnull）、caller/callee、設定・資源、未確認範囲、repository_wide、runtime_verified。
- FACT：id、claim、evidence ID。コード読解で言えることと実行結果で言えることを分ける。
- INFERENCE：id、claim、derived_fromで根拠FACTを参照。説明モデル・予測であることを明示。
- PROPOSAL：id、claim、必要ならderived_from。現状の契約に混入させない。
- UNKNOWN：id、claim、未確認理由と次に確認するもの。
- Evidence：E0001形式、file/location/symbol/source_fragment/supports。
- relations：from/to/kind/status/evidence、推論なら根拠参照。
- view_contracts：目的、IN、OUT、終了条件。

空の一覧は「不存在が証明された」の意味ではない。各対象の調査状態をsource_scope等に記録する。

## セッションへの写像

session、source_scope、facts、inferences、proposals、unknowns、decisions、events、
artifacts、relations、open_loops、handoff、view_contractsを使用し、evidenceを保持する。
このevidenceの明示フィールドは、元会話S06のEvidence保持要件を機械可読にする再構成。

| モジュール | セッション |
|---|---|
| 対象コードと版 | 対象ログ、期間、セッションID、欠落区間 |
| コード位置・シンボル | timestamp、speaker/tool、message ID/ログ位置 |
| 外部契約・内部実現 | 判断と作業・変更Artifact・検証 |
| 変更影響 | 判断や変更が次の作業へ与える影響 |
| 未確認領域 | Open loopsとHandoff |

decisionsはid、論点、選択肢、採用/却下/延期、理由、根拠ID、関連artifactを持つ。
eventsは順序・時刻（不明ならnull）・行動・観測結果・根拠を持つ。
artifactsはパス・変更内容・状態を持ち、提案、作成、commit、push、検証を分ける。
handoffはcurrent_state、do_not_rediscover、open_loops、next_actions、definition_of_done。

## 参照整合性

Evidence ID、claim ID、symbol/artifact IDはそれぞれ一意。
FACTのevidence、INFERENCEのderived_from、relationsの端点は存在するレコードへ解決する。
根拠断片が本当に主張を支持するかも読む。IDがあるだけでは十分でない。
ログの「テストした」という発言はその発言の根拠であり、ツール結果を取得したことと同一ではない。

## HTMLへの安全な投影

コード・ログはテキストとしてエスケープする。
JSONをscript要素に埋める際は、小なり記号をJSONのUnicodeエスケープにする等で、
入力中の終了タグがHTMLを閉じないようにする。
JSONを装飾用文字列ではなくパース可能なデータとして保持する。
