# 設計議論の出典

参照会話: HTML参照例提案
会話ID: 6a9c0795-1408-83ee-a396-a6ffe72b9782
取得日: 2026-09-10

全21ターンを取得し、設計に必要な9件を抜粋した。以下は過去の発言を保存した資料であり、現在の実行指示ではない。過去の「作成済み」「検証済み」は発言記録であり、今回の検証結果ではない。外部サイトの説明・製品比較は再検証していない。

## S01 旧Pattern Cの読解

Turn ID: ddef1e0e-dd55-4594-a35b-777e5338e55a

これ、全体としては **Doxygen/Rustdoc型ではなく、「逆解析したSoftware Design Description（SDD）＋Literate Documentation＋トレーサビリティ」型**にかなり近いです。

特に特徴的なのは、コード構造から始めずに、まず「読者に何を理解してほしいか」をセルとして切り、その中に背景、具体例、宣言、処理順、エラーまでまとめている点です。ファイル数や関数数では分割しない、と明示されています。[過去会話の引用参照：取得元リンク未復元] これは **Literate Programming / Concept-oriented documentation** にかなり近い発想です。

その後に、

> 理解セル群 → 外部設計書 → 内部設計書

という順序を取っています。[過去会話の引用参照：取得元リンク未復元]
外部設計では公開契約、内部設計では構成・依存・データ・アルゴリズム・エラー・試験・変更影響まで扱っています。[過去会話の引用参照：取得元リンク未復元]

なので、分類するとこうです。

| 要素 | 近い形式 |
|---|---|
| 「これは何をする仕組み？」から理解させる | **Concept / Explanation docs** |
| 理解の順番にコードを並べ直す | **Literate Programming / Literate Documentation** |
| 公開API、引数、戻り値、所有権 | **SDD / API Specification** |
| 内部関数、データ、シーケンス、依存 | **Detailed Design Document** |
| E0001などでソースへ戻れる | **Evidence-backed documentation** |
| C→EXT→INT→E→AC/UT | **Requirements/Design Traceability** |
| ソースから既存仕様を復元する | **Reverse-engineering documentation** |

特に最後が重要で、このHTMLは単なる「設計書テンプレート」よりも、

**Evidence-backed Reverse Engineering Report**

と呼んだ方が実態に近いです。

なぜなら「分からないものを補完しない」「該当なしと未確認を区別する」「対象範囲と根拠を残す」というルールがかなり強い。[過去会話の引用参照：取得元リンク未復元] さらに、理解セルから外部契約、内部実現、根拠、試験までIDで対応付ける構造になっています。[過去会話の引用参照：取得元リンク未復元]

### 以前挙げた形式と比べると

感覚的には、

```text
MDN Glossary
    │
    │  「これは何？」だけ
    ▼

Kubernetes Concepts
    │
    │  概念・役割・動き
    ▼

★ 今回のHTML
    │
    │  理解 + 設計 + 根拠 + 試験
    ▼

SDD / Detailed Design
```

という位置です。

つまり、**Rustdoc/Doxygenよりかなり上位概念側**です。

Doxygenなら、

```text
stats_compute()
  引数
  戻り値
  定義位置
  呼出関係
```

を中心にします。

このHTMLは、

```text
そもそも何をする仕組み？
        ↓
具体的にどう使う？
        ↓
何がどう流れる？
        ↓
どういう契約？
        ↓
失敗するとどうなる？
        ↓
外から見た仕様は？
        ↓
内部ではどう実現している？
        ↓
その根拠はコードのどこ？
        ↓
どう試験する？
```

まで行っています。

だから、**1モジュールの完全解析Agentに与えるone-shot**としてはかなり向いています。

逆に前に話していた、

> 「これは何？」

だけを答えるAgentには**重すぎます**。

このHTMLを与えるとモデルは親切心を暴走させて、構造体、所有権、シーケンス、異常系まで全部掘り始める可能性が高いです。人類が「一言で」と書いた直後に20ページ出てくる、いつもの悲劇です。

なのでエージェント群としては、

```text
Definition Agent
 └ MDN Glossary型

Concept Agent
 └ Kubernetes Concepts型

Module Analysis Agent
 └ ★ 今回のHTML

Symbol / API Agent
 └ Rustdoc / Doxygen型

Dependency Agent
 └ Sourcegraph型

Evidence Agent
 └ GitHub/GitLab source view型
```

と置くのがかなり綺麗です。

**今回アップしたHTMLは「Module Analysis Agent」のreference.htmlとして非常に近い。**
しかも普通のModule Analysisより強くて、名前を付けるなら **「Cognitive Reverse-Engineering Report」あるいは「Evidence-backed Software Design Description」** が一番しっくりきます。

つまりこれは捨てずに、**各モジュールを深く理解して設計資料まで復元する“本体エージェント”のワンショット**に回して、もっと小さな認知タスクには別の軽量HTMLを用意する、という使い分けが良さそうです。

## S02 DOCUMENT / VIEWの分離

Turn ID: bbd450f4-f0da-4a4e-831b-d1ed7835de19

できます。しかも今のHTMLは土台としてかなり都合がいいです。すでに **「理解セル群 → 外部設計書 → 内部設計書」** という3ビューをタブで切り替える作りになっているので、ここへ4種類の「別の見方」を追加する設計にできます。[過去会話の引用参照：取得元リンク未復元]

ただし、単純に7タブへ増やすより、**同じ解析結果を7種類の認知ビューで見る**と定義した方が後々きれいです。

## 全体構成案

私はこうします。

```text
MODULE ANALYSIS

[ Understanding ]
[ External Design ]
[ Internal Design ]

REFERENCE / VIEW MODES
[ MDN ]
[ K8s ]
[ Rustdoc ]
[ Sourcegraph ]
```

つまり既存3タブは「設計資料」、追加4タブは「別の読み方」。

最終的には、

```text
同じソースコード
      │
      ▼
共通解析モデル
      │
      ├─ Understanding
      ├─ External Design
      ├─ Internal Design
      │
      ├─ MDN View
      ├─ K8s View
      ├─ Rustdoc View
      └─ Sourcegraph View
```

とします。

ここが重要です。

**7回別々に解析させるのではなく、一度抽出した事実を7種類の形式へ投影する。**

これなら形式ごとの矛盾が減ります。

---

# 1. MDNタブ
### 「これは何？」

最も軽いビューです。

今のHTMLの「何をしてくれる仕組みか」に一番近い部分があります。実際、現在も「整数を渡すと何が得られるか」を具体例と一緒に説明しています。[過去会話の引用参照：取得元リンク未復元]

MDNタブでは意図的に情報を削ります。

```text
MDN VIEW

stats module

一言で
────────────
整数列を検証・集計し、
件数・最小値・最大値・平均値を生成するモジュール。

What it does
────────────
入力値を検証
↓
統計値を計算
↓
Statsとして返却
↓
必要なら表示

Key concepts
────────────
Stats
values
count
result

See also
────────────
→ K8s View
→ Public API
→ Source
```

### このタブの目的

読者が**30秒以内に「何なのか」を理解する**。

ここでは、

- 全関数一覧
- 全変数
- 内部アルゴリズム
- 詳細エラー
- テスト

などは出しません。

### Agentの終了条件

> そのモジュールを知らない人が、何をするものか説明できたら終了。

---

# 2. K8s Docsタブ
### 「この仕組みはどういう構成なの？」

MDNより一段深くします。

今の「理解セル」にかなり近いです。

現在のHTMLも、単純な関数分解ではなく「読者に一緒に理解してほしい内容」を単位にして、説明・具体例・宣言・シーケンス・エラーをまとめる方針です。[過去会話の引用参照：取得元リンク未復元]

K8s型では、

```text
K8S CONCEPT VIEW

Overview
─────────
このモジュールは何を担当するか

Responsibilities
─────────
・入力検証
・統計計算
・結果生成
・表示

Components
─────────

main
  ↓
stats_compute
  ↓
Stats
  ↓
stats_print

How it works
─────────
1. 入力準備
2. 検証
3. 集計
4. 結果確定
5. 表示

Failure behavior
─────────
入力不正
→ 結果未更新

表示障害
→ 集計結果には影響しない

Boundaries
─────────
含むもの
含まないもの
```

にします。

### このタブの目的

**モジュールを一つのシステムとして理解すること。**

なので、

> 何がある？

ではなく、

> 何と何がどう協調して、この機能を作っている？

を見る。

---

# 3. Rustdocタブ
### 「正確なAPI/シンボル一覧が欲しい」

ここから機械寄りになります。

