module MT::Core
  def split_mono!(node : MonoNode)
    raise "Only support split pronouns" unless node.tag.pronouns?

    pronoun = make_pronoun_node(node.key[0].to_s)

    qt_key = node.key[1..]
    qt_val = node.val.sub("#{pronoun.val}", "").strip

    quanti = MonoNode.new(qt_key, qt_val, PosTag::Qtnoun, idx: node.idx + 1, dic: 1)
    {pronoun, quanti}
  end

  private def make_pronoun_node(key : String)
  end
end
