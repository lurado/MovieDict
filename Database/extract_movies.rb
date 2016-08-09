file 'extract_movies.c' => 'extract_movies.rl' do
  sh 'ragel extract_movies.rl'
end

file 'extract_movies.bin' => 'extract_movies.c' do
  sh 'gcc extract_movies.c -o extract_movies.bin'
end

desc "Extracts all English pages about movies into ./enwiki as plain text files"
task :extract_english_movies => 'extract_movies.bin' do
  mkdir_p 'enwiki'
  rm_rf 'enwiki/*.txt'
  sh "./extract_movies.bin '#{ENWIKI_FILE}' 'enwiki'"
end

desc "Extracts all Chinese pages about movies into ./zhwiki as plain text files"
task :extract_chinese_movies => 'extract_movies.bin' do
  mkdir_p 'zhwiki'
  rm_rf 'zhwiki/*.txt'
  sh "./extract_movies.bin '#{ZHWIKI_FILE}' 'zhwiki'"
end
