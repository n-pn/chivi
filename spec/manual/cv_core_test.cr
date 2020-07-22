require "../../src/engine/convert/cv_core"

text = "第十三集 龙章凤仪 第一章 屠龙之术
贾文和一个玩阴谋的，突然间客串了一把热血刺客，效果立竿见影。一万个道理都未必能说服的廖群玉，被一把错刀给说得心服口服，当即赶到宋国馆邸，通过官方渠道传讯临安，以自己的身家性命作保，顺利说服贾师宪，由其举荐宝钞局主事，工部员外郎程宗扬为唐国正使，通问昭南事宜。

宋国行事向来拖沓，但贾太师亲自出面，自是不同。更何况昭南的战争威胁正打中宋国的软肋，在临安造成的震荡比外界想像得更加剧烈。有道是病急乱投医，宋国上下一片惶恐，正情急间，突然有人挺身而出，主动为国分忧，朝廷百官无不额首称庆，根本无人质疑程宗扬仅仅只是个宝钞局主事，能不能担当起如此重任。

刚过午时，童贯便赶到程宅，口传圣谕：宝钞局主事，工部员外郎程宗扬忠敏勤敬，可当重任，特授礼部侍郎，差赴唐国，充任通问计议使，全权处置对唐国事务，及与昭南交涉各项事宜。

代宋主传完口谕，童贯立马趴下来，规规矩矩地叩首施礼，“恭喜程主事，升任礼部侍郎！”

程宗扬打趣道：“没跟你商量，就抢了你的正使职位，抱歉抱歉。”"

GENERIC = TrieDict.load! "data/trie_dicts/shared_base/generic.dic"
COMBINE = TrieDict.load! "data/trie_dicts/shared_base/combine.dic"
COMBINE.set("贾文和", "Giả Văn Hoà")

DICTS = [GENERIC, COMBINE]

def translate(input : String, title = false)
  if title
    CvCore.cv_title(DICTS, input).vi_text
  else
    CvCore.cv_plain(DICTS, input).vi_text
  end
end

text.split(/\n+/).each_with_index do |line, idx|
  puts translate(line, title: idx == 0)
end

puts translate("第一章", true)
puts translate("第一章 屠龙之术", true)
puts translate("一, 屠龙之术", true)
puts translate("第十三集 龙章凤仪 第一章 屠龙之术", true)
puts translate("1第一章")
puts translate("朥负已定")
