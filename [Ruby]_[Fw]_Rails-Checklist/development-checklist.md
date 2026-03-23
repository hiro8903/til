# 📋 Rails 開発セルフチェックリスト

Rails で機能を追加・修正した際、「これを忘れると後で困る！」というポイントを凝縮したチェックリストです。

---

## 🛠️ テーブル作成・修正 (Migration)

| 状態 | チェック項目 | 詳細ガイド |
| :--- | :--- | :--- |
| **設計時** | `t.integer` ではなく `t.references` を使ったか？ | [関連付けの基本](../[Ruby]_[Fw]_Rails-Model/model-association.md) |
| **設計時** | 外部キー制約 (`foreign_key: true`) は確実に付けたか？ | [関連付けの基本](../[Ruby]_[Fw]_Rails-Model/model-association.md) |
| **共有前** | ロールバックができるか一回試したか？ (`db:rollback`) | [マイグレーション運用作法](../[Ruby]_[Fw]_Rails-Migration/migration-workflow.md) |
| **共有前** | クラス名とファイル名は一致しているか？ | [マイグレーション運用作法](../[Ruby]_[Fw]_Rails-Migration/migration-workflow.md) |
| **共有後** | 共有済みのファイルを直接編集していないか？ | [マイグレーション運用作法](../[Ruby]_[Fw]_Rails-Migration/migration-workflow.md) |

---

## 🏗️ モデルの関連付け (Association)

| 状態 | チェック項目 | 詳細ガイド |
| :--- | :--- | :--- |
| **実装時** | 子（例：Micropost）に `belongs_to` は書いたか？ | [関連付けの基本](../[Ruby]_[Fw]_Rails-Model/model-association.md) |
| **実装時** | 親（例：User）に `has_many` は書いたか？ | [関連付けの基本](../[Ruby]_[Fw]_Rails-Model/model-association.md) |
| **実装時** | 親子それぞれのメソッド（`user.microposts`など）が動くか？ | [関連付けの基本](../[Ruby]_[Fw]_Rails-Model/model-association.md) |

---

## 📊 設計図の自動更新 (DBML)

| 状態 | チェック項目 | 詳細ガイド |
| :--- | :--- | :--- |
| **更新時** | テーブル構造を変えたら `dbml:export` を実行したか？ | [DBML自動生成ガイド](../[Ruby]_[Tool]_DBML-Automation/rails-dbml-export.md) |

---

> [!TIP]
> **なぜチェックリストが必要なのか？**
> 「自分はミスをする」という前提でチェックリストを活用します。この表にある項目を埋めるだけで、将来のバグや環境不一致の地獄を未然に防ぐことができます。
