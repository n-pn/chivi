require "../../src/engine/util"

puts CvUtil.titlecase("xxx  x x")
puts CvUtil.slugify("xxx  x x")

puts CvUtil.hanzi_int("1203")
puts CvUtil.hanzi_int("十")
puts CvUtil.hanzi_int("十七")
puts CvUtil.hanzi_int("二十")
puts CvUtil.hanzi_int("二十七")
puts CvUtil.hanzi_int("百")
puts CvUtil.hanzi_int("百零五")
puts CvUtil.hanzi_int("百十五")
puts CvUtil.hanzi_int("八百零五")
puts CvUtil.hanzi_int("八百三十五")
puts CvUtil.hanzi_int("四千零七")
puts CvUtil.hanzi_int("四千八百零七")
puts CvUtil.hanzi_int("四千二百一十七")
puts CvUtil.hanzi_int("九九九〇")
