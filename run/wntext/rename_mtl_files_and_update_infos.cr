require "sqlite3"

# require "../../src/wnapp/data/chinfo"
log_files = Dir.glob("var/wnapp/logging/*-anlz.db")

log_files.each do |log_file|
  puts log_file
  wn_id = File.basename(log_file, "-anlz.db")

  wn_dir = "var/wnapp/nlp_wn/#{wn_id}"
  Dir.mkdir_p(wn_dir)

  input = [] of {Int32, Int32, String}

  input = DB.open("sqlite3:#{log_file}?immutable=true") do |db|
    # query = "select ch_no, p_idx, cksum from ulogs where _algo = 'electra_base'"
    query = "select ch_no, p_idx, cksum from ulogs"
    db.query_all(query, as: {Int32, Int32, String})
  end

  input.each do |ch_no, p_idx, cksum|
    path = "#{wn_id}/#{ch_no}-#{cksum}-#{p_idx}"
    puts path

    mtl_file = "var/wnapp/chtext/#{path}.hmeb.mtl"
    con_file = "var/wnapp/chtext/#{path}.hmeb.con"

    File.rename(mtl_file, mtl_file.sub("chtext", "nlp_wn")) if File.file?(mtl_file)
    File.rename(con_file, con_file.sub("chtext", "nlp_wn")) if File.file?(con_file)
  end

  # DB.open("sqlite3:#{log_file}") do |db|
  #   db.exec "begin"
  #   db.exec "update ulogs set _algo = 'hmeb' where _algo = 'electra_base'"
  #   db.exec "commit"
  # end
end
