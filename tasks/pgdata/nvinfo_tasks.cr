require "file_utils"
require "../shared/bootstrap"

output = File.open("var/_common/nvinfos.tsv", "w")
CV::Nvinfo.query.order_by(id: :asc).each do |nvinfo|
  entry = {nvinfo.zname, nvinfo.author.zname}
  output.puts entry.join('\t')
end

output.close
