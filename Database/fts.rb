namespace :fts do
  LANGUAGES.each do |lang|
    task lang.to_sym => :close_database do
      sqlite_cli "DROP TABLE IF EXISTS fts_#{lang}"
      # SQLite's default tokenizer still does not support CJK text, e.g. searching for 大戰 will not find 星際大戰.
      # -> For these languages, only delete the fts tables (if they exist), but don't recreate them.
      if %w(en de fr ru).include? lang
        sqlite_cli "CREATE VIRTUAL TABLE fts_#{lang} USING fts5(content = \"movies\", #{lang}, tokenize = 'porter')"
        sqlite_cli "INSERT INTO fts_#{lang}(fts_#{lang}) VALUES('rebuild')"
      end
    end
  end
  
  desc "Creates full-text search indices for all languages"
  task :all => LANGUAGES.map(&:to_sym)
end
