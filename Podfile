platform :ios, "9.0"

target "MovieDict" do
  # This includes sqlite3 and enables compilation of the FTS5 module.
  pod "sqlite3/fts5", inhibit_warnings: true
  # No need to use FMDB/standalone-fts, because this only enables FTS3/4.
  pod "FMDB/standalone", inhibit_warnings: true
end
