require "sqlite3"

DIR = "var/mtdic/fixed"
DIC = DB.open "sqlite3:#{DIR}/common-main.dic"

at_exit { DIC.close }

record Term, zstr : String, vstr : String, xpos : String, feat : String do
  include DB::Serializable

  def to_tsv(io : IO)
    {zstr, vstr, xpos, feat}.join(io, '\t')
  end
end

def write_to_disk(out_path : String, data : Array(Term))
  File.open(out_path, "w") do |file|
    data.join(file, '\n') { |term| term.to_tsv(file) }
  end
end

single_tags = DIC.query_all("select zstr, vstr, xpos, feat from defns where xpos <> '' and not xpos like '% %'", as: Term)

# write_to_disk("#{DIR}/_temp/single_tags.tsv", single_tags)
# write_to_disk("#{DIR}/_temp/single_tags-VA.tsv", single_tags.select(&.xpos.== "VA"))
# write_to_disk("#{DIR}/_temp/single_tags-VV.tsv", single_tags.select(&.xpos.== "VV"))
# write_to_disk("#{DIR}/_temp/single_tags-NT.tsv", single_tags.select(&.xpos.== "NT"))
# write_to_disk("#{DIR}/_temp/single_tags-CD.tsv", single_tags.select(&.xpos.== "CD"))
# write_to_disk("#{DIR}/_temp/single_tags-M.tsv", single_tags.select(&.xpos.== "M"))
# write_to_disk("#{DIR}/_temp/single_tags-NN.tsv", single_tags.select(&.xpos.== "NN"))
# write_to_disk("#{DIR}/_temp/single_tags-NR.tsv", single_tags.select(&.xpos.== "NR"))
write_to_disk("#{DIR}/_temp/single_tags-AD.tsv", single_tags.select(&.xpos.== "AD"))
