module CV::Improving
  QUANTI = {
    "石" => "thạch",
    "两" => "lượng",
    "里" => "dặm",
    "米" => "mét",
  }

  def fix_number!(node : MtNode) : MtNode
    while succ = node.succ
      break unless succ.number?
      node = succ.tap(&.fuse_left!("#{node.val} "))
    end

    return node unless succ

    {% begin %}
    case succ.key
      {% for key, val in QUANTI %}
      when {{key}} then succ.update!({{val}}, PosTag::Quanti)
      {% end %}
    end
    {% end %}

    case succ
    when .quanti?, .nquant?, .qtverb?, .qttime?
      node.fuse_right!("#{node.val} #{succ.val}")
      node.tag = PosTag::Nquant
    end

    node
  end
end
