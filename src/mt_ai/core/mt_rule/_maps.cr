class MT::AiCore
  def fix_term_body!(hashmap : Hash(String, String), node : MtNode)
    return false unless vstr = hashmap[node.zstr]?

    if vstr == "∅"
      node.attr = :hide
    elsif !vstr.empty?
      node.body = vstr
    end

    true
  end

  def fix_pair_body!(hashmap : Hash({String, String}, {String, String}), head : MtNode, tail : MtNode)
    return false unless found = hashmap[{head.zstr, tail.zstr}]?
    head_vstr, tail_vstr = found

    if head_vstr == "∅"
      head.attr = :hide
    elsif !head_vstr.empty?
      head.body = head_vstr
    end

    if tail_vstr == "∅"
      tail.attr = :hide
    elsif !tail_vstr.empty?
      tail.body = tail_vstr
    end

    true
  end
end
