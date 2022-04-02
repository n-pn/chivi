require "../shared/seed_util"

INP = "_db/bcover"
OUT_NEW = "_db/_output"
OUT_OLD = "_db/_webp"


CACHE = {} of String => Tabkv


def load_covers(sname : String, snvid : String)
  map = CACHE[sname] ||= Tabkv.load("var/nvseeds/#{sname}/covers.tsv")
  map.get()

end

CV::Nvinfo.query.each do |nvinfo|

  if nvinfo.ysbook_id > 0
    out_file = "#{OUT_NEW}/"
    old_file = "#{OUT_OLD}/yousuu.#{nvinfo.ysbook_id}.webp"
    if File.exists?(old_file)
  end
end
