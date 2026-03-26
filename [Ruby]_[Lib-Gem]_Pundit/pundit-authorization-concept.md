# 🛡️ Pundit: Rails における認可（Authorization）管理の全体像

🔗 **公式ドキュメント**: [GitHub: varvet/pundit](https://github.com/varvet/pundit)

## 📖 Pundit とは何か？（What / Why）

Pundit（パンディット）は、Ruby on Rails アプリケーションにおいて **「認可（Authorization）」** をシンプルかつ強力に管理するためのライブラリ（Gem）です。

### 認証（Authentication）と認可（Authorization）の違い
これらはよく混同されますが、役割が全く異なります。
*   **認証 (Authentication)**: 「あなたは誰ですか？」を確認する仕組み。（例: ログイン機能。Devise や Rails 8 公式認証が担当）
*   **認可 (Authorization)**: 「あなたは**これをする権利**がありますか？」を判定する仕組み。（例: 「この画面を開けるか？」「このデータを削除できるか？」これを Pundit が担当）

### なぜ Pundit が必要なのか？
Pundit を使わない場合、コントローラーやビューのあちこちに「もし自分が管理者なら…」「もしこのデータの作成者が自分なら…」という複雑な `if` 文が散乱し、コードが非常に読みづらく、テストも難しくなります。

Pundit を導入すると、これらの「権限チェックルール」を **Policy（ポリシー）** という専用のクラスに隔離できます。これにより、コントローラーのコードを極限までクリーンに保つことができます。

---

## 🏗️ 一般的な活用事例と仕組み（How）

Pundit は基本的に「1つのモデルに対して、1つの Policy クラス」を作成します。

### 1. ポリシーの定義 (Policy Class)
`app/policies/` ディレクトリにルールを記述します。

```ruby
# app/policies/post_policy.rb
class PostPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  # 更新（Edit/Update）ができる条件
  def update?
    # 自分が作成した記事か、システム管理者であれば更新可能
    post.user_id == user.id || user.admin?
  end

  # 削除（Destroy）ができる条件
  def destroy?
    # 削除できるのはシステム管理者のみ
    user.admin?
  end
end
```

### 2. コントローラーでの権限チェック (Controller)
コントローラーでは `authorize` メソッドを呼ぶだけです。中で Pundit が自動的に `PostPolicy` の `update?` などを呼び出し、権限がなければエラー（アクセス拒否例外）を投げます。

```ruby
class PostsController < ApplicationController
  def update
    @post = Post.find(params[:id])
    
    # ここで権限チェック！権限がなければここで処理が終わる
    authorize @post
    
    if @post.update(post_params)
      redirect_to @post
    # ...
  end
end
```

### 3. ビューでの出し分け (View)
ビュー（画面）でも、権限がないユーザーには「編集ボタン」自体を見せないように簡単に制御できます。

```erb
<!-- @postを更新する権限がある場合だけリンクを表示する -->
<% if policy(@post).update? %>
  <%= link_to '編集する', edit_post_path(@post) %>
<% end %>
```

### 2. コントローラーでの標準的な実装（The Correct Way）

コントローラー側では、Pundit が提供する内部ロジックを意識する必要はありません。以下の 3 つのステップで「門番」を配置するのが標準的な実装です。

#### 1) 機能を共通コントローラーで読み込む
`ApplicationController` で一度だけ読み込めば、すべてのコントローラーで Pundit が使えるようになります。

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization # 認可機能を有効化
end
```

#### 2) 各アクションで `authorize` を呼び出す
アクション内で対象となるモデルのインスタンスを渡し、`authorize` メソッドを呼びます。

```ruby
def update
  @user = User.find(params[:id])
  
  # 門番の呼び出し
  # Pundit が自動で UserPolicy を探し、update? メソッドを実行します
  authorize @user
  
  # 権限があればここから下に進める
  if @user.update(user_params)
    # ...
end
```

#### 3) 権限がない場合のエラーハンドリング
`authorize` が失敗した時（`false` を返した時）に、どういう画面（例: 403 Forbidden やリダイレクト）を出すかを一箇所で定義します。

```ruby
# ApplicationController などに記述
rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

private

def user_not_authorized
  flash[:alert] = "この操作を行う権限がありません。"
  redirect_to(request.referrer || root_path)
end
```

---

## 🏭 製造業アプリ (`mfg_core`) での特殊な活用例

一般的な Web サービスでは上記のように「データの作成者が自分か？」で判定することが多いですが、私たちの `mfg_core` のような企業向け業務システムでは少し異なります。

### 複数組織・兼務による「動的な権限解決」のガードマンとして
`mfg_core` には以下の要件があります。
*   一人の社員が「人事部」と「第1工場」を兼務している
*   組織（OrgUnit）ごとに持っている権限が違う

このような非常に複雑な条件で「その人はこのボタンを押していいのか？」を毎回 Controller に書くのは不可能です。

**`mfg_core` ではどう使っているか？**
1. `User` モデルに、自分が現在所属している全組織の権限をかき集めるメソッド（例: `effective_permissions`）を作る。
2. Pundit の Policy では、その集めたリストの中に `manage_inventory` (在庫管理権限) があるかどうか？ **だけ**をチェックする。

これによって、**「どんなに人事異動が複雑になっても、Pundit のガードチェックの文法自体はずっとシンプルなまま」**という美しいアーキテクチャを実現しています。
