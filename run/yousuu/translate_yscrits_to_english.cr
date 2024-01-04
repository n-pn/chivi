require "colorize"

ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"

require "../../src/mt_ai/core/*"
require "../../src/mt_sp/util/*"

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

  trans = SP::DlTran.translate(input.ztext.split(/\R/))
  File.write(file_path, trans.join('\n'))

  puts "- <#{idx}/#{inputs.size}> #{input.yc_id} translated \
          (total: #{translated} chars, remain keys: #{SP::DlTran.api_keys.size})"
end
