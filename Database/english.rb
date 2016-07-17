require 'erb'

desc "Recreates Movies.db with the information from the text files in ./enwiki"
task :create_english_database => [:delete_database, :database] do
  columns = (LANGUAGES + LINKS).map { |lang| "#{lang} TEXT" }.join(', ')
  $db.execute "CREATE TABLE movies (id INTEGER PRIMARY KEY, year INTEGER, #{columns}, suggestion INTEGER);"
  
  Dir['enwiki/*.txt'].each do |filename|
    catch :not_a_movie do
      page_id = File.basename(filename).to_i
      
      languages = {}
      imdb_link, wikipedia_link, year = nil, nil, nil
      
      File.open(filename, 'r') do |page|
        en = page.gets.chomp.gsub('&quot;', '"').gsub('&amp;', '&')
        
        wikipedia_link = "https://en.wikipedia.org/wiki/#{ERB::Util.url_encode en}"
        
        if en =~ /([12]...)( film)?\)$/i
          year = $1.to_i
        end
        
        en.gsub! /\s*\(.*(film|movie|anime|short)\)$/i, ''
        en.gsub! /\s*\([12][0-9]{3}\)$/i, ''
        
        # Careful, Americans are going to use this app
        if en =~ /(Fuck|fuck|Porn|porn|.XXX|XXX.|Xxx|xXx|Sex$| sex$|Sex[^e][^s])/
          puts "Censoring #{wikipedia_link}"
          throw :not_a_movie
        end
        
        # Skip lists, print media etc.
        if en =~ /^List of/i or en =~ /(comics|cartoons|novel(la)?|book|story|show|drama|opera|video|series|serial|program(me)?|TV special|episode|director|actor|character|play|song|album|soundtrack|franchise|manga|franchise|live|musical|game|pinball|studio|company|golfer|Oni Press)\)$/i
          puts "Skipping #{wikipedia_link}"
          throw :not_a_movie
        end
        
        languages['en'] = en
        
        while line = page.gets do
          if line =~ /\{\{imdb[^0-9}]+([0-9]{6,})[^0-9][^}]*\}/i
            imdb_link = "https://www.imdb.com/title/tt#{$1}/"
          end
          if line =~ /\{\{Film date\|([0-9]{4})\|[^}]+\}\}/i
            year = $1.to_i
          end
        end

        if en =~ /Award/ and en != "The Darwin Awards"
          puts "Skipping #{wikipedia_link} because it is an Awards page"
          throw :not_a_movie
        end
      end
      
      language_columns = LANGUAGES.map do |lang|
        if languages[lang]
          "'#{languages[lang].gsub("'", "''")}'"
        else
          'NULL'
        end
      end.join(', ')
      
      imdb_column = imdb_link ? "'#{imdb_link.gsub("'", "''")}'" : 'NULL'
      wikipedia_column = "'#{wikipedia_link.gsub("'", "''")}'"
      year_column = year || "NULL"
      
      $db.execute "INSERT INTO movies VALUES (#{page_id}, #{year_column}, #{language_columns},
                                              #{wikipedia_column}, #{imdb_column}, NULL)"
    end
  end
end