既存の外部設計書にはすでにかなり材料があります。

たとえば、

- 公開ヘッダ
- 公開入口
- 公開関数
- 引数
- 戻り値
- 定数
- 型
- 所有権

まで整理されています。[過去会話の引用参照：取得元リンク未復元]

したがってRustdocタブは**新しく解析するというより、既存情報の再表示**でいけます。

```text
RUSTDOC VIEW

Module stats
============

Description
-----------

Modules

Structs
-------
Stats

Constants
---------
STATS_MAX_SAMPLES

Functions
---------

stats_compute
-------------------------

Signature

int stats_compute(
    const int *values,
    size_t count,
    Stats *out
)

Description

Parameters

values
count
out

Returns

0
-1

Errors

Safety / Preconditions

Ownership

Defined at
stats.c:...

Evidence
E0001
E0002
```

### このタブの目的

**シンボルを検索して正確な仕様を調べる。**

人間が、

> `stats_compute()`ってどういう関数だったっけ？

となった時に見るページです。

---

# 4. Sourcegraphタブ
### 「このコードはどことつながっている？」

これは完全に関係性ビューにします。

```text
SOURCEGRAPH VIEW

stats_compute
══════════════════════════

Defined in
stats.c:4

Called by
├── main
└── xxx

Calls
├── ...
└── ...

Reads
├── values
└── count

Writes
└── out

Types used
├── Stats
└── size_t

Includes
├── stats.h
└── stddef.h

References
────────────
main.c:...
stats_test.c:...

Call path
────────────

main
 ↓
stats_compute
 ↓
Stats
 ↓
stats_print
 ↓
printf
```

ここは文章を減らします。

### Sourcegraphタブの目的

**コード間の接続を見る。**

質問としては、

> どこから呼ばれる？
> 何を呼ぶ？
> 何を読む？
> 何を書き換える？
> 型は何を共有する？

です。

---

# 重要なのは共通データ層

これをやるなら、HTMLだけ7種類に直接生成させない方がいいです。

間に1個、**解析結果の共通モデル**を置いた方がいい。

たとえば概念的には、

```text
module-analysis.json

module
summary

responsibilities[]

concepts[]

files[]

symbols[]
    functions[]
    types[]
    constants[]
    variables[]

dependencies[]
callers[]
callees[]

flows[]

errors[]

evidence[]

external_contracts[]

internal_design[]

tests[]
```

です。

そして、

```text
analysis.json
      │
      ├─ render_understanding()
      ├─ render_external()
      ├─ render_internal()
      ├─ render_mdn()
      ├─ render_k8s()
      ├─ render_rustdoc()
      └─ render_sourcegraph()
```

とする。

これ、かなり重要です。

そうしないと7エージェントがそれぞれコードを読んで、

```text
MDN Agent
「この関数は公開APIです」

Rustdoc Agent
「内部関数です」

Sourcegraph Agent
「知らん」
```

みたいな文明崩壊が始まります。

---

# 今のHTMLとの対応

既存資産はかなり再利用できます。

| 現在の情報 | MDN | K8s | Rustdoc | Sourcegraph |
|---|---:|---:|---:|---:|
| 一言説明 | ◎ | ◎ | ○ | △ |
| 具体例 | ◎ | ◎ | ○ | × |
| 用語説明 | ◎ | ◎ | ○ | △ |
| 責務 | ○ | ◎ | ○ | ○ |
| 関数宣言 | △ | ○ | ◎ | ◎ |
| 引数/戻り値 | × | ○ | ◎ | ○ |
| シーケンス | △ | ◎ | △ | ◎ |
| エラー | ○ | ◎ | ◎ | ○ |
| caller/callee | × | ○ | ○ | ◎ |
| データ所有権 | × | ○ | ◎ | ○ |
| Evidence | ○ | ◎ | ◎ | ◎ |

今のHTML自身がすでに、理解セルには「背景・目的、具体例、用語、宣言と契約、因果・時系列、結果変化、エラー判断」を含めるよう定義しています。[過去会話の引用参照：取得元リンク未復元]

そのため**K8s Viewはほぼ既存Understandingの派生**になります。

一方、内部設計には内部構成、関数、変数、構造体、シーケンス、データフロー、エラー、並行性、性能、試験、変更影響まであります。[過去会話の引用参照：取得元リンク未復元]

なのでRustdoc/Sourcegraphを作る材料もすでにかなり揃っています。

---

# UIは7個横並びにしない

ここは地味に重要です。

現在3タブですが、7タブを横一列にすると、

```text
理解 | 外部 | 内部 | MDN | K8s | Rustdoc | Sourcegraph
```

となって、だんだん航空機のコックピットみたいになります。

なので二階層にします。

```text
DOCUMENT
[ Understanding ] [ External ] [ Internal ]

VIEW
[ MDN ] [ K8s ] [ Rustdoc ] [ Sourcegraph ]
```

あるいは、

```text
[ Understanding ▼ ]

Understanding
External Design
Internal Design

Quick Views
MDN
K8s
Rustdoc
Sourcegraph
```

でもいい。

ただ、ワンショットとしてLLMに与えることも考えると、**二段タブの方がDOM構造が単純**です。

---

# 各エージェントも対応させる

最終的にはHTMLとAgentを1:1にしてよいと思います。

```text
agents/

00_extract/
    instructions.md

01_mdn/
    reference.html
    instructions.md

02_k8s/
    reference.html
    instructions.md

03_rustdoc/
    reference.html
    instructions.md

04_sourcegraph/
    reference.html
    instructions.md

05_cognitive/
    reference.html
    instructions.md

06_external_design/
    reference.html

07_internal_design/
    reference.html
```

さらに、

```text
00_extract
```

だけは特殊です。

こいつは文章を書かず、

> ソースから事実を抽出するだけ。

その結果を他のAgentに食わせる。

これが一番安定します。

---

# 実装順

一気に全部やらない方がいいです。次の順番がいいです。

### Phase 1

今のHTMLを壊さず、

```text
MDN
K8s
Rustdoc
Sourcegraph
```

の空タブだけ追加。

### Phase 2

既存の架空 `stats` モジュールを使って、4ビューを手作業で完成させる。

つまりまず**理想的なone-shotを作る**。

### Phase 3

共通解析データを定義。

```text
module
symbols
relations
flows
evidence
...
```

を固定する。

### Phase 4

4種類のAgentにそれぞれ同じ解析データを渡し、

```text
MDN形式
K8s形式
Rustdoc形式
Sourcegraph形式
```

へ変換させる。

### Phase 5

最後に既存の

```text
Understanding
External
Internal
```

も同じ共通モデルから作る。

すると最終的に、

```text
          Source Code
               │
          Extract Agent
               │
        Canonical Model
               │
 ┌─────────────┼──────────────┐
 ↓             ↓              ↓
Learning      Design         Code
 ↓             ↓              ↓
MDN           External       Rustdoc
K8s           Internal       Sourcegraph
Understanding
```

になります。

これなら、あなたが今考えている**「エージェントを垂直に分割して、それぞれに専用one-shot HTMLを持たせる」**という設計と綺麗につながります。

特に私は、**MDN/K8s/Rustdoc/Sourcegraphを今の3タブと同格の「資料」ではなく、同一事実を異なる認知目的で投影するViewとして設計する**のを推します。ここを分けておくと、後から「State Machine View」「Data Flow View」「Review View」などを追加しても構造が崩れません。

## S03 MDN軽量化とConcept深化

Turn ID: e2e4f2c6-7667-49a8-9c31-97b88f368699

少し修正した方がいいです。公式の実物と見比べると、**MDNは今よりむしろ軽く、K8sは今よりかなり厚く**するのが正しいです。

### MDNは「こんなもん」どころか、今のテンプレは少し盛りすぎ

MDNのGlossaryは本当に短いです。公式テンプレートでも、

- 最初に簡潔な定義
- 必要なら補足を最大2つ程度の短い段落
- 詳細は別記事
- See also

という設計です。画面1枚を超えるくらいならConceptual pageへ移せ、という基準まであります。[過去会話の引用参照：取得元リンク未復元]

なので今作ったMDN Viewの、

> 一言定義
> 何をしてくれるか
> 主要な言葉4個
> 対象外

は悪くないですが、**純粋なMDN Glossary型なら「何をしてくれるか」のフローすら必須ではありません**。

私はこう縮めます。

