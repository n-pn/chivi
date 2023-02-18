require "json"
require "colorize"
require "../sp_ents"

DIR = "var/texts/anlzs/tmp"

# SP::EntRelate.init_db(reset: false)
# SP::EntValue.init_db(reset: false)
# SP::EntFreq.init_db(reset: false)

relates_sql = "select form, etag from ent_relates"
values_sql = "select form, etag from ent_values"

known_relates = SP::EntRelate.db.query_all(relates_sql, as: {String, String}).to_set
known_values = SP::EntValue.db.query_all(values_sql, as: {String, String}).to_set

books = Dir.children(DIR).sort_by! do |book|
  rows = book.split('-')
  book.starts_with?('!') ? rows.last.to_i - 100000 : rows.first.to_i
end

PRUNE = ARGV.includes?("--prune")

books.each do |book|
  SP::EntRelate.db.exec "begin"
  SP::EntValue.db.exec "begin"

  inp_dir = File.join(DIR, book)
  next unless File.directory?(inp_dir)

  files = Dir.children(inp_dir).select!(&.ends_with?("fine[M].tsv"))
  puts "#{inp_dir}: #{files.size}"

  files.each do |file|
    inp_file = File.join(inp_dir, file)
    strio = String::Builder.new

    File.each_line(inp_file) do |line|
      rows = line.split('\t')

      if rows.size < 3
        strio << '\n' if line.empty?
        next
      end

      form, idx, etag = rows
      strio << form << '\t' << idx << '\t' << etag << '\n'

      next unless (meaning = rows[4]?) && !meaning.empty?

      add_relates(form, etag, meaning, known_relates)
      add_values(form, etag, meaning, known_values)
    rescue
      puts [inp_file, line].colorize.red
      exit 1
    end

    File.write(inp_file.sub(".tsv", ".ner"), strio.to_s)
  end

  SP::EntRelate.db.exec "commit"
  SP::EntValue.db.exec "commit"

  next unless PRUNE

  files.each do |file|
    inp_file = File.join(inp_dir, file)
    File.delete?(inp_file)

    puts "#{inp_file} deleted".colorize.yellow
  end
end

struct Related
  include JSON::Serializable
  getter related : Array(String)
end

def add_relates(form, etag, meaning, known)
  return if known.includes?({form, etag}) || !meaning.includes?(%q|"related":|)

  puts "new related data added".colorize.blue

  related = Related.from_json(meaning).related

  File.open("tmp/ent_relates.tsv", "a") do |file|
    file << form << '\t' << etag << '\t' << related.to_json
  end

  SP::EntRelate.upsert(form, etag, related.join('\t'))
  known << {form, etag}
end

def add_values(form, etag, meaning, known)
  return if known.includes?({form, etag}) || !meaning.includes?(%q|"value":|)
  puts "new value data added".colorize.red

  File.open("tmp/ent_values.tsv", "a") do |file|
    file << form << '\t' << etag << '\t' << meaning
  end

  SP::EntValue.upsert(form, etag, meaning)

  known << {form, etag}
end
