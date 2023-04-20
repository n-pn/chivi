require "sqlite3"

CORE = DB.open("sqlite3:var/mtdic/fixed/core.dic")
BOOK = DB.open("sqlite3:var/mtdic/fixed/book.dic")
at_exit { CORE.close; BOOK.close }

def find(dict, word)
  query = "select val, ptag, wseg from terms where key = ?"
  dict.query_all query, word, as: {String, String, Int32}
end

def purge(inp_file : String, commit = false)
  puts inp_file

  out_path = inp_file + ".old"

  if File.exists?(out_path)
    removed = File.read_lines(out_path).to_set
  else
    removed = Set(String).new
  end

  words = File.read_lines(inp_file).compact_map do |line|
    next if line.empty? || line[0] == '#'
    line.split('\t', 2).first
  end

  words.uniq!.each_with_index(1) do |key, idx|
    entries = find(CORE, key) # .concat(find(BOOK, key))
    puts "- <#{idx}> #{key}: #{entries.size} entries found."

    entries.each do |val, ptag, prio|
      removed << {key, val, ptag, prio}.join("\t")
    end

    next if !commit || entries.empty?
    CORE.exec "delete from terms where key = ?", key
  end

  File.write(out_path, removed.join("\n"))
end

commit = ARGV.includes?("--commit")

ARGV.each do |file|
  next if file.starts_with?('-')
  purge(file, commit: commit)
end
