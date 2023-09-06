# # require "./engine/*"
# require "./m2_data"
# require "./core/mt_data"
# require "./core/mt_dict"
# require "./core/basic_ner"
# require "./core/mt_rule/*"

# require "../_util/text_util"

# class M2::Engine
#   def self.new(udict : String, user : String? = nil, temp : Bool = false)
#     new(-ViDict.get_id(udict), user: user, temp: temp)
#   end

#   def initialize(udict : Int32 = 0, user : String? = nil, temp : Bool = false)
#     @dicts = [MtDict.core_base]
#     @dicts << MtDict.core_temp if temp

#     @dicts << MtDict.book_base(udict)
#     @dicts << MtDict.book_temp(udict) if temp
#   end

#   # def cv_title_full(title : String) : MtData
#   #   title, chvol = TextUtil.format_title(title)

#   #   mt_data = cv_title(title, offset: chvol.size)
#   #   return mt_data if chvol.empty?

#   #   tag, pos = PosTag.make(:empty)
#   #   pos |= MtlPos.flags(CapAfter, NoSpaceL)

#   #   mt_node = MonoNode.new("", "-", tag, pos, idx: chvol.size)
#   #   mt_data.add_head(mt_node)

#   #   cv_title(chvol).concat(mt_data)
#   # end

#   # def cv_title(title : String, offset = 0) : MtData
#   #   pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
#   #   return cv_plain(title, offset: offset) if pre_zh.empty?

#   #   pre_zh += pad
#   #   pre_vi += title.empty? ? "" : ":"

#   #   tag, pos = PosTag.make(:lit_trans)
#   #   pos |= MtlPos.flags(CapAfter, NoSpaceR)
#   #   mt_head = MonoNode.new(pre_zh, pre_vi, tag, pos, dic: 1, idx: offset)

#   #   mt_data = MtData.new
#   #   mt_data.add_head(mt_head)

#   #   return mt_data if title.empty?
#   #   mt_data.concat(cv_plain(title, offset: offset + pre_zh.size))
#   # end

#   def cv_plain(input : String) : MtData
#     mt_data = MtData.new(input)

#     ner_terms = BasicNER.detect_all(mt_data.inp_chars, idx: 0)

#     mt_data.inp_chars.size.downto(0) do |idx|
#       if ner_term = ner_terms[idx]?
#         MtRule.add_node(mt_data, ner_term, idx: idx)
#       end

#       dicts.each do |dict|
#         dict.scan(mt_data.inp_chars, start: idx) do |data|
#           data.each do |ptag, term|
#             atom = MtAtom.new(term, ptag: ptag, idx: idx)
#             MtRule.add_node(mt_data, atom, idx: idx)
#           end
#         end
#       end
#     end

#     # mt_data.fix_grammar!
#     # mt_data.apply_cap!(cap: add_cap)

#     mt_data
#   end
# end
