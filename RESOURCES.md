# 🔗 公式リファレンス & 逆引きインデックス (Resources & Index)

このファイルは、各 TIL ドキュメントの核となる「一次情報（公式ドキュメント）」と、それに対応する自作メモを素早く探すためのインデックスです。
ドキュメントの目的に応じて、**[Why]**(理由・比較)、**[How]**(手順・ガイド)、**[What]**(仕様・解説) のタグを付与しています。

---

### 🏢 [Cmn] Common (共通事項)
*   **Git: `git add .` vs `git add -A` の歴史**
    *   🔗 [git-add](https://git-scm.com/docs/git-add#Documentation/git-add.txt--A) / [git-commit](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt--a)
    *   📝 **[Why]** [歴史的経緯](./%5BCmn%5D_%5BTool%5D_Git/git-add-history-and-differences.md)
*   **Git: 空ディレクトリの管理**
    *   🔗 [Git FAQ (Empty Directories)](https://git.wiki.kernel.org/index.php/Git_FAQ#Can_I_add_empty_directories.3F)
    *   📝 **[What/How]** [.gitkeep (.keep) の仕様と回避策](./%5BCmn%5D_%5BTool%5D_Git/git-ignore-empty-dir-keep.md)
*   **HTML: `autocomplete` 属性の仕様**
    *   🔗 [HTML Living Standard: Autofill](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofill)
    *   📝 **[What]** [属性の役割と注意点](./%5BCmn%5D_%5BLang%5D_HTML/autocomplete-attribute.md)

### 💎 [Ruby] Ruby on Rails
*   **Rails 基礎 & Tips**
    *   🔗 [Rails Guides: I18n](https://guides.rubyonrails.org/i18n.html) / [ja.yml (master)](https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/ja.yml)
    *   📝 **[How]** [i18n 日本語化の実践ガイド](./%5BRuby%5D_%5BFw%5D_Rails/rails-i18n-localization-guide.md)
    *   🔗 [ActiveRecord::Enum API](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)
    *   📝 **[What]** [Enum の基本と魔法](./%5BRuby%5D_%5BFw%5D_Rails/enum-basics-and-usage.md) / **[Why]** [Enum vs Boolean の比較](./%5BRuby%5D_%5BFw%5D_Rails/role-management-enum-vs-boolean.md)
    *   🔗 [ActionView::FormHelper](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html)
    *   📝 **[What]** [フォームヘルパーとHTML属性の解剖](./%5BRuby%5D_%5BFw%5D_Rails/form-helpers-and-attributes.md)
*   **データベース・設計**
    *   🔗 [Rails Guides: Migrations](https://edgeguides.rubyonrails.org/active_record_migrations.html#creating-a-new-table)
    *   📝 **[Why]** [マイグレーション設計戦略](./%5BRuby%5D_%5BFw%5D_Rails/migration-timing-strategy.md) / **[How]** [運用の作法](./%5BRuby%5D_%5BFw%5D_Rails-Migration/migration-workflow.md)
    *   🔗 [Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
    *   📝 **[What]** [テーブル関連付けの概念](./%5BRuby%5D_%5BFw%5D_Rails-Model/model-association.md)
*   **認証基盤 (Authentication)**
    *   🔗 [Rails 8.0 Release Note](https://rubyonrails.org/2024/11/7/rails-8-no-paas-required) / [Security Guide](https://guides.rubyonrails.org/v8.0/security.html)
    *   📝 **[Why]** [Rails 8 公式認証 vs Devise の機能比較](./%5BRuby%5D_%5BFw%5D_Rails-Authentication/devise-vs-rails8-auth.md)
*   **品質管理 & 開発フロー**
    *   🔗 [RuboCop: Autocorrect](https://docs.rubocop.org/rubocop/usage/autocorrect.html)
    *   📝 **[How]** [RuboCop 自動修正ガイド](./%5BRuby%5D_%5BLib-Gem%5D_RuboCop/rubocop-autocorrect-guide.md)
    *   📝 **[How/Checklist]** [Rails 開発チェックリスト](./%5BRuby%5D_%5BFw%5D_Rails-Checklist/development-checklist.md)

### 🚀 [JS] JavaScript & Tools
*   **Node.js & 環境構築**
    *   📝 **[How]** [nodenv による Node.js セットアップ](./%5BJS%5D_%5BRun%5D_Nodejs/setup-nodejs.md)
*   **設計図の自動化 (DBML)**
    *   🔗 [DBML CLI Document](https://www.dbml.org/cli/) / [dbdocs.io](https://dbdocs.io/)
    *   📝 **[How]** [Rails DBML 自動エクスポート](./%5BRuby%5D_%5BTool%5D_DBML-Automation/rails-dbml-export.md) / **[How]** [dbdocs 運用マニュアル](./%5BJS%5D_%5BLib-Pkg%5D_dbdocs/guide-dbdocs.md)
