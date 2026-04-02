# [Ruby] [Fw] Rails: メソッドの出所（Ruby / Rails / Gem）を見極める技術 (-reference)

Rails のソースコードを読んでいる際、特定のメソッドが「Ruby の基本機能なのか」「Rails の標準機能なのか」「外部 Gem の機能なのか」を即座に判断し、特定するための手法をまとめる。

---

## 💡 Context (背景)

論理削除用 Gem `discard` を導入した際、`User.discarded` や `@user.discard!` といったメソッドが登場した。これらが Rails 本体の機能ではなく、後から追加された Gem 特有の機能であることをどうやって見分け、特定するかを整理した。

---

## 🔍 メソッドの出所を見分ける 3 つのステップ

### 1. 「呪文（マクロ）」の記述場所を確認する
Rails や Gem の機能の多くは、クラスの冒頭に書かれた **「たった1行の呪文」** によって、裏側で大量のメソッドを自動生成（メタプログラミング）している。

#### 定番の呪文と、そこから生まれるメソッド例：

| 記述場所 | 呪文（マクロ） | 生成される主なメソッド | 出所 |
| :--- | :--- | :--- | :--- |
| **Model** | `include Discard::Model` | `discarded`, `kept`, `discard!` | **Gem** |
| **Model** | `has_secure_password` | `authenticate`, `password` | **Rails** |
| **Model** | `has_many :orders` | `user.orders.all`, `user.orders.create` | **Rails** |
| **Model** | `belongs_to :facility` | `user.facility` | **Rails** |
| **Model** | `attr_accessor :token` | `token` (読み), `token=` (書き) | **Ruby** |
| **Routes** | `root "home#index"` | `root_path`, `root_url` | **Rails** |

### 2. Rails Console で「ソースの場所」を直接尋ねる
```ruby
# bin/rails c で実行
User.method(:discarded).source_location
```

#### ⚠️ 注意点：メタプログラミングによる動的定義
`source_location` が Rails 本体の `named.rb` などを指すことがある。これは Rails の `scope` などの **「メソッド生成ツール（型）」** を通じてメソッドが作られたことを意味する。
この場合、ファイル内にメソッド名（`discarded` 等）は直接書かれていない。

### 3. ソースコードの「実体（生地）」を読みに行く
生成ツールを指してしまった場合は、Gem の中身を直接覗いて「命令の引数」として渡されているロジックを探す。

- **GitHub で探す**: 公式リポジトリの `lib/` フォルダ以下を確認する。
- **ローカルで探す**: ターミナルで `bundle open [gem名]` を実行する。
  - ※ 実行にはエディタの設定が必要（例: `export EDITOR=code`）。
  - 設定が困難な場合は **`bundle info [gem名]`** でパスを確認し、直接ファイルを開く。

---

## 💡 コラム：クッキーの「型」と「生地」の関係

Rails のメタプログラミングは、よく **「型（Template）」** と **「生地（Logic）」** に例えられる。

- **型（Rails本体）**: `named.rb` にある `scope` メソッド。メソッドを生成する「抜き型」。
- **生地（Gem側）**: `where.not(discarded_at: nil)` という「ロジックの塊」。

Ruby が `source_location` として教えてくれるのは、**「実際に型抜き（define_method）が行われた場所（＝型のある場所）」** である。本当のロジック（生地）を知るには、その型に生地を流し込んでいる場所（Gemのソース）を見る必要がある。

---

## 🔗 Official References (一次情報)

- **Ruby Reference - Method#source_location**: [公式解説](https://docs.ruby-lang.org/ja/latest/method/Method/i/source_location.html)
- **Bundler Guides - bundle open**: [CLI Reference](https://bundler.io/v2.4/man/bundle-open.1.html)
- **Rails Guides - Active Record Associations**: [作成されるメソッドの詳細](https://guides.rubyonrails.org/association_basics.html#methods-added-by-belongs-to)
