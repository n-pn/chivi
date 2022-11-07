require "../../src/ysapp/inputs/raw_crit"

def save_crit_body(crit : YS::RawCrit, skip_if_exists = false)
  # save crit body to disk instead of db
  # work in progress
  # TODO: remove crit_body field in db and use zip files insteads

  # do not write file if content is hidden in yousuu
  return if crit.ztext == "请登录查看评论内容" || crit.ztext.empty?

  save_dir = "var/ysapp/crits/#{crit.book.id}-zh"
  Dir.mkdir_p(save_dir)

  # write crit body to {yousuu_id}.zip
  # NOTE: were are using yousuu_id instead of yscrit id prefix
  # so that we can easy look for the custom dict name for the machine translation
  # also to detect some garbage spam reviews (which is already removed from yousuu)

  text_path = "#{save_dir}/#{crit._id}.txt"
  return if skip_if_exists && File.exists?(text_path)

  File.write(text_path, crit.ztext)
end

#############
# DIR = "_db/yousuu"

# dirs = Dir.glob("#{DIR}/crits-by-list/*/")
# dirs.each do |dir|
#   files = Dir.glob("#{dir}/*.json")

#   files.each do |file|
#     crits, _ = YS::RawCrit.from_book_json(File.read(file))
#     crits.each { |crit| save_crit_body(crit, skip_if_exists: true) }
#   rescue err
#     puts file, err
#   end
# end

# dirs = Dir.glob("#{DIR}/crits-by-list/*/")

# dirs.each do |dir|
#   files = Dir.glob("#{dir}/*.json")

#   files.each do |file|
#     crits, _ = YS::RawCrit.from_list_json(File.read(file))
#     crits.each { |crit| save_crit_body(crit, skip_if_exists: true) }
#   rescue err
#     puts file, err
#   end
# end
