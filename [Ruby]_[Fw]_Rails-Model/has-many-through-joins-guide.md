# 🔗 has_many :through による中間テーブル実装の実践ガイド

🔗 **公式ドキュメント**: [Rails Guides: Associations - The `has_many :through` Association](https://guides.rubyonrails.org/association_basics.html#the-has_many-through-association)

## 📖 概要 (What / Why)

Rails で「多対多（Many-to-Many）」の関係を構築する際、**中間テーブルそのものに属性（例：開始日、役割、備考など）を持たせたい場合**、`has_many :through` 関連付けを使用するのが「正解」です。

### なぜ `has_many :through` なのか？
*   **履歴管理**: 「いつからいつまで所属していたか」といった時間軸を持てる。
*   **属性の付与**: 「所属している」という関係性だけでなく、「どういう役割（Role）で」所属しているかを記録できる。

---

## ⚖️ 比較：`has_and_belongs_to_many` (HABTM) との違い

Rails にはもう一つ、多対多を実現する `has_and_belongs_to_many`（以下 HABTM）という簡易的な方法がありますが、**実務（特に業務システム）では `has_many :through` が強く推奨されます。**

| 特徴 | `has_and_belongs_to_many` | `has_many :through` (推奨) |
| :--- | :--- | :--- |
| **中間テーブルのモデル** | 存在しない（DBテーブルのみ） | **存在する（ActiveRecord モデル）** |
| **拡張性** | 低い（後から日付などは足せない） | **高い（自由にカラムを追加可能）** |
| **バリデーション** | 難しい | **容易（Railsの通常の検証が使える）** |
| **用途** | 単純なタグ付け、カテゴリ等 | **業務上の履歴（配属、在庫等）** |

### デメリットとしての HABTM
HABTM は「ID のペアを保存するだけ」の非常にシンプルな用途に特化しています。しかし、開発が進むにつれて「いつこの関係が作られたか知りたい」「備考を残したい」といった要望が出た際、HABTM だと**テーブルの作り直し（マイグレーションの破壊的変更）**が必要になります。

将来の拡張性を担保するため、最初から **`has_many :through`** で設計しておくのが Rails 開発における「定石」です。

---

## 🏗️ ステップバイステップ実装手順 (How)

今回の `mfg_core` プロジェクト（ユーザー ↔ 中間テーブル ↔ 組織）を例に進めます。

### Step 1. 両端のモデルを作成する
まずは「本人（User）」と「所属先（OrgUnit）」という両端の箱を作成します。

```bash
# ユーザー（名簿）
bin/rails generate model User user_code:string name:string

# 組織単位（部署・PJ）
bin/rails generate model OrgUnit code:string name:string
```

### Step 2. 中間テーブルを作成する（`references` の活用）
中間テーブル `Assignment` を作成します。ここで **`user:references`** を使うのがポイントです。これにより、外部キー（user_id）と、関連付けのための初期インデックスが自動で生成されます。

```bash
# 配属辞令履歴（中間テーブル）
# ※ ここに「いつから(start_date)」や「役割(role)」といった「関係性のデータ」を持たせる
bin/rails generate model Assignment \
  user:references \
  org_unit:references \
  role:integer \
  start_date:date
```

### Step 3. モデル間の関連付けを設定する
ここが「Railsで多対多を実現する」ための作業です。

#### 1) 中間テーブル (`Assignment`)
`rails generate` 時に `references` を使っていれば、`belongs_to` は自動で記述されています。

```ruby
# app/models/assignment.rb
class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :org_unit
end
```

#### 2) 本人 (`User`)
中間テーブルを経由して、反対側の組織を「覗き込む」設定を追加します。

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :assignments                  # 中間テーブルとの直接の紐付け
  has_many :org_units, through: :assignments # assignments を「経由して」組織を引く
end
```

#### 3) 組織 (`OrgUnit`)
逆方向も同様に設定します。

```ruby
# app/models/org_unit.rb
class OrgUnit < ApplicationRecord
  has_many :assignments
  has_many :users, through: :assignments # assignments を「経由して」ユーザーを引く
end
```

---

## 🚀 活用事例 (Usage Pattern)

設定が完了すると、Rails が裏側で自動的に SQL を組み立ててくれるため、非常に直感的にデータを扱えます。

### 1. ユーザーから所属組織を一覧する
```ruby
user = User.find_by(user_code: "U001")
user.org_units # ここで JOIN された組織データが一気に取れる
```

### 2. 「中間テーブル上のデータ」にアクセスする
単なる ID のペアではなく、中間テーブルのデータが必要な場合はこう書けます。
```ruby
# ユーザーの全配属履歴を取得し、その「役割（role）」を表示する
user.assignments.each do |assign|
  puts "#{assign.org_unit.name} で #{assign.role} を担当中"
end
```

---

## 🏭 製造業アプリ (`mfg_core`) での応用

`mfg_core` では、この `has_many :through` の仕組みを **「権限の動的解決」** に応用しています。

1.  `User` は複数の `assignments` (配属) を持つ。
2.  各 `assignment` は `OrgUnit` (組織) に紐付いている。
3.  `OrgUnit` は `org_unit_permissions` (権限) を持っている。

この連鎖を `through` メソッドで辿ることで、**「今このユーザーが、所属部署の合計としてどんな権限を持っているか？」** を一行のコードで導き出せるようになります。これが、複雑な人事異動に負けない堅牢な設計の核（Business Core）となっています。
