# 📜 [Ruby]_[Tool]_Rails-DBML-Export (Railsの設計図をクリーンに自動生成)

Rails (SQLite3) のテーブル構造から、ER図の元になる **DBMLファイル** を「PCを一切汚さず」に、自動で生成・整理するための Rake タスクの記録です。

---

## 🌟 全体の流れ (Fast Workflow)

特別なツールのインストールは不要です。以下の 3 ステップだけで最新の設計図が手に入ります。

1.  **DBの準備**: `rails db:migrate` でテーブルを確定させる。（材料となる DB が必要です）
2.  **台本の設置**: `lib/tasks/dbml.rake` に自動生成用のスクリプトを保存する。
3.  **実行**: **`bundle exec rake dbml:export`** を打つ。
4.  **確認**: `db/schema.dbml` が出来上がる。

---

## ✅ 事前準備 (Prerequisites)
DBML 作成ツール自体は不要ですが、そのツールを動かす**エンジンとしての Node.js** が必須です。

- **Rails プロジェクト**: 既に `rails new` して開発中のもの。
- **Node.js**: ツールを一時的に借りてくる（npx）ために不可欠です。
  - ※ Node.js が入っていないと `npm` や `npx` コマンドが一切使えないため、必ず導入しておいてください。
  - 詳細は [Node.js 環境構築ガイド (setup-nodejs.md)](../[JS]_[Run]_Nodejs/setup-nodejs.md) を参照。

---

## 💻 検証環境 (Environment)
- **OS**: macOS Sequoia 15.4.1 (Apple Silicon / M2)
- **Ruby**: 3.x (Rails 8.x)
- **Node.js**: v20.11.1
- **Tool**: @dbml/cli (npx経由で使用)

---

## 🛤 PCを汚さないためのポリシー (npx の活用)

### 1. 今回の作業で使うツールの役割

| ツール名 | 役割 / イメージ | 備考 |
| :--- | :--- | :--- |
| **Node.js** | **「エンジン本体」** | **必須。** ツールを動かすために必要。 |
| **nodenv** | **「管理ボックス」** | **Node.jsのバージョン**（20系など）を切り替えます。（rbenv の Node版） |
| **npm** | **「道具箱」** | ツールを管理します。Node.jsを入れると自動で付いてくる。 |
| **npx** | **「道具を直接使う機能」** | 今回主役となる「一時的に借りてくる」ための機能。 |

### 2. ツールはどこに保存されるのか？
`npx` で実行されたツールは、PC全体にインストールされるのではなく、**一時的なキャッシュ** として保存されます。

- **場所 (macOS)**: `~/.npm/_npx/`
- **いつ消えるのか？**: 数日間使われないと OS 側で自動的に掃除されます。
- **手動で消したい時**: `npm cache clean --force`

---

## 🛠️ Step-by-Step ガイド (詳細手順)

### 【Step 1】 データベースのテーブル作成
通常通り Rails で `bin/rails db:migrate` を実行して、実際のデータベース（SQLite3等）を最新の状態にしておきます。
※材料となるテーブルが存在しないと、設計図は作れません。

### 【Step 2】 使用中のデータベースを確認する
Rakeタスク（台本）を正しく動かすために、今のプロジェクトが何のデータベースを使っているかを確認します。

- **確認ファイル**: `config/database.yml`
- **確認コマンド**:
  ```bash
  cat config/database.yml
  ```
- **読み取り方**: `adapter:` の項目を見ます。
  - `adapter: sqlite3` であれば、今回の Rake タスクがそのまま使えます。

### 【Step 3】 自動生成用「Rakeタスク」の作成
プロジェクト直下の `lib/tasks/` フォルダに、**`dbml.rake`** という名前でファイルを作成します。

- **作成場所**: `~/your_app/lib/tasks/dbml.rake`
- **台本の中身**: [こちら (example_dbml.rake)](./example_dbml.rake) の内容をコピーして保存。

### 【Step 4】 コマンドの実行
プロジェクトフォルダ内で以下のコマンドを打ちます。

```bash
bundle exec rake dbml:export
```

### 【Step 5】 出来上がったファイルの確認
`db/` フォルダに、新しく **`schema.dbml`** というファイルが生成されていれば成功です！
※テーブル構成を変更した後は、再度このコマンドを打てば `db/schema.dbml` が更新されます。

---

