require "./mtl_pos"
require "./mtl_tag"

module MT::PosTag
  property pos = MtlPos::None
  property tag = MtlTag::LitBlank

  forward_missing_to @tag

  def nebulous?
    @pos.nebulous? || @tag.nebulous?
  end

  delegate boundary?, to: @pos
  delegate inactive?, to: @pos

  delegate cap_after?, to: @pos
  delegate no_ws_before?, to: @pos
  delegate no_ws_after?, to: @pos

  delegate at_head?, to: @pos
  delegate at_tail?, to: @pos

  delegate redup?, to: @pos

  delegate aspect?, to: @pos
  delegate vauxil?, to: @pos

  delegate ktetic?, to: @pos
  delegate aspect?, to: @pos
  delegate vcompl?, to: @pos
  delegate object?, to: @pos

  delegate proper?, to: @pos
  delegate plural?, to: @pos
  delegate people?, to: @pos
  delegate locale?, to: @pos

  delegate maybe_noun?, to: @pos
  delegate maybe_verb?, to: @pos
  delegate maybe_adjt?, to: @pos
  delegate maybe_advb?, to: @pos

  delegate can_split?, to: @pos
  delegate link_verb?, to: @pos
  delegate bond_word?, to: @pos
end

# puts MT::PosTag.init("n").tag
# puts MT::PosTag.init("na").tag
# puts MT::PosTag.init("vm", "").tag
# puts MT::PosTag.init("~vd").tag
# puts MT::PosTag.init("w", "﹑").tag
# puts MT::PosTag.init("w", ":").tag
# puts MT::PosTag.init("w", "：").tag
# puts MT::PosTag.init("v!", "会").tag
# puts MT::PosTag.init("w", "《").tag
# puts MT::PosTag.init("w", "“").tag
