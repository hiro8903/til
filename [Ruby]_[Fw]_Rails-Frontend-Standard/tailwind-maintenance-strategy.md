# Tailwind CSS メンテナンス戦略 (Maintenance Strategy)

このドキュメントでは、Rails プロジェクトにおける Tailwind CSS の一括管理とディレクトリ構造の指針（Strategy）を整理します。

---

## 🛠️ 1. デザインの共通化・一括管理の手法 (Maintenance)

「何百箇所もあるボタンの色を一気に変えたい」といった運用コストを下げるための 3 層のアプローチです。

### ① テーマ設定 (Custom Theme)
プロジェクト全体のデザインの **「Source of Truth（唯一の真実）」** です。
*   **ファイル**: `tailwind.config.js`
*   **役割**: 「primary」という色を定義し、アプリ全体でその名前を使い回します。

### ② クラスの抽出 (@apply)
CSS ファイル側で、よく使うクラスの組み合わせに「名前」を付けます。
*   **役割**: ボタンや入力フォームなどの **最小単位（アトミックパーツ）** の装飾。

### ③ Rails コンポーネント化 (Partial / ViewComponent)
HTML の構造ごと「部品」として切り出します。これが **Rails 開発におけるメインの手法** です。
*   **役割**: 「アイコン付きニュースカード」のような、**構造とデザインのセット**。

---

## 💡 2. Rails 開発で「コンポーネント化」が推奨される理由

1.  **構造とスタイルの同時管理**: `@apply` では CSS クラス名しか共通化できませんが、コンポーネント語なら「アイコン付きボタン」のような **HTML 構造ごと固定** できます。
2.  **型（ViewComponent）の普及**: テストが可能で、Ruby クラスとして UI 部品を堅牢に定義できます。
3.  **記述のノイズ削減**: ビュー（`index.html.erb` 等）に何百行も並ぶのを防ぎ、ビジネスロジックの見通しを良くします。

---

## 📂 3. フォルダ構成とファイルの分割 (File Splitting)

実務における、①（土台）、②（CSS結合）、③（HTML部品）の関係性を示す理想的なフォルダ構成です。

```text
(Project Root)
├── tailwind.config.js          # ① 全体の土台（色の定義など）
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       ├── application.tailwind.css  # メイン CSS ファイル
│   │       └── components/               # ② @apply (CSS の部品)
│   │           ├── _buttons.css
│   │           └── _inputs.css
│   └── views/
│       ├── shared/                       # ③ Rails Components (HTML 汎用)
│       │   ├── _button.html.erb
│       │   └── _badge.html.erb
│       └── layouts/
│           └── _header.html.erb          # 共通ヘッダー
```

---

## 📁 4. 共通パーツの置き場所 (File Structure)

再利用の範囲（スコープ）に合わせてフォルダを分けるのが Rails のベストプラクティスです。

| フォルダ | 役割 | 具体例 |
| :--- | :--- | :--- |
| **shared/** | アプリ全域で使う汎用部品 | `_button.html.erb`, `_input.html.erb` |
| **layouts/** | 画面の枠組み、ガワ | `_header.html.erb`, `_sidebar.html.erb` |
| **[モデル名]/** | 各モデル専用の独自部品 | `users/_user_card.html.erb` |

---

### 📡 5. Tailwind の仕組み：入り口 (Entry Point)

Rails で Tailwind を有効にするためには、以下の 3 行が必要不可欠です。

*   **ファイル**: `app/assets/stylesheets/application.tailwind.css`
```css
@tailwind base;       /* (1) ブラウザ標準スタイルのリセット */
@tailwind components; /* (2) @apply クラスやプラグインの展開 */
@tailwind utilities;  /* (3) ユーティリティクラスの展開 */
```

#### ✨【プラスα】レイヤーの優先順位 (@layer)
独自の CSS（@apply 等）を書くときは、必ず `@layer` で囲むのが正解です。
```css
@layer components {
  .btn-primary { @apply bg-blue-500 text-white; }
}
```
> **Point**: `@layer` を使うことで、Tailwind 本体が持っているクラスとの**優先順位が正しく制御**され、「後から HTML 側で少しだけ上書きしたい（例：`class="btn-primary p-8"`）」といったときに、意図通りに動くようになります。

---

## ❓ 6. よくある質問 (FAQ)

### Q. ②（@apply）を一切使わないなら、app/assets フォルダは消して良い？
**A. いいえ、消せません。**
1.  **Tailwind の起動**: `application.tailwind.css` の `@tailwind ...` の 3 行があって初めて機能が有効になります。
2.  **その他の管理**: 画像 (`images/`) やフォントを置く場所としても Rails の規約上で必要です。

---

## 🏗️ 7. 適材適所の棲み分け (When to use what)

| 手法 | 役割 | 頻度 |
| :--- | :--- | :--- |
| **① テーマ** | 設計図 | **必須** |
| **② @apply** | CMSや外部ライブラリ等の HTML 用 | **たまに必要** |
| **③ 部品化** | 開発の主力 | **メイン (95%)** |
