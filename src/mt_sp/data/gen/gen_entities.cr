require "json"
require "colorize"
require "../sp_ents"

DIR = "/mnt/devel/Chivi/results/entities"
files = Dir.glob("#{DIR}/*/*.tsv")

SP::EntRelate.init_db(reset: true)
SP::EntValue.init_db(reset: true)
SP::EntFreq.init_db(reset: true)

SP::EntRelate.db.exec "begin"
SP::EntValue.db.exec "begin"
SP::EntFreq.db.exec "begin"

struct Related
  include JSON::Serializable
  getter related : Array(String)
end

files.each do |file|
  puts file

  etag = File.basename(file, ".tsv")

  File.each_line(file) do |line|
    form, meaning = line.split('\t')

    SP::EntFreq.upsert(form, etag, 1)

    next if meaning.empty?

    if meaning.includes?(%q|"related":|)
      related = Related.from_json(meaning).related.join('\t')
      SP::EntRelate.upsert(form, etag, related)
    end

    if meaning.includes?(%q|"value":|)
      SP::EntValue.upsert(form, etag, meaning)
    end
  rescue
    puts file.colorize.red
    puts line.colorize.red
    exit 1
  end
end

SP::EntRelate.db.exec "commit"
SP::EntValue.db.exec "commit"
SP::EntFreq.db.exec "commit"
