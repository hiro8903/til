# Rails View における `capture` ヘルパーの極意

## 🕯️ 背景 (Background)
Rails の View（`.html.erb`）では、通常 Ruby のコードは書いた瞬間に実行・出力される。しかし、「特定の HTML の塊を一旦変数に保存しておき、後で別の場所（あるいは部品内）で使いたい」という場面がある。これを実現するのが `capture` ヘルパーである。

---

## 🎯 1. `capture` の本質：HTML の「瞬間冷凍」
`capture` は、ブロック（`do...end` や `{...}`）の中に書かれた HTML や Ruby の実行結果を、ブラウザに出力せず **文字列（String）として変数に格納** する役割を持つ。

### イメージ
「今すぐ食べる（表示する）」のではなく、「お弁当箱（変数）に詰めて後で食べる」という状態。

---

## 🛠️ 2. 基本的な用語と動き

### 名称 (Term)
- **`capture`**: 「捕らえる、記録する」という意味の Rails ヘルパーメソッド。

### 他の場面での使い方の例
`render` 以外でも、View 内の重複を防ぐために使用できる。

```erb
<%# 1. HTML の塊を変数に保存（瞬間冷凍） %>
<% red_button = capture do %>
  <button class="bg-red-500 text-white p-2">削除する</button>
<% end %>

...（長いコンテンツ）...

<%# 2. 好きな場所で解凍して表示 %>
<div class="footer">
  <%= red_button %>
</div>
```

---

## 🚀 3. なぜ `render`（パーシャル）と組み合わせて使うのか？

パーシャル（共通部品）に「ボタンのリスト」などの複雑な HTML を渡したい場合、通常の引数（例：`title: "文字"`）では限界がある。

### 解決できる課題
- **直接指定の限界**: `actions: link_to(...)` と書くと、その瞬間に呼び出し側の画面にボタンが出てしまい、部品の中に渡すことができない。
- **`capture` の効能**: `capture` で一旦「文字列」にすることで、安全に部品の奥深く（`actions` エリアなど）まで荷物を届けることができる。

#### 使い方（セットメニュー）
```erb
<%= render "shared/card", 
    actions: capture { %>
      <%= link_to "編集", edit_path %>
<% } %>
```

---

## ⚖️ まとめ
- **`capture` は独立した機能**: `render` 専用ではなく、View 全体で使える「HTML の変数化ツール」である。
- **役割の分離**: 中身を「作る」のは View（発注者）、どこに「置くか」を決めるのは Shared（職人）という役割分担を支援する。
- **シンタックス**: `capture { %> ... <% } %>` のように書くことで、複雑な HTML 構造をそのまま小包にできる（詳細は、[ERB の掟：入れ子禁止と世界の切り替え](./erb-tag-nesting-and-world-switching.md) を参照）。

---

## 📚 リファレンス (References)
- [ActionView::Helpers::CaptureHelper (Official API Ref)](https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html)
