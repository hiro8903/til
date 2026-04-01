# Tailwind CSS 実用パターンガイド (Tailwind CSS Practical Patterns)

このドキュメントでは、「こういう見た目・動きを作りたい」という具体的な実装手順（How-To）を整理します。

---

## 📐 1. レイアウト (Layout)

### ① 上下左右の中央揃え (The Center)
**【実例】** モーダルの中身や、アイコン付き ボタンの配置。
```html
<!-- Flexbox を使う場合 (主流) -->
<div class="flex items-center justify-center">
  <span>中央に配置</span>
</div>

<!-- Grid を使う場合 (一撃で決まる) -->
<div class="grid place-items-center">
  <span>中央に配置</span>
</div>
```

### ② モバイルファースト：レスポンシブの鉄則 (Mobile First)
Tailwind の `sm:`, `md:`, `lg:` は、**「その画面幅以上になったら」** という意味です。

*   **正しい書き方 (Mobile First)**: 「まずスマホの見た目を書き、画面が広い時だけ上書きする」
```html
<!-- スマホ(1列) → PC(3列) -->
<div class="grid grid-cols-1 md:grid-cols-3 gap-6"> ... </div>

<!-- スマホ(文字小) → PC(文字大) -->
<h1 class="text-sm md:text-2xl font-bold">タイトル</h1>
```
> **Point**: 「スマホ用の `sm:`」を書くことはありません。接頭辞なしがスマホ、`md:` が PC と考えましょう。

---

## 🖱️ 2. インタラクションと状態 (State Management)

### ① 親のホバーで子を変える (Group Hover)
**【実例】** カード全体をホバーした時に、中のテキストの色を変えたり、アイコンを動かす。
```html
<div class="group border p-4 hover:bg-blue-50 transition-colors">
  <h3 class="text-gray-900 group-hover:text-blue-600 font-bold transition-colors">
    タイトル
  </h3>
  <p class="text-gray-500">詳細はここをクリック</p>
</div>
```
> **Point**: 親要素に `group` クラスを付け、子要素に `group-hover:xxx` を指定します。

### ② アクセシビリティ：フォーカスリング (Focus States)
**【実例】** キーボード操作時に「今どこを選択しているか」を明確にする。
```html
<button class="bg-blue-500 px-4 py-2 ring-offset-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
  送信
</button>
```
> **Point**: `focus:outline-none` でブラウザ標準の枠線を消す場合は、必ず `focus:ring` で代わりの視覚フィードバックを用意してください。

### ③ ✨【プラスα】心地よい変化 (Transitions)
ただ色が変わるだけでなく、少し時間をかけて変化させるだけで、UI の高級感が一気に増します。
```html
<!-- duration-300: 0.3秒かけて変化 -->
<button class="bg-blue-500 hover:bg-blue-600 transition-colors duration-300">
  ふわっと変わるボタン
</button>
```

---

## 📝 3. テキストと装飾のテクニック (Typo & Decoration)

### ① 長い文章を「...」で省略する (Line Clamp)
**【実例】** ニュース一覧などで、2行以上になるテキストを切り捨てる。
```html
<!-- 1行で省略 -->
<p class="truncate">とても長い文章がここに入りますが、はみ出すと三点リーダーになります。</p>

<!-- 2行指定で省略 (実務で多用) -->
<p class="line-clamp-2">ここには説明文が入ります。2行を超えると自動的に省略されます。</p>
```

### ② 画像の比率を固定する (Aspect Ratio)
**【実例】** 写真のサイズがバラバラでも、16:9 などの一定の枠に美しく収める。
```html
<div class="aspect-video w-full overflow-hidden rounded-lg">
  <img src="photo.jpg" class="h-full w-full object-cover">
</div>
```

### ③ 色の透過指定 (Color Opacity)
**【実例】** 背景や文字を、色味を保ったまま半透明にする。
```html
<!-- スラッシュの後に数値(0-100)を入れるだけ (v3系以降) -->
<div class="bg-blue-500/50 text-black/80 p-4">
  背景は50%、文字は80%の不透明度
</div>
```

---

## ⚡ 4. 効率的な実務テクニック (Efficiency)

### ① スペーシングの「4の倍数」ルール
Tailwind の数値は、基本的に **1 = 4px** です。
*   `p-1` = **4px**
*   `p-4` = **16px** (1rem)
*   `p-10` = **40px**
> **Tip**: デザインカンプからピクセル値を読み取るとき、**「4で割れば Tailwind の数値になる」** と覚えると爆速です。

### ② 条件分岐：Rails の `class_names` ヘルパー
Rails 6.1 以降で使える、条件によってクラスを付け替えるための最強の武器です。
```erb
<div class="<%= class_names(
  'p-4 rounded-lg',                     # 常に付与
  'bg-blue-500 text-white': active?,    # 条件が真の時に付与
  'bg-gray-100 text-gray-500': !active? # 条件が偽の時に付与
) %>">
  ステータス
</div>
```

---

## 🚀 5. 実務上の「禁じ手」と対策 (Anti-Patterns)

### ❌ やってはいけない：クラス名の文字列結合
```javascript
// 動かない例
const color = 'blue';
return <div className={`bg-${color}-500`} />; // Tailwind のスキャナーが認識できない
```

### ✅ 正しいやり方：完全なクラス名を指定する
```javascript
// 動く例
const colorClass = {
  blue: 'bg-blue-500',
  red: 'bg-red-500'
}[color];

// または Rails なら、やはり class_names が最適です。
```

---

## 📚 公式リファレンス (Reference)
*   [Tailwind CSS Docs](https://tailwindcss.com/docs)
