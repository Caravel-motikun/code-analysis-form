# sessionlog_mentalmodel_builder 再生成仕様

会話S06から再構成。目的は会話の圧縮ではなく、得た知識・判断・未解決事項を次へ引き継ぐこと。
完成HTML本体は未取得。

## DOCUMENT

- D1 Session Understanding：目的、開始時の見立て、決定的だった確認、到達したMental Model、確定事項、深掘りしなかった範囲。
- D2 Decision & Work Record：Decision Ledger、試行・実験、変更Artifact、検証結果、却下・延期案。
- D3 Handoff：Current state、Do not rediscover、Open loops、次セッションの最初の行動、Definition of done。

## QUICK VIEWの契約

| View | IN | OUT・終了条件 |
|---|---|---|
| V1 Snapshot | 目的・結果・残件の短い説明 | 全発言・全試行なし。10秒でセッションの意味を把握 |
| V2 Mental Model | 初期仮説、転機となるEvidence、変わった理解、現在の説明モデル | 単なる時系列羅列なし。なぜ理解が変わったか分かる |
| V3 Decision Index | 採用・却下・延期、理由、根拠、関連Artifact | 未採用案を決定としない。判断を検索できる |
| V4 Timeline / Impact | 時系列、転機、因果、変更物、次への影響 | 時間順を因果の証明にしない。関係FACTと影響INFERENCEを分ける |

4分類を維持し、DECISIONを独立した記録種別として追加。
EvidenceはE0001形式でtimestamp、speaker/tool、発言/ログ位置、
code inspection、patch、test resultなどの原資料断片とsupportsを保持する。
時刻や実行結果が欠けていればUNKNOWN。成功を作り出さない。

Canonical Session Modelの項目と共通規則は[共通モデル](../docs/architecture/multiview-analysis-model.md)を参照。
HTMLはモジュール版と同じ7タブ、外部依存なし、Evidence内部リンク、埋め込みJSON、印刷、キーボード操作を備える。

## 検証

判断の採否と実装状態が混ざっていないこと。
次の行動が未解決事項に対応すること。完了条件が観測可能であること。
ログ欠落・未取得Artifact・実行未確認を明記すること。
根拠なしの因果や成果を追加しないこと。
HTML構造の検査は[V3仕様](pattern-c-v3-spec.md)と共通。
