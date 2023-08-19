require "colorize"
require "./mt_core"

TEST1 = "(NP (DNP (NP (NR 家乐福) (CC 或) (NR 大润发)) (DEG 的)) (NP (NN 大卖场)))"
TEST2 = "(NP\n  (QP (CD 很多))\n  (DNP (NP (NN 医学) (NN 领域) (PU 、) (NN 制药) (NN 领域)) (DEG 的))\n  (NP (NN 专家)))"
TEST3 = <<-TXT
(TOP
  (IP
    (PU “)
    (IP
      (NP (PN 他))
      (VP
        (ADVP (AD 一直))
        (ADVP (AD 很))
        (VP
          (VV 想)
          (IP (VP (VP (VV 进) (NP (NN 鬼) (NN 屋))) (VP (VV 参观)))))))
    (PU ，)
    (IP
      (NP (PN 这))
      (VP
        (VC 是)
        (NP
          (CP
            (CP
              (IP
                (NP (PN 我))
                (VP (PP (P 和) (NP (PN 他))) (VP (VRD (VV 约定) (VA 好)))))
              (DEC 的))))))
    (PU ，)
    (IP (VP (VNV (VV 能) (AD 不) (VV 能)) (VP (VV 帮帮忙))))
    (PU 。)
    (PU ”)
    (IP
      (NP (NN 少妇))
      (VP
        (PP (P 从) (LCP (NP (NN 背包)) (LC 里)))
        (VP
          (VRD (VV 翻) (VV 出))
          (NP
            (QP (CLP (M 张)))
            (DNP (QP (CD 一百)) (DEG 的))
            (ADJP (JJ 整))
            (NP (NN 钞))))))
    (PU ：)
    (CP (PU “) (IP (VP (VV 不会) (VP (VV 出事)))) (SP 的))
    (PU 。)
    (PU ”)))
TXT

TEST4 = <<-TXT
(TOP
  (IP
    (IP
      (NP (NR 平安县))
      (VP
        (VC 是)
        (NP (NP (NP (NR 宁州)) (QP (CD 七十二)) (NP (NN 县))) (NP (NN 之一)))))
    (PU ，)
    (IP
      (NP (NN 境内))
      (VP (ADVP (AD 多)) (VP (VC 是) (NP (NN 山川) (NN 丘陵)))))
    (PU ，)
    (IP (NP (NN 人口)) (VP (VA 稀少)))
    (PU ，)
    (IP
      (NP (NR 莲花岛))
      (VP
        (VC 是)
        (NP
          (LCP (NP (NR 平安县)) (LC 内))
          (DNP (ADJP (JJ 唯一)) (DEG 的))
          (QP (CD 一) (CLP (M 座)))
          (NP (NN 湖) (NN 岛)))))
    (PU 。)))
TXT

TEST5 = <<-TXT
(TOP
  (IP
    (IP (VP (VV 离) (DER 得) (VP (VP (VA 近)) (SP 了))))
    (PU ,)
    (VP
      (ADVP (AD 就))
      (ADVP (AD 越发))
      (VP
        (VV 觉出)
        (NP
          (NP (DNP (NP (NN 尸骸)) (DEG 的)) (NP (NN 高大)))
          (CC 和)
          (NP (DNP (NP (PN 自身)) (DEG 的)) (NP (NN 渺小))))))
    (PU 。)))
TXT

TEST6 = <<-TXT
(TOP
  (IP
    (NP
      (LCP (NP (NP (PN 她)) (NP (NN 心))) (LC 中))
      (DP (DT 那) (CLP (M 份)))
      (DNP (ADJP (JJ 淡淡)) (DEG 的))
      (NP (NN 感伤)))
    (VP (VV 散去))
    (SP 了)
    (PU 。)))
TXT

# CORE = AI::MtCore.new(0)

# def do_test(input : String)
#   input = input.strip
#   puts input
#   puts "--------------------------------".colorize.dark_gray
#   puts CORE.translate(input).colorize.yellow
#   puts "--------------------------------".colorize.dark_gray
# end

# puts do_test(TEST1)
# puts do_test(TEST2)
# puts do_test(TEST3)
# puts do_test(TEST4)
# puts do_test(TEST5)
# puts do_test(TEST6)

def parse_file(input : String)
  url = "localhost:5555/mtl/electra_base/file?file=#{input}"
  HTTP::Client.get(url) do |res|
    raise "invalid: #{res.body_io.gets_to_end}" unless res.status.success?
    # puts File.read(input.sub(".txt", ".con"))
  end
end

# def parse_line(input : String)
#   url = "localhost:5555/con/rand"

#   HTTP::Client.post(url, body: input) do |res|
#     puts res.body_io.gets_to_end
#   end
# end
time = Time.measure do
  # parse_line " “浅川同学。”一花笑吟吟道，“昨天下午的提议你考虑的怎么样了？” "
  parse_file "/2tb/tmp.chivi/texts/1-f3mh03-1.txt"
end

puts time
