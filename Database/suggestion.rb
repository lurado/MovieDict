desc "Populates the 'suggestion' column in Movies.db"
task :fill_suggestion_column => :database do
  counter = 0
  indices = {}
  
  $db.execute "UPDATE movies SET suggestion = NULL"
  
  $db.execute2 "SELECT * FROM movies" do |columns|
    if indices.empty?
      columns.each_with_index do |column_name, index|
        indices[column_name] = index
      end
    else
      id = columns[indices['id']]
      languages = LANGUAGES.map { |lang| columns[indices[lang]] }.compact
      
      if languages.count >= 4
        $db.execute "UPDATE movies SET suggestion = #{counter} WHERE id = ?", id
        counter += 1
      end
    end
  end
  
  $db.execute "CREATE UNIQUE INDEX IF NOT EXISTS suggestion ON movies (suggestion)"
end