## 🚀 自動化の「舞台裏（マジック）」の解説
Rake タスクが裏側で「一瞬だけ材料（SQL）を作り、加工して、最後にゴミを片付ける」処理を行っています。

1.  **「材料（SQL）の一時生成」**:
    `sqlite3 ... .schema` コマンドで、現在のデータベースから一瞬だけ `tmp/schema_dump.sql` を作ります。
2.  **「調理（DBMLへの変換）」**:
    `npx` を使って、その SQL ファイルを DBML という綺麗な形式に変換します。

    > **なぜ「postgres」という言葉が出てくるのか？**
    > `sql2dbml` というツールの内部では「どの種類の言語(方言)で変換するか」を指す際、PostgreSQL（ポストグレス）を `--postgres` というオプションで指定します。これはファイル名ではなく、ツールの「方言指定のマニュアル名」のようなものです。

3.  **「汚いテーブルの削除」**:
    Railsが管理用に使っている `schema_migrations` などのテーブル情報を、プログラムが直接削り取ります。
4.  **「後片付け」**:
    最初に作った一時的な SQL ファイルは、不要になったので自動で削除（`File.delete`）します。

---

## 📖 参考：手動でコマンドを打つ時のパターン別ガイド
Rakeタスクを使わず、手動で一回だけ変換したい時のためのシナリオ別のコマンド例です。

### 1. 基本：材料と出来上がりを自分で指定する
```bash
# 材料(SQL): schema.sql
# 出力(DBML): schema.dbml
npx -y -p @dbml/cli sql2dbml schema.sql --out schema.dbml
```

### 2. シナリオ別：材料の種類を教える
| 状況 | コマンドの書き方例 | 解説 |
| :--- | :--- | :--- |
| **標準的な変換** | `npx -y -p @dbml/cli sql2dbml schema.sql --out [ファイル名].dbml` | SQLite等のシンプルなSQLならこれ。 |
| **PostgreSQL用** | `npx -y -p @dbml/cli sql2dbml dump.sql --postgres --out [ファイル名].dbml` | `--postgres`: 材料が PostgreSQL 方言であると教えています。 |
| **MySQL用** | `npx -y -p @dbml/cli sql2dbml mysqldump.sql --mysql --out [ファイル名].dbml` | `--mysql`: 材料が MySQL 方言であると教えています。 |

#### オプションの意味（再確認）
- **`sql2dbml`**: 「SQL を DBML に変換して！」という具体的な命令。
- **`--out [ファイル名]`**: 「この名前で保存して！」という仕上げの指示。
- **`--postgres / --mysql`**: 材料の「方言（書き方の規則）」をツールに教えるヒント。

> [!TIP]
> **出力ファイル名（.dbml）の命名のコツ**
> 基本的には自由ですが、プロジェクトの目的に合わせて以下のような名前がよく使われます。
> - **`schema.dbml`**: 最も一般的。Rails の `schema.rb` と対になる名前として分かりやすい。
> - **`design.dbml`**: 設計案、という意味合いで使いたい時に。
> - **`erd.dbml`**: 図解用のファイルであることを強調したい時に。

---

## 💡 Q&A：なぜ`bundle exec rake dbml:export` というコマンドで特定のファイルが動くのか？

### 1. `bundle exec rake` とは？
- **`bundle exec`**: 「このプロジェクト専用のライブラリ（Gem）を使って実行せよ」という宣言。
- **`rake`**: **R**uby M**ake**の略。伝統的なツール `make` の精神を受け継いだ、**Ruby 言語全般** で使える「自動化ツール」です。
> **名前の由来：熊手（Rake）**
> 英語の `rake` には「熊手（くまで）」という意味があります。「面倒なタスクを一気にかき集めて片付ける」イメージです。

### 2. Rails の「自動ロード」マジック
Rails は `lib/tasks/` 内の `.rake` ファイルをすべて読み込み、中で定義された `namespace` や `task` の名前をコマンド一覧へ自動で登録します。
- **`namespace :dbml`**: コマンドの「前半分（グループ）」
- **`task export: :environment`**: コマンドの「後半分（作業）」。`:environment` は Rails の設定（DBの場所など）を読み込むおまじない。

---

## 📚 参考資料 (Resources)
- **公式 CLI ドキュメント**: [DBML - Command Line Interface](https://www.dbml.org/cli/)
- **公式サービス**: [dbdocs.io](https://dbdocs.io/)
