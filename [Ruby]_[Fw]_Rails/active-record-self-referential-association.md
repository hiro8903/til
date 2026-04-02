# [Ruby] [Fw] Rails: 自己参照リレーション（Self-Referential Association）による階層構造の実現 (-concept)

「ホールディングス企業と子会社」「全国の支店網」「商品の大カテゴリ・小カテゴリ」「上司と部下の上長設定」など、システム開発において「同じ種類のデータを親子関係（階層構造）で管理したい」という要望は100%発生する。
これらを別々のテーブル（親テーブルと子テーブル）に分けることなく、**1つのテーブルの中で完結して無限の階層を表現する設計テクニック**を「自己参照（Self-Referencing）」と呼ぶ。

---

## 💡 Context (背景)

基幹システムの取引先マスタ（`BusinessPartner`）設計において、「ホールディングスの枠組みでグループ企業をまとめて見たい」かつ「個別の支店や子会社ごとに取引もしたい」という要件が発生した。これを実現するため、別テーブルを使わず、同テーブル内に `parent_id` を持たせる自己参照設計を採用した。

---

## 🛠 データベース側の設計（マイグレーション）

テーブル内に「自分の親要素のID」を保存するためのカラム（通例は `parent_id`）を1つだけ追加する。

```ruby
class CreateBusinessPartners < ActiveRecord::Migration[8.1]
  def change
    create_table :business_partners do |t|
      t.string :name, null: false
      
      # 自分と同じテーブル(business_partners)のIDを保存する箱を作る。
      # to_table オプションで「外部キーの紐づけ先は自分自身だよ」と明示するのが必須ルール。
      t.references :parent, foreign_key: { to_table: :business_partners }
    end
  end
end
```

マイグレーションでの最重要ポイントは **`foreign_key: { to_table: :自分自身のテーブル名 }`** である。これがないと、Railsが「`parents` という別のテーブルを探しに行く」ことになりエラーで落ちる。

---

## 🛠 モデル側の設計（アソシエーション）

1つのモデル（単一のクラスファイル）の中に「親の顔（`belongs_to`）」と「子の顔（`has_many`）」の両方を書き込む。

```ruby
class BusinessPartner < ApplicationRecord
  # ① 親から見た「子どもたち」の設定
  # 「children」という名前で呼ぶが、実際のシステム上の正体は「BusinessPartner」だよ、と教える。
  # 子どもたちは「自分（親）のIDを parent_id に持っているやつら」であると指定する。
  has_many :children, class_name: 'BusinessPartner', foreign_key: 'parent_id', dependent: :destroy

  # ② 子から見た「親」の設定
  # 「parent」という名前で呼ぶが、実際の正体は「BusinessPartner」だよ、と教える。
  # optional: true は「（最上位のホールディングス自体のように）親がいない場合もあるよ」という意味。
  belongs_to :parent, class_name: 'BusinessPartner', optional: true
end
```

### なぜ `class_name` や `foreign_key` が必要なのか？
通常、`belongs_to :parent` と書くと、Railsは勝手に `Parent` というモデル（別のRubyファイル）を探しにいってしまう。今回は「親も子も全員 BusinessPartner クラスである」という特殊な状況なため、オプションで「本当の姿」を強制的に教えてあげる必要がある。

---

## 🚀 使い方と絶大なメリット

この設定を済ませると、Ruby のコードで以下のように「無限に遡る・潜る」ことが一行でできるようになる。

```ruby
# 1. 孫会社（パナオート九州）から、親会社（パナオート）、さらに大元の親（パナHD）を順に辿る
branch = BusinessPartner.find(4)
puts branch.parent.name         # => "パナソニック オートモーティブ(株)"
puts branch.parent.parent.name  # => "パナソニック ホールディングス(株)"

# 2. 親会社から、所属する全ての子会社を配列で取り出す
holdings = BusinessPartner.find(1)
holdings.children.each do |child|
  puts child.name
end
```

### なぜ別テーブル（Group等）を作らないのか？
別テーブルで `Group` > `Company` のような関係を作ってしまうと、「階層が2階層で固定」されてしまう。自己参照であれば、「パナHD > パナソニック > パナオート > パナオート九州」のように、**階層の深さが全くの無制限**になる。これが基幹システムにおいて自己参照が無双する最大の理由である。

---

## 🔗 Official References (一次情報)

- **Rails Guides - Active Record Associations**: [Self Joins (自己結合)](https://guides.rubyonrails.org/association_basics.html#self-joins)
