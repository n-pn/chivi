require "../src/_data/_data"
require "../src/mtapp/service/deepl_api"

record Input, yc_id : String, ztext : String do
  include DB::Serializable
end

inputs = PGDB.query_all <<-SQL, as: Input
  select encode(yc_id::bytea, 'hex') as yc_id, ztext from yscrits
  where like_count > 0 or repl_count > 0
  order by like_count desc
SQL

DIR = "/2tb/var.chivi/ysapp/crits"

translated = 0

inputs.each_with_index(1) do |input, idx|
  translated += input.ztext.size

  dir_path = "#{DIR}/#{input.yc_id[0..4]}-de"
  Dir.mkdir_p(dir_path)

  file_path = "#{dir_path}/#{input.yc_id}.txt"
  next if File.file?(file_path)

  deepl = SP::Deepl.translate(input.ztext.split(/\R/))
  File.write(file_path, deepl.map(&.[1]).join('\n'))

  puts "- <#{idx}/#{inputs.size}> #{input.yc_id} translated \
          (total: #{translated} chars, remain keys: #{SP::Deepl.clients.size})"
end
