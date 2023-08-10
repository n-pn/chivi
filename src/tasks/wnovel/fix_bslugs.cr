ENV["CV_ENV"] = "production" if ARGV.includes?("--prod")

require "../../_data/_data"
require "../../_util/text_util"

def make_bslug(hname : String)
  hslug = TextUtil.slugify(hname)
  tokens = hslug.split('-', remove_empty: true)

  if tokens.size > 8
    tokens.truncate(0, 8)
    tokens[7] = ""
  end

  tokens.join('-')
end

record Input, id : Int32, bslug : String, btitle_hv : String do
  include DB::Serializable
end

select_stmt = "select id, bslug, btitle_hv from wninfos"

inputs = PGDB.query_all select_stmt, as: Input

outputs = inputs.compact_map do |input|
  next if input.btitle_hv =~ /\p{Han}/
  bslug = make_bslug(input.btitle_hv)
  next if bslug == input.bslug
  {bslug, input.id}
end

outputs.each_slice(1000) do |slice|
  puts slice

  PGDB.exec "begin"

  slice.each do |bslug, wn_id|
    PGDB.exec "update wninfos set bslug = $1 where id = $2", bslug, wn_id
  end

  PGDB.exec "commit"
end