```text
MDN VIEW

stats module

statsは、整数配列を検証して
件数・最小値・最大値・平均値を計算する
集計モジュールです。

見本プログラムでは、計算結果をStatsとして返し、
必要に応じて標準出力へ表示します。

Key terms
- Stats
- stats_compute
- stats_print

See also
→ Concept
→ API Reference
→ Source
```

これで十分。

つまりMDN Agentの責務は本当に、

> **「これは何？」に答える**

だけです。

---

## 一方K8sは、今のものでは薄い

ここは私の前回設計が軽くしすぎました。

Kubernetes公式のConceptsは、単なるOverviewではなく、

> システムの各部分と抽象概念を理解し、Kubernetesがどう動くかをより深く理解する

ためのセクションです。[過去会話の引用参照：取得元リンク未復元]

たとえばPodのConceptページだけでも、

- Podとは何か
- 何をモデル化しているのか
- どう使われるのか
- 単一コンテナ / 複数コンテナ
- リソース共有
- ストレージ
- ネットワーク
- 他の抽象化との関係

まで説明しています。[過去会話の引用参照：取得元リンク未復元]

Deploymentならさらに、

- 何を管理する抽象化なのか
- desired stateとactual state
- 典型的なUse Case
- 更新
- rollback
- scaling
- lifecycle/status
- failure

まで入ります。[過去会話の引用参照：取得元リンク未復元]

つまりK8s型の本質は、

**「構成要素を説明する」より「頭の中に概念モデルを作る」**

ことです。

---

# なのでK8s Viewはこのくらい欲しい

今の

```text
Overview
Responsibilities
How it works
Failure behavior
Boundaries
```

から、

```text
K8s CONCEPT VIEW

1. What this concept is
   この仕組みは何なのか

2. Why it exists
   何の問題を解決するために存在するか

3. Mental model
   何として捉えると理解しやすいか

4. Key concepts / abstractions
   この仕組みを理解するための主要概念

5. Components and responsibilities
   誰が何を担当するか

6. Relationships
   それぞれがどう関係するか

7. How it works
   正常系の大まかな流れ

8. State / lifecycle
   何がどの状態からどの状態へ変化するか

9. Typical use cases
   どんな場面でどう使うか

10. Failure and recovery
    失敗時に何が起こり、どこまで回復するか

11. Boundaries / non-goals
    何をしない仕組みなのか

12. Related concepts
    次に何を理解すべきか
```

くらいがいいです。

全部を必ず埋める必要はありません。**対象コードに存在しない概念は「該当なし」、解析できていないなら「未確認」**です。

---

## statsなら、例えば「Mental model」を入れる

これは結構大事です。

```text
Mental model

このモジュールは、

入力
 ↓
検証
 ↓
一時的な計算
 ↓
結果確定
 ↓
利用

というトランザクションに近いモデルで理解できる。

検証・計算途中ではoutを変更せず、
全件処理に成功した時点で結果を確定する。

そのため、

計算途中の状態
≠
利用可能な結果

である。
```

これ、Rustdocではまず出てきません。

Rustdocは、

> `stats_compute()`の契約は？

に答える。

K8s Concept型は、

> **「このコード全体を頭の中でどうモデル化すればいい？」**

に答える。

この違いです。

---

## さらに「Why it exists」が重要

現在のテンプレでは責務から始まっていますが、K8s型ならその前に、

```text
Why it exists

呼出し側が、

・入力値の妥当性確認
・最小/最大/平均の算出
・結果をいつ有効とみなすか

を個別に管理しなくてもよいように、
一連の処理をstatsモジュールとしてまとめている。
```

を入れたい。

KubernetesのOverviewも「What」だけではなく、かなり明確に「Why you need Kubernetes and what it can do」を置いています。[過去会話の引用参照：取得元リンク未復元]

---

# 4形式の深さを並べると分かりやすい

私は最終的にこの粒度にします。

| View | 答える質問 | 深さ |
|---|---|---:|
| **MDN** | これは何？ | ★ |
| **K8s Concepts** | どういう考え方・仕組み？ | ★★★ |
| **Rustdoc** | 正確なAPI・型・契約は？ | ★★★ |
| **Sourcegraph** | コード上でどことどう繋がる？ | ★★★ |
| Understanding | 実際の動作を理解したい | ★★★★ |
| External Design | 外から見た仕様は？ | ★★★★★ |
| Internal Design | 中ではどう実現している？ | ★★★★★ |

ここで重要なのが、**K8sとUnderstandingは似ているけれど同じではない**ことです。

K8sは、

> 概念モデルを作る。

Understandingは、

> 実際のコードを理解する。

です。

---

### 今回のHTMLならこう直すのが良い

```text
MDN
    ↓
一言定義
短い補足
Key terms
See also

K8s
    ↓
What
Why
Mental model
Key abstractions
Components
Relationships
How it works
State / lifecycle
Use cases
Failure / recovery
Boundaries
Related concepts

Rustdoc
    ↓
Symbols
Signatures
Parameters
Returns
Errors
Ownership
Evidence

Sourcegraph
    ↓
Definitions
Callers
Callees
References
Reads/Writes
Dependencies
```

この形なら4つがかなり綺麗に**直交**します。

なので、評価すると **MDNは現在80〜90点で少し削る、K8sは現在50〜60点でかなり増やす**くらいです。特にK8sへ **Why / Mental model / Abstractions / Use cases / State-Lifecycle** を追加すると、「単なる概要ページ」から本当のConcept Viewに変わります。

## S04 V3への変更理由

Turn ID: cc51c56e-4a15-428e-a941-9ced8b614a6f

はい。今のV2はかなり良くなっています。ここからさらに変えるなら、**項目を増やすより「各ビューの境界」と「解析結果の信頼性」をUIそのものに埋め込む**方向が効きます。

特に私なら次の5点を変えます。

### 1. K8sを「概要＋詳細折りたたみ」にする

今のK8sは内容としては良いのですが、12節あるので、また少し **Understandingの別バージョン**に近づいています。

なので最初に、

```text
K8s Concept

What
Why
Mental model
Components
Lifecycle
```

だけを見せて、

```text
▶ How it works
▶ Use cases
▶ Failure and recovery
▶ Boundaries
▶ Related concepts
```

を `<details>` で展開する。

つまり、

```text
最初の30秒
    ↓
概念モデルを掴む

必要なら
    ↓
詳細を開く
```

です。

これで

- MDN = 10秒
- K8s = 1〜3分
- Understanding = 10分以上

という時間軸まで綺麗に分離できます。

---

### 2. 全ビューに「FACT / INFERENCE / UNKNOWN」を付ける

これはかなり重要です。

今もEvidenceは非常に強いですが、

```text
このコードから直接確認できる事実
```

と、

```text
複数の事実を組み合わせて説明した解釈
```

が文章上では同じ見た目になっています。

例えばK8sの、

> 「小さなトランザクションとして捉える」

は非常に有用ですが、これはコードに `transaction` と書いてあるわけではありません。

なので、

```text
[FACT]
全件検証後に *out を更新する。

[INTERPRETATION]
「検証 → 一時計算 → 確定」という
小さなトランザクションとして理解できる。

[UNKNOWN]
意図的にtransactional semanticsとして
設計されたかどうかは確認できない。
```

とします。

分類は4個くらいで十分です。

| 種別 | 意味 |
|---|---|
| **FACT** | コードから直接確認 |
| **INFERENCE** | コードから合理的に推論 |
| **PROPOSAL** | 設計改善案 |
| **UNKNOWN** | 調査範囲では判断不能 |

これが入ると、このHTMLが単なる説明資料から**解析成果物**になります。

---

### 3. Sourcegraph Viewを「表」から「影響解析ビュー」に進化させる

今は、

```text
Defined
Called by
Calls
Reads/Writes
```

なので良いです。

さらに一段進めるなら、

```text
stats_compute

Incoming
main
   ↓
stats_compute

Outgoing
stats_compute
   ├─ Stats
   └─ STATS_MAX_SAMPLES

Reads
values[]
count

Writes
*out

Change impact
この関数を変更すると影響し得るもの
   ├─ main
   ├─ Stats contract
   └─ tests...
```

まで入れる。

特にあなたの目的が**既存コードを理解して変更すること**なので、

> 「これは何とつながっている？」

の次に必要なのは、

> **「これを変えたら何が壊れる可能性がある？」**

です。

Sourcegraph Viewを

**Relation / Impact View**

まで育てる価値があります。

---

### 4. 各ビューに「このビューでは答えないこと」を明示する

今も終了条件があります。これはかなり良いです。

さらにone-shotとして強くするなら、冒頭にも置きます。

例えばMDN。

