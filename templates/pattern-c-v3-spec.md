# Pattern C Multi-View V3 再生成仕様

これは会話S01–S05/S07/S08から再構成した意味構造の仕様。完成V3 HTMLの原本ではない。
詳細な生成規則は[最終Instructions](../agents/module-analysis/instructions.md)にある。

## 7つの表示契約

| 種別 | 名称 | IN | OUT・終了条件 |
|---|---|---|---|
| D1 | Understanding | 読者の到達目標、具体例、用語、入口、因果、状態変化、正常/失敗、利用時の判断 | 関数数でセルを分割しない。セル単体で説明・判断できる |
| D2 | External Design | 公開入口・型・引数・戻り値・所有権・寿命・エラー・保証・設定・受入条件 | 実装都合を公開保証として扱わない |
| D3 | Internal Design | 構成・依存・内部データ・処理・確定点・エラー伝播・資源・並行性・性能・試験・変更影響 | 不明な内部仕様を補完しない |
| V1 | Definition / MDN | 1〜2文の定義、短い補足、Key terms、See also | 詳細処理・全関数・全エラーなし。10〜30秒 |
| V2 | Concept / K8s | What、Why、Mental Model、抽象概念、責務、関係、動作、状態、用途、失敗、境界 | 全シンボル・行単位追跡・完全API一覧なし。概念を把握 |
| V3 | Symbol Reference / Rustdoc | 宣言・引数・戻り値・前提・副作用・所有権・寿命・定義位置・Evidence | 長い設計思想なし。契約を引ける |
| V4 | Relation / Impact | caller/callee、参照、read/write、型・資源・import、変更時に確認すべき範囲 | 未調査の全体網羅を断定しない |

DOCUMENT 3タブとQUICK VIEW 4タブの2段ナビゲーション。
各Quick View冒頭にIN/OUTを表示する。MDN等は文書様式の呼称であり、外部サイトの実装への依存ではない。
ConceptのWhat/Failureも根拠があって初めてFACT。Why/Mental Modelは根拠が直接なければINFERENCE。

## 共通UI

自己完結HTML、埋め込みCSS/JS、外部読込なし。
文字付き4分類LegendとBadge、Evidenceリンクと末尾の折りたたみ根拠一覧。
Conceptは概要を先に、詳細をdetailsへ。
canonical-analysisというIDのapplication/jsonにモデルを埋め込む。
明るい背景、高可読性、表の横スクロール、モバイル対応、キーボード操作、aria対応。
印刷時は全7表示と必要な根拠を読めるようにし、操作UIを非表示にする。
作成者モードは任意。未記入例やガイドを通常の解析結果と混ぜない。

## 受入検査

- source_scopeが明示され、FACTの根拠、推論の導出元、未確認範囲が追える。
- 同じ契約・状態・失敗保証が7表示で矛盾しない。
- ID重複、内部リンク切れ、tab/tabpanel対応漏れがない。
- JSONをパースでき、JavaScript構文が正常。外部読込がない。
- クリックとキーボードで切替可能。別タブや閉じたEvidenceへのリンク先を表示できる。
- 狭い画面と印刷で内容が欠けない。
- 試験案と実施結果を区別し、未実行項目を「検証済み」にしない。

出力：対象名_analysis.html。架空stats例の主張は実際の対象へ流用しない。
