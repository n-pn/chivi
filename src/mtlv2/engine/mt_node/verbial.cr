# module MtlV2::AST
#   class Verbal < BaseNode; end

#   class VShi < Verbal; end

#   class VYou < Verbal; end

#   # 动词 - verb - động từ
#   class Verb < Verbal
#     @[Flags]
#     enum Flag
#       DirCompl # Direction complement
#       ResCompl # Result complement
#       PotCompl # Potential complement
#       QtiCompl # Quantity complement

#       HasPzai
#       HasUzhe
#       HasUde3

#       HasBu4
#       HasUle

#       Need0Obj
#       Need2Obj
#     end

#     getter flag = Flag::None

#     DIR_RE = /.+[下上出进回过起来去]/
#     RES_RE = /[好完错晚坏饱清到走会懂见掉]/

#     def initialize(term : V2Term)
#       super(term)
#       return if key.size < 2

#       @flag |= Flag::HasPzai if key.includes?('在')
#       @flag |= Flag::HasUzhe if key.includes?('着')
#       @flag |= Flag::HasUde3 if key.includes?('得')

#       @flag |= Flag::HasBu4 if key.includes?('不')
#       @flag |= Flag::HasUle if key.includes?('了')

#       @flag |= Flag::DirCompl if key =~ DIR_RE
#       @flag |= Flag::ResCompl if key =~ RES_RE
#     end
#   end

#   class VLinking < Verb
#     MAP_VAL = {
#       "爱"   => "yêu",
#       "喜欢"  => "thích",
#       "避免"  => "tránh",
#       "忍不住" => "không nhịn được",
#       "加以"  => "tiến hành",
#       "进行"  => "tiến hành",
#       "予以"  => "ban cho",
#       "着手"  => "lấy tay",
#       "舍得"  => "nỡ bỏ",
#     }

#     def self.has_key?(key : String)
#       MAP_VAL.has_key?(key)
#     end
#   end

#   class VCompare < Verb
#     MAP_VAL = {
#       "如"  => "tựa",
#       "像"  => "giống",
#       "仿佛" => "giống",
#       "宛若" => "giống",
#       "好像" => "thật giống",
#       "和"  => "giống",
#     }

#     def self.has_key?(key : String)
#       MAP_VAL.has_key?(key)
#     end
#   end

#   class VDircomp < Verb
#     MAP_VAL = {
#       "上"  => "lên",
#       "下"  => "xuống",
#       "进"  => "vào",
#       "出"  => "ra",
#       "过"  => "qua",
#       "去"  => "đi",
#       "回"  => "trở về",
#       "起"  => "lên",
#       "来"  => "tới",
#       "上来" => "đi đến",
#       "上去" => "đi lên",
#       "下来" => "lại",
#       "下去" => "xuống",
#       "进来" => "tiến đến",
#       "进去" => "đi vào",
#       "出来" => "đi ra",
#       "出去" => "ra ngoài",
#       "过来" => "qua tới",
#       "过去" => "qua",
#       "回来" => "trở về",
#       "回去" => "trở lại",
#       "起来" => "lên",
#     }

#     def self.has_key?(key : String)
#       MAP_VAL.has_key?(key)
#     end
#   end

#   class Verb2Obj < Verb
#     def initialize(term : V2Term)
#       super(term)
#       @flag |= Flag::Need2Obj
#     end
#   end

#   class IntrVerb < Verb
#     def initialize(term : V2Term)
#       super(term)
#       @flag |= Flag::Need0Obj
#     end
#   end

#   class VerbObject < IntrVerb; end

#   #########

#   class VerbNoun < Mixed
#     getter verb_val : String? = nil
#     getter verb_tag : String = "v"

#     getter noun_val : String? = nil
#     getter noun_tag : String = "n"

#     def initialize(term : V2Term)
#       super(term)

#       @verb_val = term.vals[1]?
#       @verb_tag = term.tags[1]? || "v"

#       @noun_val = term.vals[2]?
#       @noun_tag = term.tags[2]? || "n"
#     end

#     # def as_noun
#     # end
#   end

#   class VerbAdvb < Mixed
#     getter verb_val : String? = nil
#     getter verb_tag : String = "v"

#     getter advb_val : String? = nil
#     getter advb_tag : String = "a"

#     def initialize(term : V2Term)
#       super(term)

#       @verb_val = term.vals[1]?
#       @verb_tag = term.tags[1]? || "v"

#       @advb_val = term.vals[2]?
#       @advb_tag = term.tags[2]? || "d"
#     end
#   end

#   #################

#   class Vmodal < BaseNode; end

#   class VmHui < Vmodal; end # động từ `hội`

#   class VmNeng < Vmodal; end # động từ `năng`

#   class VmXiang < Vmodal; end # động từ `tưởng`

#   #################

#   # ameba:disable Metrics/CyclomaticComplexity
#   def self.verb_from_term(term : V2Term)
#     case term.tags[0][1]?
#     when nil then Verb.new(term)
#     when 'o' then VerbObject.new(term)
#     when 'n' then VerbNoun.new(term)
#     when 'd' then VerbAdvb.new(term)
#     when 'i' then IntrVerb.new(term)
#     when '2' then Verb2Obj.new(term)
#     when 'x' then VLinking.new(term)
#     when 'p' then VCompare.new(term)
#     when 'f' then VDircomp.new(term)
#     when 'm' then vmodal_from_term(term)
#     when '!' then special_verb_from_term(term)
#     else          Verb.new(term)
#     end
#   end

#   def self.vmodal_from_term(term : V2Term)
#     case term.key
#     when "会" then VmHui.new(term)
#     when "能" then VmNeng.new(term)
#     when "想" then VmXiang.new(term)
#     else          Vmodal.new(term)
#     end
#   end

#   def self.special_verb_from_term(term : V2Term)
#     case
#     when term.key.ends_with?('是')    then VShi.new(term)
#     when term.key.ends_with?('有')    then VYou.new(term)
#     when VLinking.has_key?(term.key) then VLinking.new(term)
#     when VCompare.has_key?(term.key) then VCompare.new(term)
#     when VDircomp.has_key?(term.key) then VDircomp.new(term)
#     else                                  Verb2Obj.new(term)
#     end
#   end
# end