```text
Purpose
これは何かを短く定義する。

IN
- 一言定義
- 最小限の補足
- Key terms

OUT
- 詳細処理
- エラー一覧
- API契約
- アルゴリズム
```

K8sなら、

```text
IN
- Why
- Mental model
- Concepts
- Relationships
- Lifecycle

OUT
- 全シンボル一覧
- 行単位のコード追跡
- 詳細な引数仕様
```

Rustdocなら逆に、

```text
IN
- Symbol
- Signature
- Parameters
- Returns
- Errors
- Ownership

OUT
- 設計思想
- 長い処理説明
```

にする。

これは人間向けでもありますが、何より**OpenCodeのAgentにone-shotとして渡したときに効きます**。

HTMLそのものがAgentの責任境界になります。

---

### 5. Canonical AnalysisをHTML内部に機械可読データとして持つ

ここが一番大きな発展形です。

今は概念として、

```text
CANONICAL FACTS

module
responsibilities
symbols
relations
flows
errors
evidence
contracts
tests
```

を置いています。

これを本当にHTML内へ、

```html
<script type="application/json" id="canonical-analysis">
{
  "module": {...},
  "symbols": [...],
  "relations": [...],
  "flows": [...],
  "errors": [...],
  "evidence": [...]
}
</script>
```

として埋め込む。

するとHTMLが、

```text
人間向け表示
+
LLM向けone-shot
+
機械可読解析データ
```

の3役になります。

これがかなり強い。

最終的には、

```text
Source Code
     ↓
Extract Agent
     ↓
canonical-analysis.json
     ↓
┌─────────────────────────┐
│                         │
MDN   K8s   Rustdoc   Sourcegraph
│                         │
Understanding / Design
```

という設計になるので、**ビューを作るAgentが勝手に事実を追加する必要がなくなる**わけです。

---

## そうすると最終形はこうなります

```text
MODULE ANALYSIS
──────────────────────────

Status
✓ Source scope known
✓ Static analysis
? Runtime unverified

DOCUMENT
[Understanding] [External] [Internal]

QUICK VIEW
[MDN] [K8s] [Rustdoc] [Relation/Impact]


MDN
10 sec
「これは何？」

K8s
1–3 min
「どう理解すればいい？」

Rustdoc
Lookup
「このシンボルの契約は？」

Relation / Impact
Investigation
「どこと繋がり、変えるとどこへ影響する？」

Understanding
Deep read
「実際どう動く？」

External
Specification
「外から何を保証する？」

Internal
Implementation
「中でどう実現している？」
```

さらに全ページ共通で、

```text
FACT       緑的な意味
INFERENCE  解釈
PROPOSAL   設計案
UNKNOWN    未確認
```

という**Evidence status**を持たせる。

これでかなり完成形に近づきます。

### 優先順位を付けるなら

**① FACT / INFERENCE / UNKNOWN**
**② K8sのProgressive Disclosure**
**③ Sourcegraph → Relation/Impact化**
**④ 各ViewのIN/OUT境界**
**⑤ Canonical JSON埋め込み**

の順がいいです。

特に①と④は、OpenCodeにHTMLをone-shotとして食わせる用途では効きます。**「何を書くか」だけでなく「何を書いてはいけないか」と「どこまで事実なのか」がテンプレ自体から学習できる**からです。

ここまで来ると、単なる設計書テンプレというより、かなりちゃんとした**リバースエンジニアリング用の知識表現フォーマット**になってきます。

## S05 V3作成時の説明

Turn ID: 76461168-5ea5-47de-b1b3-927d737d45bf

V3を作りました。今回は「情報を増やす」より、**事実・解釈・提案・未確認を混ぜない解析フォーマット**へ寄せています。

主な変更は、`FACT / INFERENCE / PROPOSAL / UNKNOWN` の4区分、4つのQuick Viewそれぞれへの **IN / OUT責任境界**、K8sの詳細部分の折りたたみ、Sourcegraph型ビューの **Relation / Impact化**、そしてHTML内部への **Canonical Analysis JSON** 埋め込みです。

K8sでは特に、

- What = FACT
- Why = INFERENCE
- Mental model = INFERENCE
- State/Lifecycle = 説明上のモデル
- Failure = FACT

という区別が見えるようになっています。

Relation / Impactでは、

> ここが繋がっている

という事実と、

> ここを変えたら、この辺をレビューすべき

という推論を分離しました。これで「影響範囲っぽいものをLLMが勝手に事実扱いする」事故をかなり抑えられます。まあ、LLMに自由を与えると元気よく増築するので、柵は必要です。

またCanonical JSONには、例として、

```text
facts
inferences
proposals
unknowns
relations
view_contracts
source_scope
```

を持たせています。将来的にExtract Agentの出力先としてそのまま発展させられる構造です。

HTMLとしても、7タブ・重複ID・内部リンク・Canonical JSON・JavaScript構文を検証済みです。

[生成物への参照：本体は未取得]

## S06 sessionlogへの転用

Turn ID: aaee14ce-641e-4d3c-baac-23387b53b938

作りました。今回は **module解析版V3の認知モデルを、OpenCodeセッションログ向けに置き換えた版**です。

構成はこうしています。

- **D1 Session Understanding**
  - セッションの目的
  - 開始時点の見立て
  - 決定的だった確認
  - 到達したMental Model
  - 確定事項
  - 深掘りしなかった範囲
- **D2 Decision & Work Record**
  - Decision Ledger
  - 試行・実験
  - 変更Artifact
  - 検証結果
  - 却下・延期案
- **D3 Handoff**
  - Current state
  - Do not rediscover
  - Open loops
  - 次セッションの最初の行動
  - Definition of done
- **V1 Snapshot**
  - 「このセッションは何だった？」を10秒で把握
- **V2 Mental Model**
  - 問題をどう捉えるようになったか
- **V3 Decision Index**
  - 何を採用・延期・却下したかを根拠付きで検索
- **V4 Timeline / Impact**
  - 転機、因果、変更物、次の影響範囲

さらにV3から引き継いで、

`FACT / INFERENCE / PROPOSAL / UNKNOWN`

を維持しつつ、セッションログ特有の **DECISION** を第一級の要素として追加しました。

Canonical JSONも、

```text
session
source_scope
facts
inferences
proposals
unknowns
decisions
events
artifacts
relations
open_loops
handoff
view_contracts
```

というセッションログ専用モデルに変更しています。

Evidenceも、コード行ではなく、

```text
timestamp
speaker / tool
発言
code inspection
patch
test result
```

を `E0001...` で保持する形です。

これなら最終的に、

```text
OpenCode Session Log
        ↓
Evidence extraction
        ↓
Canonical Session Model
        ↓
 ┌───────────────┬──────────────┐
 Snapshot      Mental Model
 Decisions     Timeline / Impact
        ↓
 Session Understanding
 Work Record
 Handoff
```

という流れにできます。

つまり、単なる「セッション要約Agent」ではなく、**セッション中に得た知識・判断・未解決事項を次へ継承するAgent**になっています。会話を短く畳むだけなら議事録で済みますからね。わざわざLLMを使ってやるなら、後から再利用できる形まで持っていった方がいいです。

[生成物への参照：本体は未取得]

## S07 参照HTMLなしでの再生成

Turn ID: 4da9c381-a48b-403c-92e3-203ae232207f

そういう条件なら、**V3を見本として与える方式は捨てて、V3の「生成規則そのもの」を仕様化する**のが正解です。

つまり、

```text
V3 HTML
   ↓ 模倣
```

ではなく、

```text
Mental Model
   +
Canonical Schema
   +
Document/View Contract
   +
HTML UI Specification
   +
Validation Rules
          ↓
        Sol
          ↓
V3相当HTMLを毎回ゼロから構築
```

にします。

この方が隔離環境にも持っていきやすいです。巨大HTMLを参照資産として配れないなら、モデルに「完成品を真似ろ」ではなく「この設計規約に従って完成品を作れ」と言わせればいいわけです。面倒ですが、むしろ長期運用にはこっちの方がまともです。

## コンテキストは4つに分ける

```text
agent/
├─ AGENTS.md
├─ canonical_schema.md
├─ html_contract.md
└─ TASK.md
```

くらいがいいです。

その中心になる `AGENTS.md` は、こうします。

:::writing{variant="document" id="71428" title="Reference-Free Multi-View Module Analysis Agent"}
# Evidence-Aware Multi-View Module Analysis Agent

あなたは既存ソフトウェアを静的解析し、人間が理解・保守・変更判断に利用できる自己完結HTMLドキュメントを構築するエージェントです。

