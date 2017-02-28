file 'extract_movies.bin' => 'extract_movies.cpp' do
  sh 'g++ extract_movies.cpp -std=gnu++11 -O3 -o extract_movies.bin'
end

desc "Extracts all English pages about movies into ./enwiki as plain text files"
task :extract_english_movies => 'extract_movies.bin' do
  rm_rf 'enwiki'
  mkdir_p 'enwiki'
  # TODO: curl -s <filename> | bzcat | ./extract_movies ...
  # TODO +caffeinate
  sh "bzcat #{ENWIKI_FILE} | ./extract_movies.bin enwiki"
end

desc "Extracts all Chinese pages about movies into ./zhwiki as plain text files"
task :extract_chinese_movies => 'extract_movies.bin' do
  rm_rf 'zhwiki'
  mkdir_p 'zhwiki'
  # TODO: curl -s <filename> | bzcat | ./extract_movies ...
  # TODO +caffeinate
  sh "cat '#{ZHWIKI_FILE}' | ./extract_movies.bin zhwiki"
end
