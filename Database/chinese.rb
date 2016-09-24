TAGS_PER_VARIANT = {
  'cn' => %w(cn_name 中國大陸片名 中国大陆片名),
  'hk' => %w(hk_name 香港片名),
  'tw' => %w(tw_name 臺灣片名 台灣片名 台湾片名),
}

desc "Imports local Chinese titles from the text files in ./zhwiki into Movies.db"
task :add_chinese_variants => :database do
  Dir['zhwiki/*.txt'].each do |filename|
    File.open(filename, 'r') do |page|
      zh = page.gets.chomp
      
      while line = page.gets do
        CHINESE_VARIANTS.each do |lang|
          TAGS_PER_VARIANT[lang].each do |tag|
            if line =~ /#{tag}\s*\=\s([^\n]+)/
              name = $1.dup

              name.gsub! "'''", ''
              name.gsub! "''", ''
              name.gsub! /\{\{lang[|-].+\|+(.*)\}\}/i, '\1'
              name.gsub! /<span.*>(.*)<\/span>/i, '\1'
              name.gsub! /\-\{(.*)\}\-/, '\1'
              name.gsub! /\[\[(.*)\]\]/, '\1'
              name.gsub! /'(.*)'/, '\1'
              name.gsub! /\}-(.*)-\{/, '\1'
              # this regexp also catches </br>, see zh:太陽之
              name.gsub! /&lt;\/?\s*br\s\/?&gt;/i, ' '

              name.gsub! /&lt;.*&gt;/i, ''
              name.gsub! /&lt;.*>/i, ''

              name.gsub! '&quot;', '"'
              name.gsub! '&amp;', '&'
              name.gsub! '&lt;', '<'
              name.gsub! '&gt;', '>'

              # For articles where everything is on one line; see zh:金枝玉葉
              # TODO - but then we would only catch the first title?!
              name.gsub! /\|.*$/, ''
              # For tw_name=FOO{{notetag|前譯:BAR}}
              name.gsub! /\{\{.*$/, ''

              name.gsub! /\s\s/, ' '
              name.gsub! /^\s+/, ''
              name.gsub! /\s*\}*$/, ''

              next if name =~ /^\{\{fact/ # TODO what is going on there?

              # For entries with empty tw_name= etc., see zh:不沉的太陽 or tw 海巡尖兵
              next if name.gsub(/-|–|—/, '') == ''

              next if almost_equal(zh, name)

              $db.execute "UPDATE movies SET #{lang} = ? WHERE zh = ?", name, zh
            end
          end
        end
      end
    end
  end
end
