LANGUAGE_TO_TOKENIZER = {
  'en' => 'porter',
  'de' => 'unicode61',
  'ru' => 'unicode61',
  'fr' => 'unicode61',
}

namespace :fts do
  LANGUAGES.each do |lang|
    task lang.to_sym => :close_database do
      tokenizer = LANGUAGE_TO_TOKENIZER[lang] or raise "FTS not available for: #{lang}"
      
      sqlite_cli "DROP TABLE IF EXISTS fts_#{lang}; "+
                 "CREATE VIRTUAL TABLE fts_#{lang} " +
                 "USING fts4(content=\"movies\", #{lang}, tokenize=#{tokenizer}); " +
                 "INSERT INTO fts_#{lang}(fts_#{lang}) VALUES('rebuild')"
    end
  end
  
  desc "Creates full-text search indices for all languages"
  task :all => LANGUAGE_TO_TOKENIZER.keys.map(&:to_sym)
end
