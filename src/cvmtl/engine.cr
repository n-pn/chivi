# require "./engine/*"
require "./cv_data/cv_dict"
require "./mt_data"
require "../_util/text_util"

class MT::Engine
  def initialize(book : String, temp : Bool = false)
    @dicts = [MtDict.core_base]
    @dicts << MtDict.core_temp if temp

    b_id = -CvDict.id_of(book)
    return if b_id == 0

    @dicts << MtDict.book_base(b_id)
    @dicts << MtDict.book_temp(b_id) if temp
  end

  # def cv_title_full(title : String) : MtData
  #   title, chvol = TextUtil.format_title(title)

  #   mt_data = cv_title(title, offset: chvol.size)
  #   return mt_data if chvol.empty?

  #   tag, pos = PosTag.make(:empty)
  #   pos |= MtlPos.flags(CapAfter, NoSpaceL)

  #   mt_node = MonoNode.new("", "-", tag, pos, idx: chvol.size)
  #   mt_data.add_head(mt_node)

  #   cv_title(chvol).concat(mt_data)
  # end

  # def cv_title(title : String, offset = 0) : MtData
  #   pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
  #   return cv_plain(title, offset: offset) if pre_zh.empty?

  #   pre_zh += pad
  #   pre_vi += title.empty? ? "" : ":"

  #   tag, pos = PosTag.make(:lit_trans)
  #   pos |= MtlPos.flags(CapAfter, NoSpaceR)
  #   mt_head = MonoNode.new(pre_zh, pre_vi, tag, pos, dic: 1, idx: offset)

  #   mt_data = MtData.new
  #   mt_data.add_head(mt_head)

  #   return mt_data if title.empty?
  #   mt_data.concat(cv_plain(title, offset: offset + pre_zh.size))
  # end

  def cv_plain(input : String, add_cap = true) : MtData
    mt_data = MtData.new(input)
    mt_data.construct!(@dicts)

    # mt_data.fix_grammar!
    # mt_data.apply_cap!(cap: add_cap)

    mt_data
  end
end
