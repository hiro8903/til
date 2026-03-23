# ~/environment/new_app/lib/tasks/dbml.rake
# SQLite等のシンプルなSQLファイルであれば、以下のタスクでDBMLファイルを生成できる

namespace :dbml do
  desc "DBML生成後に、管理用テーブルの定義を直接ファイルから削除する"
  task export: :environment do
    project_root = Rails.root
    sql_file     = project_root.join("tmp", "schema_dump.sql")
    dbml_file    = project_root.join("db", "schema.dbml")

    # 1. SQLをダンプ
    db_config = Rails.configuration.database_configuration["development"]
    db_path   = project_root.join(db_config["database"])
    puts "Dumping schema..."
    system("sqlite3 #{db_path} .schema > #{sql_file}")

    # 2. SQLite固有の修正（これは変換エラー防止に必要）
    content = File.read(sql_file)
    content.gsub!(/AUTOINCREMENT/i, "")
    content.gsub!(/CREATE TABLE sqlite_sequence\(.*?\);/m, "")
    File.open(sql_file, "w") { |f| f.write(content) }

    # 3. SQL -> DBML 変換
    puts "Converting to DBML..."
    system("npx -y -p @dbml/cli sql2dbml #{sql_file} > #{dbml_file}")

    # 4. 【ここが重要】生成された DBML ファイルを直接掃除する
    if File.exist?(dbml_file)
      dbml_content = File.read(dbml_file)

      # DBMLの Table "名前" { ... } ブロックを丸ごと削除する正規表現
      # schema_migrations と ar_internal_metadata を狙い撃ち
      dbml_content.gsub!(/Table\s+"schema_migrations"\s+\{.*?\}/m, "")
      dbml_content.gsub!(/Table\s+"ar_internal_metadata"\s+\{.*?\}/m, "")

      # 連続した空行を整理して保存
      File.open(dbml_file, "w") { |f| f.write(dbml_content.strip + "\n") }

      puts "✨ Successfully cleaned and generated: #{dbml_file}"
      File.delete(sql_file) if File.exist?(sql_file)
    else
      puts "❌ Error: DBML file not found."
    end
  end
end
