require "../../src/engine/cutil"

puts CUtil.titlecase("xxx  x x")
puts CUtil.slugify("xxx  x x")

puts CUtil.hanzi_int("1203")
puts CUtil.hanzi_int("十")
puts CUtil.hanzi_int("十七")
puts CUtil.hanzi_int("二十")
puts CUtil.hanzi_int("二十七")
puts CUtil.hanzi_int("百")
puts CUtil.hanzi_int("百零五")
puts CUtil.hanzi_int("百十五")
puts CUtil.hanzi_int("八百零五")
puts CUtil.hanzi_int("八百三十五")
puts CUtil.hanzi_int("四千零七")
puts CUtil.hanzi_int("四千八百零七")
puts CUtil.hanzi_int("四千二百一十七")
puts CUtil.hanzi_int("九九九〇")
