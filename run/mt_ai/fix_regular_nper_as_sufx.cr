# ENV["MT_DIR"] = "/2tb/dev.chivi/var/mt_db/mt_ai"
ENV["MT_DIR"] = "/2tb/app.chivi/var/mt_db/mt_ai"

require "../../src/mt_ai/data/vi_term"

# nh_zstrs = File.read_lines("var/mtdic/cvmtl/vocab/chinese-honorifics.tsv").reject!(&.blank?)

# n_honors = [] of {String, String}

# MT::ViTerm.db("regular").open_ro do |db|
#   query = "select vstr from terms where ipos = #{MT::MtEpos::NN.value} and zstr = $1"

#   nh_zstrs.each do |zstr|
#     next unless vstr = db.query_one?(query, zstr, as: String)
#     n_honors << {zstr, vstr}
#   end
# end

MT::ViTerm.db("regular").open_tx do |db|
  query = "update terms set vstr = $1 where ipos = #{MT::MtEpos::NN.value} and zstr = $2"
  File.each_line("var/mtdic/fix_honors.tsv") do |line|
    zstr, vstr = line.split('\t')
    db.exec query, vstr, zstr
  end
end