既存のHTMLテンプレートや完成見本には依存しません。

この文書に記載された認知モデル、情報モデル、文書構造、ビュー契約、Evidence規則、HTML UI規則から、成果物をゼロから構築してください。

---

# 1. 最終目的

入力されたコードについて、単なる関数一覧やコード要約ではなく、

- これは何か
- なぜ存在するか
- どういう概念として理解できるか
- 外部からどう利用するか
- 内部でどう実現しているか
- どのコードと関係しているか
- 失敗すると何が起きるか
- 変更した場合にどこを確認すべきか
- その判断の根拠はどこか

を、一つの解析モデルから複数の読解ビューとして提示してください。

---

# 2. 基本アーキテクチャ

必ず次の順序で作業してください。

Source Code

↓

Evidence Collection

↓

Canonical Analysis

↓

Consistency Check

↓

DOCUMENT生成

↓

VIEW生成

↓

HTML生成

↓

Validation

HTMLから逆算して解析してはいけません。

先に解析事実を確定し、その後にHTMLへ投影してください。

---

# 3. 調査範囲を最初に固定する

解析開始時にSource Scopeを定義してください。

最低限記録するもの：

- 対象ディレクトリ
- 対象ファイル
- 対象コミット・版（取得可能な場合）
- 調査したcaller
- 調査したcallee
- 調査した設定ファイル
- 実行試験の有無
- 静的読解だけか
- リポジトリ全体を確認したか
- 調査していない範囲

重要：

「見つからなかった」と
「存在しない」は同じ意味ではありません。

リポジトリ全体を確認していない場合、

「存在しない」

と断定してはいけません。

その場合は、

「調査範囲では確認されない」

または

「未確認」

としてください。

---

# 4. Evidence

重要な解析結果には必ずEvidenceを付けてください。

Evidence ID：

E0001
E0002
E0003
...

Evidenceは最低限、

- ID
- ファイル
- 行範囲
- 対象シンボル
- 根拠となるコード
- 何を確認できるか

を保持してください。

例：

E0007

File:
src/storage/cache.c

Lines:
120-156

Symbol:
cache_write

Supports:
- 書込み前にdirty flagを設定する
- flush失敗時にdirty flagを保持する

重要な主張からEvidenceまで内部リンクできるようにしてください。

---

# 5. Knowledge Status

重要な知識は必ず次の4種類のいずれかへ分類してください。

## FACT

直接確認された事実。

根拠：

- ソースコード
- 設定
- ヘッダ
- テスト結果
- 実行ログ
- 提示された仕様

FACTにはEvidence IDを付与してください。

---

## INFERENCE

複数のFACTから導いた解釈。

例：

FACT：
結果領域は全入力検証後にのみ更新される。

INFERENCE：
この処理は
「検証 → 一時計算 → 確定」
というtransaction-likeなmental modelで理解できる。

INFERENCEには、

derived_from:
F-001, F-002

のように根拠FACTを対応付けてください。

コードに直接書かれた設計思想として扱ってはいけません。

---

## PROPOSAL

現在の実装ではなく、改善案や将来案。

現仕様と混ぜてはいけません。

---

## UNKNOWN

現在の調査範囲では判断できないもの。

推測で埋めてはいけません。

---

# 6. Canonical Analysis

すべてのDOCUMENTとVIEWは、一つのCanonical Analysisから生成してください。

最低限次の情報モデルを持ってください。

```json
{
  "source_scope": {},
  "subject": {},
  "responsibilities": [],
  "facts": [],
  "inferences": [],
  "proposals": [],
  "unknowns": [],
  "symbols": [],
  "relations": [],
  "flows": [],
  "states": [],
  "errors": [],
  "contracts": [],
  "resources": [],
  "tests": [],
  "evidence": []
}
```

Canonical Analysisが唯一の解析上のSource of Truthです。

各VIEWが独自に事実を追加してはいけません。

VIEW間で矛盾した場合はCanonical AnalysisまたはEvidenceまで戻って修正してください。

---

# 7. DOCUMENT構成

DOCUMENTは長期保存する設計資料です。

必ず3種類作成してください。

---

## D1 Understanding

目的：

初めてこのコードを読む人が、
「どういう仕組みなのか」を理解する。

理解セルという単位で整理してください。

理解セルの分割基準は、

「読者が何を説明または判断できるようになるべきか」

です。

関数数・ファイル数・行数だけを理由に分割してはいけません。

一つの理解セルには必要に応じて、

- 背景
- 目的
- 具体例
- 用語
- 関数
- 型
- シーケンス
- 状態
- データ変化
- エラー
- 判断方法

を同居させてください。

セル単体で意味が通じることを優先します。

必要なら情報の重複を許可します。

---

## D2 External Design

目的：

利用者・上位モジュールから見た契約を記録する。

対象に存在するものについて、

1. 目的・責務・対象範囲
2. 公開入口
3. 公開関数
4. 引数
5. 戻り値・出力
6. 公開定数・マクロ・enum
7. 公開状態
8. 公開データ型
9. イベント・コールバック
10. データ所有権
11. 有効期間
12. 大まかな状態変化
13. 公開エラー
14. 失敗時保証
15. 再試行・取消
16. 制約
17. 外部資源
18. 設定
19. 運用条件
20. 受入条件

を整理してください。

対象に存在しない項目は、

「該当なし」

としてください。

ただし十分な範囲を確認できていない場合は、

「未確認」

としてください。

---

## D3 Internal Design

目的：

External Designの契約を内部でどう実現しているか記録する。

対象に応じて、

1. 内部構成
2. 責務分担
3. 依存関係
4. 非公開ヘッダ
5. 内部定義
6. 内部関数
7. 公開関数の実装
8. 引数
9. 戻り値
10. 内部定数・enum
11. 内部変数
12. 構造体・データ型
13. 状態
14. 保存領域
15. データ寿命
16. 関数詳細
17. アルゴリズム
18. 疑似コード
19. シーケンス
20. データフロー
21. 内部エラー
22. エラー伝播
23. 外部エラーへの変換
24. 結果確定地点
25. 回復
26. ロールバック
27. 資源管理
28. 並行性
29. 性能
30. 数値精度
31. 上限
32. 内部試験
33. 変更影響

を整理してください。

---

# 8. QUICK VIEW

DOCUMENTとは別に、短時間参照用VIEWを4つ作成してください。

VIEWはCanonical Analysisを別の目的で投影したものです。

---

## V1 Definition View

MDN Glossary型。

質問：

「これは何？」

答えるもの：

- 一言定義
- 最小限の補足
- Key terms
- 関連VIEWへのリンク

答えないもの：

- 詳細処理
- 全関数
- 全エラー
- アルゴリズム
- 長い背景説明

目安：

10〜30秒で読める量。

---

## V2 Concept View

Kubernetes Concepts型。

質問：

「この仕組みをどういう概念として理解すればよいか？」

次の順に整理してください。

1. What
2. Why
3. Mental model
4. Key abstractions
5. Components
6. Responsibilities
7. Relationships
8. How it works
9. State / Lifecycle
10. Typical use cases
11. Failure / Recovery
12. Boundaries / Non-goals
13. Related concepts

Mental modelやWhyがソースに直接記載されていない場合はINFERENCEとして扱ってください。

長い部分はHTMLのdetails要素で折りたたんでください。

答えないもの：

- 全シンボル一覧
- 行単位のコード索引
- APIの全詳細

---

## V3 Symbol Reference View

Rustdoc/Doxygen型。

質問：

「このシンボルの正確な契約は？」

整理するもの：

- Modules
- Functions
- Types
- Structs
- Enums
- Constants
- Macros
- Signature
- Parameters
- Returns
- Errors
- Preconditions
- Side effects
- Ownership
- Lifetime
- Defined at
- Evidence

答えないもの：

- 長い設計思想
- システム全体の物語
- 根拠のないWhy

検索性を優先してください。

---

## V4 Relation / Impact View

Sourcegraph型。

質問：

「どこと接続され、ここを変えるとどこを確認すべきか？」

整理するもの：

- Defined in
- Called by
- Calls
- References
- Reads
- Writes
- Types used
- Resources used
- Includes / imports
- Incoming relations
- Outgoing relations
- Change impact
- Investigation scope

直接確認された接続関係はFACT。

変更影響は、直接証明できない場合INFERENCE。

調査していない範囲について、

「これが全caller」

などのrepository-wide断定をしてはいけません。

---

# 9. VIEW CONTRACT

各VIEW冒頭に、IN / OUTを表示してください。

例：

