desc "Imports translations from the langlinks dump"
task :import_translations do
  sh "echo 'drop database langlinks; create database langlinks' | mysql -uroot"
  sh "curl -s https://dumps.wikimedia.org/enwiki/#{EN_DATE}/enwiki-#{EN_DATE}-langlinks.sql.gz | gzcat | mysql -uroot -D langlinks"  
end

desc "Adds translations from the langlinks table to Movies.db"
task :add_translations => :database do
  mysql = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "langlinks")
  
  languages_to_query = LANGUAGES - CHINESE_VARIANTS
  $db.execute("SELECT id, en, wikipedia FROM movies") do |id, en, wikipedia_link|
    languages = {}
    
    mysql.query("SELECT ll_lang, ll_title FROM langlinks WHERE ll_from = #{id}").each do |link|
      if languages_to_query.include? link['ll_lang']
        title = link['ll_title'].force_encoding('UTF-8')
        
        if title =~ / \((Roman|Manga|Comic|Musikvideo|Buch|小說|漫？)\)$/
          languages = {}
          break
        end
        
        title = title.gsub /\s*\([^()]*(musical|anime|фильм|film|映画|影|片)\)/i, ''
        # Strip years (some Wikipedia languages are full of them)
        title = title.gsub /\s*\([^()]*[0-9]{4}\)$/, ''
        
        # Censor the French translation "Fucking Åmål"...
        title = "…ing Åmål" if title == "Fucking Åmål"
        
        languages[link['ll_lang']] = title unless almost_equal(title, en)
      end
    end
    
    # No new languages? Delete this row
    if languages.empty?
      puts "Deleting: No translations found for #{wikipedia_link}"
      $db.execute "DELETE FROM movies WHERE id = #{id}"
    else
      languages.each do |language, title|
        $db.execute "UPDATE movies SET #{language} = ? WHERE id = ?", title, id
      end
    end
  end
end
