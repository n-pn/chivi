# require "./ai_term"

class MT::AiCore
  CMP_WORD = {
    "似的" => "giống y",
    "一样" => "giống",
    "一般" => "giống hệt",
    "般"  => "hệt",

    "和" => "với",
    "与" => "với",
    "跟" => "với",
    "同" => "với",
    "如" => "như",
    "像" => "như",
  }

  CMP_PAIR = {
    {"似的", "仿佛"} => {"giống", "như"},
    {"似的", "宛若"} => {"giống", "như"},
    {"似的", "好像"} => {"thật giống", "như"},
    {"似的", "如同"} => {"giống hệt", "như"},

    {"一样", "仿佛"} => {"giống", "như"},
    {"一样", "宛若"} => {"giống", "như"},
    {"一样", "好像"} => {"thật giống", "như"},
    {"一样", "如同"} => {"giống hệt", "như"},

    {"一般", "仿佛"} => {"giống", "như"},
    {"一般", "宛若"} => {"giống", "như"},
    {"一般", "好像"} => {"thật giống", "như"},
    {"一般", "如同"} => {"giống hệt", "như"},

    {"般", "仿佛"} => {"hệt", "tựa"},
    {"般", "宛若"} => {"hệt", "tựa"},
    {"般", "好像"} => {"thật hệt", "như"},
    {"般", "如同"} => {"giống hệt", "như"},
  }

  def fix_cmp_type_1!(vp_node : MtNode, vp_body : Array(MtNode), vp_tail : MtNode? = nil) : MtNode
    ad_list = [] of MtNode
    cp_node = vp_body.pop

    while vp_body.first?.try(&.epos.advb?)
      ad_list << vp_body.shift
    end

    at_tail = ad_list.size

    while vp_body.last?.try(&.epos.advb?)
      ad_list.insert(at_tail, vp_body.pop)
    end

    unless vp_head = vp_body.first?.try(&.inner_head)
      ad_list.insert(at_tail, cp_node)
      vp_node.body = ad_list
      return vp_node
    end

    unless fix_pair_body!(CMP_PAIR, cp_node, vp_head)
      fix_term_body!(CMP_WORD, cp_node)
      fix_term_body!(CMP_WORD, vp_head)
    end

    if new_body = fix_vp_body!(vp_body)
      vp_body = [new_body]
    end

    vp_body.unshift(cp_node)
    vp_body.unshift(vp_tail) if vp_tail
    ad_list.reverse_each { |node| vp_body.unshift(node) }

    vp_node.body = vp_body
    vp_node.attr |= :at_t
    vp_node
  end
end
