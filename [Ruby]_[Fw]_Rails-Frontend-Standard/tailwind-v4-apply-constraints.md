# Tailwind CSS v4 における `@apply` の制約とトラブルシューティング

## 🕯️ 背景 (Background)
CSS コンポーネント（例：ボタン）を定義する際、共通部分を `.btn` として定義し、それを他の `.btn-primary` 等で使い回そうと（DRY 化しようと）した際に発生したエラーの記録。

---

## 🚫 1. 発生した問題 (The Issue)

### 実行したコード
```css
.btn {
  @apply px-4 py-2 rounded-md ...;
}

.btn-primary {
  @apply btn bg-blue-600 ...; /* ← ここでエラー */
}
```

### 🚨 エラーメッセージ
> **`Error: Cannot apply unknown utility class btn`**

### なぜこれが起きるのか？ (The Cause)
Tailwind CSS（特に v4）の `@apply` 命令は、基本的に **「Tailwind 本来のユーティリティ（`px-4` 等）」** を対象としている。

同じファイル内の `.btn` を `@apply` しようとすると、コンパイラが「`.btn` って何？ そんなユーティリティは知らないぞ！」と混乱し、処理を止めてしまう（公式のプラグイン等で登録しない限り、自作クラスを入れ子にすることは推奨されていない）。

---

## ✅ 2. 解決策：スタイルの「フラット化」 (Flattening)

入れ子（ネスト）を避け、各コンポーネントクラスに直接 Tailwind のクラスを書き出す。

### 修正後のコード
```css
.btn-primary {
  /* 共通部分をそのまま書く */
  @apply inline-flex items-center px-4 py-2 rounded-md font-medium text-sm ...;
  /* 固有部分を書く */
  @apply bg-blue-600 text-white hover:bg-blue-700;
}

.btn-secondary {
  @apply inline-flex items-center px-4 py-2 rounded-md font-medium text-sm ...;
  @apply bg-white text-gray-700 border border-gray-300;
}
```

---

## ⚖️ まとめ (Conclusion)
- **`@apply` は Tailwind の「部品」を呼ぶためのもの**: 自作の「部品」を呼ぶためのものではない。
- **DRY よりも確実性を優先**: CSS レベルでの共通化（`.btn` を作って `@apply` する）にこだわりすぎず、各コンポーネントに直接スタイルを適用するのが、モダンな Tailwind 開発の「堅実な近道」である。

---

## 📚 リファレンス (References)
- [Tailwind CSS v4 Documentation - @apply](https://tailwindcss.com/docs/v4-beta#using-apply)
- ※v4 では CSS 変数（`--btn-padding: ...`）を活用した共通化が推奨されることもあるが、Rails 環境では `@apply` のフラットな記述が最もトラブルが少ない。
