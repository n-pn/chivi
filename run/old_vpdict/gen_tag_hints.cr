# require "../../src/_init/postag_init"
# require "../../src/mt_v2/vp_hint"

# input = CV::PostagInit.new("_db/vpinit/bd_lac/out/top25-all.tsv")

# out_name = "var/vhint/postag/bd_lac"
# FileUtils.rm_rf(out_name)

# NUMHAN_RE = /^[零〇一二两三四五六七八九十百千万亿兆多余米来]+$/

# output = CV::VpHint.new(out_name, 256)

# input.data.each do |key, counts|
#   next if should_skip?(key, counts.first_key)

#   tags = [] of String
#   minimal = counts.first_value // 100

#   counts.each do |tag, count|
#     next if count < minimal

#     case tag
#     when "nx" then tags << "nz"
#     when "xc" then tags << "o" << "y"
#     when "m"  then tags << "mq"
#     else
#       tags << tag
#     end
#   end

#   output.add(key, tags.uniq!) unless tags.empty?
# end

# PREFIXES = {
#   "不知道",
#   "最初",
#   "有些",
#   "最后",
#   "最好",
#   "最强",
#   "最美",
#   "不是",
#   "不过",
#   "一段",
#   "一众",
#   "一样",
#   "一些",
#   "一般",
#   "一点",
#   "一道",
#   "一阵",
#   "一句",
#   "一名",
#   "一位",
#   "一座",
#   "一脚",
#   "一颗",
# }

# NOUN_PREFIXES = {
#   "一片",
#   "一条",
#   "一口",
#   "一声",
#   "一个",
#   "一只",
#   "一把",
#   "一笑",
#   "一群",
#   "一件",
#   "一张",
#   "一头",
#   "一直",
#   "一介",
# }

# def should_skip?(key : String, tag : String)
#   PREFIXES.each { |test| return true if key.size > 2 && key.starts_with?(test) }

#   if tag == "n"
#     NOUN_PREFIXES.each { |test| return true if key.starts_with?(test) }
#   end

#   if tag == "m" || tag == "t"
#     return true if key =~ /^[〇一二两三四五六七八九十百千万\d]/
#   end

#   return true if key =~ /^第[零〇一二两三四五六七八九十百千\d]+/
#   false
# end

# output.save!
