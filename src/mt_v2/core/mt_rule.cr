require "./mt_rule/*"

module M2::MtRule
  macro add_rule(apos, bpos = nil, fn_name = nil)
    {% if fn_name %}
      _add_rule({{apos}}, {{bpos}}, ->{{fn_name.id}}(MtData, MtNode, MtNode, Int32))
    {% elsif bpos == nil %}
      _add_rule({{apos}}, ->{{apos.downcase.id}}(MtData, MtNode, Int32))
    {% elsif bpos.is_a?(StringLiteral) %}
      _add_rule({{apos}}, {{bpos}}, ->{{apos.downcase.id}}__{{bpos.downcase.id}}(MtData, MtNode, MtNode, Int32))
    {% else %}
      _add_rule({{apos}}, ->{{bpos.id}}(MtData, MtNode, Int32))
    {% end %}
  end

  add_rule "NN"
  add_rule "NR", nn
  add_rule "NT", nn

  add_rule "NN", "NN"
  add_rule "NT", "NT"

  add_rule "NN", "CC"
  # add_rule "NT", "CC", nn__cc

  add_rule "NR", "NN"

  add_rule "NR_s", "NN_ss"
  add_rule "NR_h", "NN_hs"
  add_rule "NR_h", "NN_hs"
end