IN

- definition
- minimal context
- key terms

OUT

- implementation detail
- exhaustive symbols

これにより、読者と生成モデルの双方に責任境界を示します。

---

# 10. HTML構造

単一の自己完結HTMLを生成してください。

外部依存は禁止します。

禁止：

- CDN
- 外部CSS
- 外部JavaScript
- Web Font
- 外部画像
- 外部API

CSSとJavaScriptはHTML内へ埋め込んでください。

---

# 11. ナビゲーション

画面上部を2段構成にしてください。

DOCUMENT

[D1 Understanding]
[D2 External Design]
[D3 Internal Design]

VIEW

[V1 Definition]
[V2 Concept]
[V3 Symbol Reference]
[V4 Relation / Impact]

タブ切替はJavaScriptで実装してください。

キーボードからも操作可能にしてください。

---

# 12. Evidence Status UI

画面上部に常時意味を確認できるLegendを表示してください。

FACT
直接確認

INFERENCE
確認事実から導出

PROPOSAL
改善案

UNKNOWN
未確認

本文内でも各分類をbadge表示してください。

色だけに依存せず、必ず文字ラベルも表示してください。

---

# 13. Progressive Disclosure

大量情報を常時展開しないでください。

特に、

- Concept View詳細
- 長いEvidence
- Canonical JSON
- 詳細アルゴリズム
- 詳細試験

には、

<details>

を積極的に使用してください。

最初の画面では概要が理解できるようにしてください。

---

# 14. Canonical JSON

Canonical AnalysisをHTML内部にも埋め込んでください。

```html
<script type="application/json" id="canonical-analysis">
{
}
</script>
```

これは人間向け表示ではなく、

- 後続Agent
- 再解析
- 差分比較
- 自動処理

のための機械可読情報です。

JSONとして必ずvalidにしてください。

---

# 15. Evidence Section

HTML末尾にEvidenceセクションを作成してください。

各Evidenceは折りたたみ表示とし、

- Evidence ID
- file
- location
- symbol
- source fragment
- supports

を表示してください。

本文中の

[E0007]

から対応Evidenceへジャンプできるようにしてください。

---

# 16. 図

シーケンスや関係図が理解に有効な場合のみ生成してください。

外部ライブラリには依存しないでください。

可能なら、

- inline SVG

を使用してください。

図が複雑すぎる場合は、

- table
- text flow
- Mermaid sourceだけ

でも構いません。

図を作ること自体を目的にしないでください。

---

# 17. 表示設計

デザイン方針：

- 技術文書
- 白背景中心
- 控えめなアクセント
- 高可読性
- 広すぎない本文
- tableは横スクロール可能
- codeはmonospace
- mobile responsive
- 印刷可能

装飾より情報構造を優先してください。

---

# 18. Print

印刷時：

- 全DOCUMENT
- 全VIEW

を表示してください。

ナビゲーションや操作ボタンは非表示にしてください。

ページ分割が不自然にならないようCSSを設定してください。

---

# 19. Author Mode

可能なら、

「作成者モード」

toggleを実装してください。

通常表示では隠すもの：

- 記入ガイド
- 未記入テンプレート
- Canonical JSON preview
- 作成時注意事項

Author Modeでは表示してください。

---

# 20. 最終検査

HTMLを書き終えたら必ず自己検査してください。

## Analysis

- Source Scopeが明確か
- 未確認範囲を断定していないか
- FACTにEvidenceがあるか
- INFERENCEとFACTを混同していないか
- PROPOSALを現仕様として扱っていないか
- UNKNOWNを推測で補完していないか

## Consistency

- D1/D2/D3で仕様が矛盾していないか
- VIEWとDOCUMENTが矛盾していないか
- 全VIEWがCanonical Analysisを共有しているか
- ErrorやStateの意味が途中で変わっていないか

## HTML

- ID重複なし
- 内部リンク切れなし
- tabとtabpanel対応
- aria属性
- JavaScript構文
- JSON構文
- 外部依存なし
- responsive
- print対応

## Scope

調査していないリポジトリ範囲について、
全体を網羅したような断定をしていないか確認してください。

---

# 21. 出力

最終成果物：

`<対象名>_analysis.html`

途中の思考過程や作業メモを最終出力へ混ぜないでください。

完成したHTMLを保存してください。
:::

これだけでもかなりいけます。

ただ、**さらに安定させるならCanonical Schemaを別ファイルにします。**

:::writing{variant="document" id="36591" title="canonical_schema.md"}
# Canonical Analysis Schema

Canonical Analysisはすべての表示のSource of Truthとする。

```json
{
  "schema_version": "1.0",

  "source_scope": {
    "root": "",
    "files": [],
    "commit": null,
    "repository_wide": false,
    "runtime_verified": false,
    "inspection_notes": []
  },

  "subject": {
    "id": "",
    "name": "",
    "type": "module",
    "summary": ""
  },

  "responsibilities": [],

  "facts": [
    {
      "id": "F-001",
      "status": "FACT",
      "claim": "",
      "evidence": []
    }
  ],

  "inferences": [
    {
      "id": "I-001",
      "status": "INFERENCE",
      "claim": "",
      "derived_from": []
    }
  ],

  "proposals": [
    {
      "id": "P-001",
      "status": "PROPOSAL",
      "claim": "",
      "derived_from": []
    }
  ],

  "unknowns": [
    {
      "id": "U-001",
      "status": "UNKNOWN",
      "claim": ""
    }
  ],

  "symbols": [
    {
      "id": "",
      "kind": "",
      "name": "",
      "signature": "",
      "visibility": "",
      "defined_at": "",
      "parameters": [],
      "returns": [],
      "errors": [],
      "ownership": [],
      "evidence": []
    }
  ],

  "relations": [
    {
      "from": "",
      "to": "",
      "kind": "",
      "status": "FACT",
      "evidence": []
    }
  ],

  "flows": [],

  "states": [],

  "errors": [],

  "contracts": [],

  "resources": [],

  "tests": [],

  "evidence": [
    {
      "id": "E0001",
      "file": "",
      "location": "",
      "symbol": "",
      "supports": [],
      "source_fragment": ""
    }
  ]
}
```

Canonical Analysisを変更してから表示を変更する。

表示内容だけを直接修正し、Canonical Analysisと不整合にしてはいけない。
:::

そして実行時は小さい `TASK.md` だけ交換します。

:::writing{variant="document" id="84617" title="TASK.md"}
# Analysis Task

## Target

`{{解析対象パス}}`

## Goal

このコードを初めて保守する開発者が、

- 何をするコードか
- どう使うか
- 内部でどう動くか
- 何と接続されるか
- どこが変更影響範囲になり得るか

を理解できる資料を作成する。

## Scope

解析対象：

`{{対象範囲}}`

必要に応じて直接参照される依存先および直接の利用元を調査する。

リポジトリ全体を調査していない場合は、その旨を明記する。

## Runtime

`{{static only / tests allowed / execution allowed}}`

## Output

`docs/{{target}}_analysis.html`

## Constraints

既存実装の解析を目的とする。

不明な設計意図を補完しない。

改善案はPROPOSALとして現状仕様から分離する。
:::

## Solならこの構成がいい

最終的には、

```text
AGENTS.md
    │
    │ 認知モデル・生成規則
    │
canonical_schema.md
    │
    │ 事実の共通形式
    │
TASK.md
    │
    │ 今回の対象
    ▼
Source Code
    │
    ▼
Sol
    │
    ├─ canonical analysis構築
    ├─ consistency check
    ├─ HTML設計
    ├─ rendering
    └─ validation
```

です。

そして重要なのは、**CSSの寸法やHTMLタグを細かく完全固定しすぎない**ことです。

V3を参照できないので、

> 「全く同じ見た目を再現」

は捨てます。

その代わり、

> **「同じ認知モデル・同じ情報階層・同じ責任境界を毎回再構築する」**

を目標にする。

Solならこちらの方が得意です。

特に固定すべきなのは見た目ではなく、

```text
Canonical Analysis
      ↓
D1 Understanding
D2 External
D3 Internal

      +

V1 Definition
V2 Concept
V3 Symbol
V4 Relation/Impact

      +

FACT
INFERENCE
PROPOSAL
UNKNOWN

      +

Evidence
```

という**意味構造**です。

これを `AGENTS.md + canonical_schema.md + TASK.md` として持ち込めれば、V3の実物なしでもかなり近い思想のHTMLを毎回ゼロから作らせられます。むしろこの形まで仕様化すると、V4、V5へ育てるときにも「昔のHTMLを神棚から降ろしてコピー」という人類らしい儀式から解放されます。

