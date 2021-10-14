require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")
CV::VpDict.combine.set(CV::VpTerm.new("贾文和", ["Giả Văn Hoà"], "nr 4"))

puts CV::VpDict.regular.find("龙")
puts CV::VpDict.regular.find("之术")
puts CV::VpDict.regular.find("历史")

HANVIET = CV::MtCore.hanviet_mtl

def test_convert(input : String, mode = 0)
  puts "=" * 65
  puts "#{input}"
  puts "-" * 65

  output = case mode
           when 2 then GENERIC.cv_title_full(input)
           when 1 then GENERIC.cv_title(input)
           else        GENERIC.cv_plain(input)
           end

  puts output.to_s # , output.inspect

  # puts "=" * 65
end

test1 = "坚定不移沿着中国特色社会主义道路前进  为全面建成小康社会而奋斗"
test2 = "MUV  LUV AL 红龙"
test3 = "异闻录  每晚一个离奇的故事"
test4 = "红龙M红~~~龙 MUV  LUV AL 红龙 http://test.com/test?q=1"
test5 = "【实验总分：79.3。排名：6】"
test6 = "“稍等。”李峥倒是不在意这些议论，更在意身旁失魂落魄的大兄弟，“英男别慌，最惨的是我才对，400分满分，输了一分，输了一生。”"

puts HANVIET.translit(test1)
puts HANVIET.translit(test2)
puts HANVIET.translit(test3)
puts HANVIET.translit(test4)
puts HANVIET.translit("左丰")

text = "第十三集 龙章凤仪 第一章 屠龙之术
红龙 http://test.com/test?q=1
贾文和一个玩阴谋的，突然间客串了一把热血刺客，效果立竿见影。一万个道理都未必能说服的廖群玉，被一把错刀给说得心服口服，当即赶到宋国馆邸，通过官方渠道传讯临安，以自己的身家性命作保，顺利说服贾师宪，由其举荐宝钞局主事，工部员外郎程宗扬为唐国正使，通问昭南事宜。
宋国行事向来拖沓，但贾太师亲自出面，自是不同。更何况昭南的战争威胁正打中宋国的软肋，在临安造成的震荡比外界想像得更加剧烈。有道是病急乱投医，宋国上下一片惶恐，正情急间，突然有人挺身而出，主动为国分忧，朝廷百官无不额首称庆，根本无人质疑程宗扬仅仅只是个宝钞局主事，能不能担当起如此重任。
刚过午时，童贯便赶到程宅，口传圣谕：宝钞局主事，工部员外郎程宗扬忠敏勤敬，可当重任，特授礼部侍郎，差赴唐国，充任通问计议使，全权处置对唐国事务，及与昭南交涉各项事宜。
代宋主传完口谕，童贯立马趴下来，规规矩矩地叩首施礼，“恭喜程主事，升任礼部侍郎！”
程宗扬打趣道：“没跟你商量，就抢了你的正使职位，抱歉抱歉。”
‘果然！知识的积累！我有种感觉，这些魔咒我虽然在这六年中，从来没有看过一眼。但理解魔咒的必备条件，我已经都掌握了！此时掌握它们，就像是做小学生的加减运算题那样简单！’
"

text.split(/\n+/).each_with_index do |line, idx|
  test_convert(line, idx == 0 ? 2 : 0)
end

test_convert("第一章", mode: 1)
test_convert("第一章 屠龙之术", mode: 1)
test_convert("一, 屠龙之术", mode: 1)
test_convert("1, 屠龙之术", mode: 1)
test_convert("第十三集 龙章凤仪 第一章屠龙之术", mode: 2)
test_convert("第十三集 龙章凤仪", mode: 1)
test_convert("1第一章")
test_convert("一. 屠龙之术")
test_convert("朥负已定")
test_convert("第三千七百九十八章 历史的本质就是套娃", mode: 1)
test_convert("12：12", mode: 1)

pp GENERIC.cv_plain("能让我坐在这里无病呻－吟")
pp GENERIC.cv_title("1, 屠龙之术")
pp GENERIC.cv_plain("无病呻－吟").to_s

text = "【飞卢中文网A级签约作品：荒野食神之吃光食物链】当叶晓晨第一次得到【荒野食神系统】的时候，其实他是，是拒绝的，他跟系统讲，他拒绝，因为，其实他，根本没有厨艺……系统跟他讲，抓完荒野食材给厨艺，刀工很叼很快很炫目……  奇奇怪怪的荒野食材，丛林、沙漠、冰川、抓了这些食材，加了一段时间的厨艺技能之后呢！  菠萝烤鳄鱼，DUANG~~~很柔，很软。  蜜汁熊掌，DUANG~~~很香，很滑口。  亚马逊电鳗鱼面，DUANG~~DUANG~~DUANG~~很弹牙！  ……  女明星们问为什么这么好吃。  因为叶晓晨，他加特技…(本故事及人物纯属虚构，如有雷同，纯属巧合，切勿模仿。)"
list = GENERIC.cv_plain(text)
puts list

text = "奇奇怪怪的荒野食材，丛林、沙漠、冰川、抓了这些食材"
list = GENERIC.cv_plain(text)
puts list, list.inspect

puts GENERIC.cv_plain("……怎么也这么好看。")
pp GENERIC.cv_plain("飞卢中文网A级签约作品")
pp GENERIC.cv_plain("许七安越说越兴奋")
pp GENERIC.cv_plain("越说越兴奋")
pp GENERIC.translit("许七安越说越兴奋")
pp GENERIC.cv_plain("第二个反应是：")

test_convert("【第006章】我的美女死党", mode: 2)
test_convert("百分之九十九点九九")

puts GENERIC.cv_plain("‘成功了！’").to_str
puts GENERIC.cv_plain("奥西克丽丝浑身颤抖的指向了大门说道：“快出去！”").to_str
