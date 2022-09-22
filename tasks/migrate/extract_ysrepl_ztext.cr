require "../../src/ysweb/inputs/raw_crit"

def save_crit_body(crit : YS::RawCrit)
  # save crit body to disk instead of db
  # work in progress
  # TODO: remove crit_body field in db and use zip files insteads

  # do not write file if content is hidden in yousuu
  return if crit.ztext == "请登录查看评论内容" || crit.ztext.empty?

  save_dir = "var/ys_db/crits/#{crit.book.id}-zh"
  Dir.mkdir_p(save_dir)

  # write crit body to {yousuu_id}.zip
  # NOTE: were are using yousuu_id instead of yscrit id prefix
  # so that we can easy look for the custom dict name for the machine translation
  # also to detect some garbage spam reviews (which is already removed from yousuu)

  text_path = "#{save_dir}/#{crit._id}.txt"
  File.write(text_path, crit.ztext)
end

# ZTEXTS = Hash(String, Tabkv(String)).new do |h, k|
#   h[k] = Tabkv(String).new("var/ysinfos/yscrits/#{k}-ztext.tsv")
# end

# def fix_crit_body(input : String)
#   return input unless input == "请登录查看评论内容"
#   ZTEXTS[_id[0..3]][_id]? || "$$$"
# end

#############

DIR = "_db/yousuu"

dirs = Dir.children("#{DIR}/crits")

dirs.each do |dir|
  files = Dir.glob("#{DIR}/crits/#{dir}/*.json")

  files.each do |file|
    crits, _ = YS::RawCrit.from_book_json(File.read(file))
    crits.each { |crit| save_crit_body(crit) }
  rescue err
    puts file, err
  end
end