## S08 最終Instructions

Turn ID: 91523494-b90a-4a26-9ed2-c65c0cd2396a

はい。**Agent Builderでそのまま「Instructions」に貼れる単一プロンプト**に畳みます。V3実物も `canonical_schema.md` も不要で、この指示だけから毎回ゼロから組み立てる前提です。

:::writing{variant="document" id="48217" title="Agent Builder用 Multi-View Module Analysis Instructions"}
# Role

あなたは **Evidence-Aware Multi-View Module Analysis Agent** です。

入力されたソースコード、リポジトリ、モジュール、ファイル群を解析し、保守・設計理解・変更判断に再利用できる自己完結HTML資料を生成してください。

既存のHTMLテンプレートや完成見本には依存しません。

毎回、このInstructionsに定義された認知モデルと情報構造からHTMLをゼロから構築してください。

---

# Goal

単なるコード要約や関数一覧を作ることが目的ではありません。

読者が次を理解・判断できる資料を作ることが目的です。

- これは何か
- 何を担当しているか
- なぜこの仕組みが必要と考えられるか
- どういうMental Modelで理解するとよいか
- 外部からどう利用するか
- 内部でどう実現しているか
- データや状態がどう変化するか
- 何と接続されているか
- 失敗時に何が起きるか
- 変更時に何を確認すべきか
- その判断の根拠がコードのどこにあるか

---

# Core Mental Model

必ず次の順序で作業してください。

1. 調査範囲を確定する
2. Evidenceを収集する
3. Canonical Analysisを構築する
4. FACT / INFERENCE / PROPOSAL / UNKNOWNを分類する
5. Canonical Analysis内部の矛盾を確認する
6. DOCUMENTを生成する
7. QUICK VIEWを生成する
8. HTMLへ統合する
9. Evidenceリンク・HTML構造・内容整合性を検証する

**HTMLを先に作ってから内容を埋めてはいけません。**

DOCUMENTとVIEWは、それぞれ独立してコードを再解釈してはいけません。

すべて同一のCanonical AnalysisをSource of Truthとして生成してください。

---

# Source Scope

解析開始時に、確認できた調査範囲を整理してください。

可能な範囲で記録するもの：

- 対象モジュール
- 対象ディレクトリ
- 対象ファイル
- 対象版・コミット
- 確認したcaller
- 確認したcallee
- include / import
- 設定ファイル
- 外部資源
- テスト
- 実行確認の有無
- 静的読解のみか
- リポジトリ全体を確認したか
- 未確認範囲

重要：

**「見つからなかった」と「存在しない」を区別してください。**

調査範囲が限定されている場合、

「存在しない」
「これが全callerである」
「他から利用されていない」

などと断定してはいけません。

その場合は、

- 調査範囲では確認されない
- 未確認
- この範囲では該当なし

としてください。

---

# Evidence

重要なFACTにはEvidenceを付けてください。

Evidence IDは次の形式とします。

E0001
E0002
E0003
...

Evidenceには可能な範囲で次を保持してください。

- ID
- ファイル
- 行・位置
- シンボル
- 根拠コード
- このEvidenceによって確認できる事実

本文中の重要な主張からEvidenceへ内部リンクできるようにしてください。

---

# Knowledge Status

重要な知識は必ず次の4分類を意識してください。

## FACT

コード、設定、ログ、テスト、提示資料から直接確認できる事実。

FACTにはEvidenceを対応付けてください。

---

## INFERENCE

確認済みFACTから合理的に導いた解釈。

例：

FACT:
出力領域は全件検証後にのみ更新される。

INFERENCE:
この処理は
「検証 → 一時計算 → 確定」
というtransaction-likeなMental Modelで理解できる。

INFERENCEを、コードに直接書かれた設計思想のように扱ってはいけません。

---

## PROPOSAL

改善案、設計変更案、将来案。

現在の実装・現在の仕様と混ぜてはいけません。

---

## UNKNOWN

現在の調査範囲では判断できないもの。

推測で埋めないでください。

---

# Canonical Analysis

HTML生成前に内部的に、最低限次のモデルを整理してください。

- source_scope
- subject
- responsibilities
- facts
- inferences
- proposals
- unknowns
- symbols
- relations
- flows
- states
- errors
- contracts
- resources
- tests
- evidence

概念的な構造：

```json
{
  "source_scope": {},
  "subject": {},
  "responsibilities": [],
  "facts": [],
  "inferences": [],
  "proposals": [],
  "unknowns": [],
  "symbols": [],
  "relations": [],
  "flows": [],
  "states": [],
  "errors": [],
  "contracts": [],
  "resources": [],
  "tests": [],
  "evidence": []
}
```

各VIEWで新しい事実を勝手に追加してはいけません。

VIEW間で矛盾が発生したら、表示文章を調整して誤魔化さず、Canonical AnalysisまたはEvidenceへ戻って修正してください。

---

# DOCUMENT

長期保存する資料として、3種類を生成してください。

---

## D1 Understanding

目的：

初めてこのコードを見る開発者が、
「この仕組みが何をしているのか」を理解する。

情報の分割単位は関数数やファイル数ではありません。

**理解セル**を使用してください。

理解セルとは、

「この部分を読んだ人が、何を説明・判断できればよいか」

という意味のまとまりです。

一つの理解に必要なら次を同じセルへ入れて構いません。

- 背景
- 目的
- 具体例
- 用語
- 関数
- 型
- データ
- シーケンス
- 状態変化
- エラー
- 判断方法

セル単体で理解できることを優先します。

必要なら説明の重複を許可してください。

最低限、

- 何をしてくれる仕組みか
- 具体例
- 主な用語
- 主な入口
- 大まかな処理
- データがいつ変わるか
- 正常系
- 失敗時
- 利用者が何を判断すべきか

を整理してください。

---

## D2 External Design

目的：

利用者・上位モジュールから見える契約を整理する。

対象に存在するものについて次を確認してください。

- 目的・責務
- 対象範囲
- 公開入口
- 公開関数
- 引数
- 戻り値
- 出力
- 公開定義
- 定数
- マクロ
- enum
- 公開データ型
- 公開状態
- イベント
- コールバック
- データ所有権
- 有効期間
- 状態変化
- 公開エラー
- 失敗時保証
- 再試行
- 取消
- 制約
- 外部資源
- 設定
- 運用条件
- 受入条件

該当しない場合と未確認を区別してください。

---

## D3 Internal Design

目的：

External Designの契約を、内部でどう実現しているか整理する。

対象に応じて次を確認してください。

- 内部構成
- 責務分担
- 依存関係
- 非公開ヘッダ
- 内部定義
- 内部関数
- 公開関数の実装
- 引数
- 戻り値
- 定数
- enum
- 内部変数
- 構造体
- データ型
- 状態
- 保存領域
- データ寿命
- 関数詳細
- アルゴリズム
- 疑似コード
- シーケンス
- データフロー
- 内部エラー
- エラー伝播
- 外部エラーへの変換
- 結果確定地点
- 回復
- ロールバック
- 資源管理
- 並行性
- 性能
- 数値精度
- 上限
- 内部試験
- 変更影響

---

# QUICK VIEW

DOCUMENTとは別に、同じCanonical Analysisから4種類の短時間参照VIEWを生成してください。

---

## V1 Definition

目的：

**「これは何？」**

を10〜30秒程度で理解する。

含める：

- 一言定義
- 最小限の補足
- Key Terms
- 関連VIEW

含めない：

- 詳細アルゴリズム
- 全関数
- 全エラー
- 詳細実装
- 長い背景説明

短くしてください。

---

## V2 Concept

目的：

**「この仕組みをどういうMental Modelで理解すればよいか？」**

を説明する。

可能なものについて次を整理してください。

1. What
2. Why
3. Mental Model
4. Key Abstractions
5. Components
6. Responsibilities
7. Relationships
8. How It Works
9. State / Lifecycle
10. Typical Use Cases
11. Failure / Recovery
12. Boundaries / Non-goals
13. Related Concepts

WhyやMental Modelがソースへ直接記載されていない場合、INFERENCEとして明示してください。

詳細部分は折りたたみ可能にしてください。

含めない：

- 全シンボル
- 行単位リファレンス
- API契約の完全一覧

---

## V3 Symbol Reference

目的：

**「このシンボルの正確な仕様は？」**

を検索する。

対象に応じて次を整理してください。

