# 📜 [Ruby]_[Fw]_Rails-Authentication (Devise vs Rails 8 公式認証の機能比較)

Rails 8 以降で認証機能を実装する際の、主要なライブラリ「**Devise (歴史と実績)**」と、新機能である「**Rails 8 公式認証（軽量・最新）**」を、よく使われる機能で比較・分析しました。

---

## 📊 機能カテゴリ別の比較表

| 機能カテゴリ | Devise (Gem) | Rails 8 公式認証 (Generator) | 自前実装 (has_secure_password) | 概要 / コメント |
| :--- | :--- | :--- | :--- | :--- |
| **暗号化** | ✅ 標準 | ✅ 標準 | ✅ 標準 | 全て `bcrypt` を使用する安全な仕組み |
| **画面・Flow** | ✅ 全て自動生成 | ✅ 基本のみ生成 | ❌ 要実装 | Rails 8 は `SessionsController` 等を生成 |
| **パスワード忘れ** | ✅ 標準搭載 | ❌ 要実装 | ❌ 要実装 | Devise はメール送信・トークン発行まで自動 |
| **アカウントロック** | ✅ 設定のみ | ❌ 要実装 | ❌ 要実装 | ログイン失敗◯回で拒否。商用では必須級 |
| **セッション管理** | ✅ 高度 (複数端末等) | ✅ 基本的 | ❌ 要実装 | Rails 8 は `Session` モデルで管理 |
| **メール確認** | ✅ 標準搭載 | ❌ 要実装 | ❌ 要実装 | サインアップ後の有効化確認 |
| **SNSログイン** | ✅ 容易 (`omniauth`) | ⚠️ 手動組み込み | ⚠️ 手動組み込み | ライブラリはあるが、Deviseの方が楽 |
| **多要素認証 (2FA)** | ✅ 容易 (`devise-2FA`) | ⚠️ 手動組み込み | ⚠️ 手動組み込み | 業務システムでの需要が高い機能 |
| **カスタマイズ性** | ⚠️ 中 (ルールに沿う) | ✅ 高 (ただのコード) | ✅ 最高 | Devise は「内部ブラックボックス化」しやすい |
| **学習コスト** | ⚠️ 低〜中 | ✅ 中〜高 (コード読解) | ❌ 高 | Devise は独自の規約を覚える必要がある |

---

## 🛠️ どちらを選ぶべきか？ (Decision Matrix)

### 1. Devise (Gem) が向いているケース
- **効率・実績重視**: 「パスワードリセット」「アカウントロック」といった**業務システムとして当たり前の機能**を、プロが検証済みのコードで一瞬で終わらせたい場合。
- ユーザーに直接メールを登録・変更させる、一般的なWebサービス（B2C/C2C）に向いている。

### 2. Rails 8 公式認証 (Generator) が向いているケース
- **シンプルさ・理解重視**: 自分でコードを一行ずつ書き、どうやってセッションが作られ、ログインが実現されるのかを「完全に制御したい」場合。
- **特殊な識別子の使用**: 「メールアドレス」ではなく、現場で使い慣れた **「ユーザーコード」** や「社員番号」などで認証させたい、または管理者のみがパスワードを付与する等の「独自の運用フロー（B2B/社内システム）」がある場合に、カスタマイズの自由度が威力を発揮する。

---

## 💡 Rails 8 公式認証の背景（"No PaaS Required"）

- **思想（No PaaS Required）**: 「認証は基本機能（Basics）であり、外部Gemや有償サービスに頼らず自分たちで制御すべき」というDHH（Rails創始者）の強い思想が反映されている。
- **仕様（Bespoke）**: サインアップ（新規登録）画面は各アプリケーションの「仕立て（Bespoke／あつらえ）」が最も出る部分であるため、あえて自動生成のスコープから外し、開発者が手動で実装する設計になっている。
- **既存技術の統合**: `has_secure_password`, `generates_token_for`, `authenticate_by` といった、Rails 7 以降から蓄積されてきた個別の機能を、一つの「認証基盤」として繋ぎ合わせるためのジェネレーターである。

---

## 🔗 公式リソース (Official Resources)

- **Rails 8 公式認証 (Action Pack / Railties)**
  - [Rails 8.0 Release Note: No PaaS Required](https://rubyonrails.org/2024/11/7/rails-8-no-paas-required) - 公式リリースニュース
  - [Securing Rails Applications (Rails Guides v8.0)](https://guides.rubyonrails.org/v8.0/security.html) - セキュリティ・認証の基本ガイド
  - [Rails Authentication Generator Source Code](https://github.com/rails/rails/tree/main/railties/lib/rails/generators/rails/authentication) - ジェネレーターのソースコード定義

- **Devise**
  - [Devise Wiki (GitHub)](https://github.com/heartcombo/devise/wiki) - 総合ガイド
  - [How-To: Use username instead of email](https://github.com/heartcombo/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address) - Email以外でログインさせる際の手順

---

## 📝 振り返り
Rails 8 の "No PaaS Required" 時代において、複雑な Gem に頼らずとも「自分たちでコードを掌握して認証を作る」という選択肢が標準提供された。
「独自要件が明確な認証（User Code 認証）」を構築する際、この公式ジェネレーターは有用そうである。
「有名だから Devise を使う」という思考停止に陥らず、ビジネス要件から技術選定を行うことが、メンテナンス性の高いアーキテクチャへの第一歩である。
