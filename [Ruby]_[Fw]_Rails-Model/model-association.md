# 🔗 [Ruby]_[Fw]_Rails-Model (テーブル同士を結びつける作法)

Rails におけるテーブル間の「関連付け (Association)」を、正しく、かつ効率的に設定するためのガイドです。

---

## 🌟 概要: 関連付けは「2つのレイヤー」で考える

データベース（保存）とモデル（Rubyプログラム）の両方で設定が必要です。

| レイヤー | 設定場所 | 役割 | 記述内容 |
| :--- | :--- | :--- | :--- |
| **データベース層** | 子（例：Micropost） | データの整合性を守る | `t.references :user, foreign_key: true` |
| **モデル層 (Ruby)** | **双方** | 便利なメソッドを提供する | `has_many`, `belongs_to` |

---

## 🛠️ DB層：`t.references` の威力

単なる `integer` カラムを作るのではなく、**`references`** を使うことで Rails の自動化の恩恵を最大化できます。

-  **カラム作成**: `user_id` という名前のカラムを自動生成。
-  **インデックス**: 検索を高速化するインデックスを自動付与。
-  **外部キー制約**: `foreign_key: true` を添える。これにより、「存在しないユーザーに投稿を紐づける」というミスを DB レベル（物理的）で防ぎます。

---

## 🛠️ モデル層：双方向の設定

親モデル（1）と子モデル（多）の両方に記述することで、直感的な Ruby メソッドが使えるようになります。

### 1. 子モデル (Micropost)
```ruby
class Micropost < ApplicationRecord
  # 私は User に属しています
  belongs_to :user
end
```

### 2. 親モデル (User)
```ruby
class User < ApplicationRecord
  # 私は複数の Micropost を持っています
  has_many :microposts
end
```

> **なぜ has_many が必要なのか？**
> これがないと、`user.microposts` と打った時に `NoMethodError` になります。Rails が「User から Micropost を辿る方法」を知らないからです。

---

## 💡 知っておくべき設計の鉄則

**「親は子のことを知らない」**

データベース上の `users` テーブルには、子の情報を一切持つ必要はありません。
「誰のデータなのか」という情報は、常に **「子テーブルの ◯◯_id」** だけが持っています。この非対称性を理解することが、綺麗な DB 設計への第一歩です。

---

## 📚 参考資料 (Resources)
- **Rails Guides**: [Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