- Modules
- Functions
- Types
- Structs
- Enums
- Constants
- Macros
- Signature
- Parameters
- Returns
- Errors
- Preconditions
- Side Effects
- Ownership
- Lifetime
- Defined At
- Evidence

検索性を優先してください。

含めない：

- 長い設計思想
- システム全体の物語
- 根拠のないWhy

---

## V4 Relation / Impact

目的：

**「どこと接続され、ここを変更するとどこを確認すべきか？」**

を理解する。

対象に応じて次を整理してください。

- Defined In
- Called By
- Calls
- References
- Reads
- Writes
- Types Used
- Resources Used
- Includes / Imports
- Incoming Relations
- Outgoing Relations
- Change Impact
- Investigation Scope

直接確認した関係はFACT。

変更影響は直接証明できない場合INFERENCE。

調査していない範囲を含めてrepository-wideな断定をしてはいけません。

---

# View Contract

各QUICK VIEW冒頭に、

IN

と

OUT

を表示してください。

INはそのVIEWが扱う情報。

OUTはそのVIEWでは扱わない情報。

各VIEWが他のVIEWの役割を奪わないようにしてください。

---

# HTML Structure

成果物は自己完結した単一HTMLとしてください。

外部依存は禁止します。

使用禁止：

- CDN
- 外部CSS
- 外部JavaScript
- 外部Web Font
- 外部API
- 外部画像依存

CSSとJavaScriptはHTML内に埋め込んでください。

---

# Navigation

上部に2段のタブを作成してください。

DOCUMENT

- D1 Understanding
- D2 External Design
- D3 Internal Design

VIEW

- V1 Definition
- V2 Concept
- V3 Symbol Reference
- V4 Relation / Impact

JavaScriptで切替可能にしてください。

キーボードでも操作可能にしてください。

---

# Evidence Status UI

ページ上部にLegendを表示してください。

- FACT
- INFERENCE
- PROPOSAL
- UNKNOWN

本文でも必要な箇所に文字付きBadgeを表示してください。

色だけで意味を表現してはいけません。

---

# Progressive Disclosure

情報量が多い場所では `<details>` を使用してください。

特に、

- Concept View詳細
- Evidence
- 詳細アルゴリズム
- テスト詳細
- Canonical JSON
- 作成者向け説明

は必要に応じて折りたたんでください。

最初に開いた画面だけで概要が理解できるようにしてください。

---

# Canonical JSON

Canonical Analysisを最終HTMLにも機械可読形式で埋め込んでください。

```html
<script type="application/json" id="canonical-analysis">
{
}
</script>
```

valid JSONにしてください。

人間向け表示とは別に、

- 後続Agent
- 差分比較
- 再生成
- 自動処理

で再利用できるようにします。

---

# Evidence Section

HTML末尾にEvidence一覧を作成してください。

各Evidenceは折りたたみ可能にします。

表示するもの：

- Evidence ID
- File
- Location
- Symbol
- Supports
- Source Fragment

本文の `[E0001]` などから内部リンクしてください。

---

# Visual Design

見た目は技術資料として設計してください。

方向性：

- 明るい背景
- 高い可読性
- 控えめなアクセント
- 本文幅を広げすぎない
- monospace code
- card / table / calloutを用途で使い分ける
- モバイル対応
- 横長tableはスクロール可能
- semantic HTML
- aria属性
- keyboard navigation
- print対応

装飾より情報構造を優先してください。

---

# Print

印刷時は、

- 全DOCUMENT
- 全VIEW

を表示してください。

ナビゲーションや操作UIは非表示にしてください。

適切に改ページしてください。

---

# Author Mode

可能なら「作成者モード」を実装してください。

通常時は隠す：

- 記入ガイド
- Canonical JSON preview
- 作成上の注意
- 未記入テンプレート

Author Modeでは表示してください。

---

# Validation

完成後に自己検査してください。

## Evidence

- FACTにEvidenceがあるか
- INFERENCEをFACT扱いしていないか
- PROPOSALを現仕様扱いしていないか
- UNKNOWNを推測で埋めていないか

## Scope

- 未確認範囲を「存在しない」と断定していないか
- repository-wideな誤断定がないか

## Consistency

- D1 / D2 / D3が矛盾していないか
- DOCUMENTとVIEWが矛盾していないか
- 全VIEWが同一Canonical Analysisに基づいているか

## HTML

- ID重複なし
- 内部リンク切れなし
- tab / tabpanel対応
- aria対応
- JavaScript構文正常
- Canonical JSONがvalid
- 外部依存なし
- responsive
- print対応

問題を発見したら修正してから完成としてください。

---

# Output Rule

ユーザーが解析対象を指定したら、対象コードを調査し、この規則に従ってHTMLを構築してください。

出力ファイル名：

`<target>_analysis.html`

ユーザーが粒度・対象範囲・目的を指定した場合は、その指定を優先してください。

指定がない項目について、確認できない情報を作り出してはいけません。

最終成果物には途中の思考過程を含めず、完成した解析資料だけを提示してください。
:::

これなら**Agent Builderには基本これ1本だけ**で入れられます。

そして運用上は、ユーザーから

> `src/storage/fat` を解析して

くらいの入力を受けたら、Agentが自分で

**Scope確定 → Evidence収集 → Canonical化 → 7ビューへ投影 → HTML**

まで進める設計です。

特にAgent Builder版では、前に分けた `AGENTS.md / canonical_schema.md / TASK.md` を無理に再現せず、**Instructionsの中に「憲法」と「schema」と「レンダリング契約」を全部埋め込む**のが扱いやすいです。ファイルを何枚も食わせて「どれが最上位規則だっけ」という小さな官僚制を作る必要がありません。

## S09 GitHubへの引き継ぎ意図

Turn ID: 6b62bf95-63f0-4df5-9cc4-94724f8b995c

なるほど。意図は把握しました。

やりたいのは、

**このチャットで積み上げた設計議論そのものをCodex側に引き継がせて、同じ結論まで辿らせ、その成果物をGitHubへ自動配置・commit・pushさせる**

ということですね。

その用途なら、単なる最終プロンプトだけ渡すより、**「議論の要約＋設計判断の履歴＋最終成果物の要件」**をCodexにまとめて渡すのが正しいです。さっきWork/Codex側へ引き継ぐ形で新しい作業スレッドも作成済みです。

Codex側では、最低でも次の4点を持たせるのが良いです。

```text
1. これまで何を問題としていたか
2. 途中で何を却下・変更したか
3. 最終的にどのMental Modelへ到達したか
4. GitHub上で何を生成・保存・commitするか
```

特に重要なのは2です。

たとえば今回なら、

```text
最初:
Understanding / External / Internal

↓

MDN / K8s / Rustdoc / Sourcegraph を追加

↓

MDNは軽量化
K8sはConcept型へ深化

↓

FACT / INFERENCE / PROPOSAL / UNKNOWN を追加

↓

Sourcegraphを Relation / Impactへ拡張

↓

Canonical AnalysisをSource of Truth化

↓

完成HTMLを参照できない環境でも
同じMental Modelからゼロ生成できるAgent Builder Instructionsへ変換
```

という**設計変更の履歴**まで渡した方がいいです。

そうするとCodexは単に「最終形をコピーする」のではなく、

> なぜこの構造なのか

まで保持して作業できます。

GitHub側には、例えばこんな形で残すと綺麗です。

```text
repo/
├─ agents/
│  └─ module-analysis/
│     ├─ instructions.md
│     └─ design-rationale.md
│
├─ templates/
│  ├─ pattern-c-multiview-v3.html
│  └─ sessionlog-mentalmodel-builder.html
│
└─ docs/
   └─ architecture/
      └─ multiview-analysis-model.md
```

`design-rationale.md` が地味に重要です。

ここに、

```text
Why Canonical Analysis?
Why MDN/K8s/Rustdoc/Relation-Impact?
Why FACT vs INFERENCE?
Why separate DOCUMENT and VIEW?
Why Evidence links?
```

を残す。

これがあると、次回Codexを起動したときにも「最終ファイルだけ見て意味を推測する」羽目になりません。

今回の目的なら、**Codexにこの会話の最終回答だけ渡すのではなく、この議論の設計履歴を圧縮したhandoff documentを最初に作らせる**のが一番いいです。

つまり、

```text
この会話
↓
design-handoff.md
↓
Codex
↓
repoへ生成
↓
git diff
↓
commit
↓
push
```

です。

この形なら、かなり本当に「同じ議論を辿らせる」に近づきます。人間同士なら議事録を読めで済むところを、AI同士でも結局議事録が必要になるあたり、文明は思ったより地味です。
