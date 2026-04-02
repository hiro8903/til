# [Ruby] [Fw] Rails: params で受け取るデータの仕組み (-concept)

Rails アプリケーションにおいて、ブラウザ（フロントエンド）から送られたデータを、コントローラ（バックエンド）で受け取るための標準的な仕組みである **`params`** についてまとめる。

---

## 💡 Context (背景)

コントローラの `index` メソッドにおいて、`if params[:discarded] == "true"` という記述が登場した。この `discarded=true` というラベルが、いつ、どこから送られてくるのかという疑問をきっかけに、Rails のデータ受け渡しの全体像を整理した。

---

## 📖 params とは

`params` は、Rails がリクエスト（ユーザーの操作）から抽出した情報を格納している、ハッシュのようなオブジェクトである。主に以下の 3 つの場所からデータを受け取る。

### 1. URL の末尾（Query Strings / クエリ文字列）
URL の末尾に `?キー=値` という形式で、追加の「添え書き」を添える方法。

- **URL 例**: `http://localhost:3000/users?discarded=true`
- **受け取り**: `params[:discarded]` は `"true"` となる。
- **よく使われる場面**: 画面の絞り込み機能や、検索ワードの指定など。

#### 🌿 Rails のビューでの指定方法

```erb
<%#    第1引数: 表示文字    第2引数: 行き先URL + パラメータ      第3引数: 見た目(任意) %>
<%= link_to "退職済み表示", users_path(discarded: true),  class: "btn-link" %>
```

- **第1引数**: ユーザーがクリックする**「テキスト」**を指定する。
- **第2引数**: **「目的地」**を指定する。ここにパスヘルパーと一緒にパラメータを渡すことで、URL の末尾にクエリ文字列が付加される。
- **第3引数**: `class` や `id` など、**「aタグ自体の属性」**を指定する。

### 2. URL 自体の一部（Path Parameters / パスパラメータ）
ルート定義 (`routes.rb`) に基づき、URL の特定の位置から値を取り出す方法。

- **URL 例**: `http://localhost:3000/users/1`
- **ルート定義**: `get '/users/:id', to: 'users#show'`
- **受け取り**: `params[:id]` は `"1"` となる。

### 3. フォームの入力値（POST Data / フォームデータ）
入力画面からボタンを押して送信されたデータ。

- **例**: `<input type="text" name="user[name]" value="田中">`
- **受け取り**: `params[:user][:name]` は `"田中"` となる。

---

## ⚠️ 初心者がハマりやすい注意点

### 値は常に「文字列（String）」である
`params[:discarded]` に入る値は、中身が数字であっても真偽値であっても、ブラウザから届いた時点では **すべて文字列** である。
- ⭕️ 正解: `if params[:discarded] == "true"` （文字列として比較する）
- ❌ 間違い: `if params[:discarded] == true` （真偽値と比較しても一致しない）

---

## 🔗 Official References (一次情報)

- **Rails Guides - Action Controller Parameters**: [公式ドキュメント](https://guides.rubyonrails.org/action_controller_overview.html#parameters)
  - コントローラでパラメータを扱うための網羅的な仕様。
- **Rails API - link_to**: [公式解説](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
  - リンクを生成する際にパラメータを付与する方法の詳細。

---

## 💡 まとめ：params は「お手紙のラベル」

ブラウザからサーバーへのリクエストを「お手紙」だとすると、`params` はその封筒に貼られた幾つかの「ラベル（添え書き）」のようなものである。
コントローラ側でこのラベルを確認することで、「今の操作は、検索のための操作なのか？」「それとも特定の ID の詳細を表示したいのか？」といった、**ユーザーの細かな意図を正確に把握する**ことができる。
