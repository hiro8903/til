# Rails 8 + Tailwind CSS v4：標準セットアップと「読み込みの魔法」

Rails 8 において Tailwind CSS v4（`tailwindcss-rails`）を導入する際、最もシンプルで強力な「正解の導入方法」を記録します。

---

## 1. 成功への「黄金の手順」
公式ガイドに従った以下の手順のみで、Tailwind は完璧に動作します。

1.  `bundle add tailwindcss-rails`
2.  `bin/rails tailwindcss:install`
3.  **サーバーの再起動**（`bin/dev` の起動）

> [!TIP]
> **なぜ `rails s` ではなく `bin/dev` なのか？**
> `rails s` だと Rails サーバーしか起動しません。Tailwind でクラス名から自動的に CSS を作成（ビルド）させるには、常に CSS の変更を監視するプロセスも同時に動かす必要があります。`bin/dev` は、「Rails サーバー」と「Tailwind の監視」の両方を同時に起動してくれるコマンドであるため、見た目を開発する際は必ず `bin/dev` を使います。

---

## 1.1 【最重要】どこを編集し、どこを触らないか (Source vs Build)
Tailwind v4 の環境では、2 つの似たような CSS ファイルが存在する。開発者が編集すべき場所を間違えると、**「書いたコードが消える」** というトラブルに直面するため、以下の鉄則を遵守すること。

### ✍️ 編集する場所（Source: 設計図）
- **パス**: `app/assets/tailwind/application.css`
- **役割**: 私たち人間が CSS を書き込む「源泉」である。

### 🚫 触ってはいけない場所（Build: 成果物）
- **パス**: `app/assets/builds/tailwind.css`
- **役割**: `bin/dev`（Tailwind CLI）が自動生成する「印刷された本」である。
- **注意**: ここを直接編集しても、**次の保存の瞬間に自動で上書きされ、修正はすべて消滅する。**

### 💡 開発サイクル（Work Flow）
1.  `tailwind/application.css` を編集・保存する。
2.  `bin/dev` が変更を検知し、瞬時に `builds/tailwind.css` を更新（再翻訳）する。
3.  ブラウザをリロードして反映を確認する。

---

## 2. Rails 8 + `:app` の「魔法」
Rails 8.1 から導入された物理的なフォルダ走査の自動化により、レイアウトファイルの読み込みタグは以下の 1 行だけで完結します。

```erb
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
```

### この 1 行が裏で行っていること
監督（Propshaft）は、ロードパス（`app/assets/builds` 等）を徘徊し、そこにあるスタイルシートを自動で見つけ出します。
- `application.css` → 自動検出
- **`tailwind.css`（ビルド成果物）** → **自動検出**

結果として、HTML には 2 つの `<link>` タグが吐き出され、すべてが正常に動作します。

---

## 3. 【重要】アセット登録の確認方法
不具合が疑われる時、監督（Propshaft）が見ている台帳を「ありのまま」表示させるのが、最も確実なデバッグ方法です。

### 🚨 最も確実な確認コマンド（台帳 vs 巡回ルート）

#### 1. 台帳（有効なアセット一覧）の確認
「そのファイルは、アセットとして正規に認められているか？」をチェックします。
```bash
bin/rails runner 'puts Rails.application.assets.load_path.assets.map(&:logical_path).inspect'
# 結果: [#<Pathname:tailwind.css>, #<Pathname:application.css>, ...]
```
このように **`#<Pathname:tailwind.css>`** がリストに含まれていれば、Propshaft はそのファイルを配信する準備が整っています。

#### 2. 巡回ルート（Load Path）の確認
「監督がそもそも、どのフォルダを物理的に捜索しているのか？」をチェックします。
```bash
bin/rails runner 'puts Rails.application.assets.load_path.paths.map(&:to_s).inspect'
# 結果: ["/Users/dev/.../app/assets/builds", "/Users/dev/.../app/assets/stylesheets", ...]
```
もしここに目的のフォルダがない場合は、設定間違いか、Gem が正しく読み込まれていない可能性があります。

---

## 4. 最後に
公式 Gem が作成する `tailwind/` ディレクトリは、現代の Rails 8 + Propshaft においては「アセット解決」を妨げるものではありませんでした。

迷ったら、**「公式の手順を信じ、この 2 つのコマンドで台帳を確認し、サーバーを再起動する」**。これが最も確実で迅速なゴールへの近道です。

---

## 📚 リファレンス (References)
- [Tailwind CSS v4: Framework Guides - Ruby on Rails](https://tailwindcss.com/docs/installation/framework-guides/ruby-on-rails)
- [tailwindcss-rails (GitHub)](https://github.com/rails/tailwindcss-rails)
