require "./mt_core"

TXT1 = "(NP (DNP (NP (NR 家乐福) (CC 或) (NR 大润发)) (DEG 的)) (NP (NN 大卖场)))"
TXT2 = "(NP\n  (QP (CD 很多))\n  (DNP (NP (NN 医学) (NN 领域) (PU 、) (NN 制药) (NN 领域)) (DEG 的))\n  (NP (NN 专家)))"
TXT3 = <<-TXT
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

puts TXT3.gsub(/\n[\t\s]+/, " ")
# node = AI::MtNode.parse(TXT3.gsub(/\)\Z+\(/, " ")
# CORE = AI::MtCore.new(0)
# puts CORE.translate(node)
