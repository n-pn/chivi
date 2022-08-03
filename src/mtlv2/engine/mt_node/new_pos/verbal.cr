# require "./_base"

# module CV::POS
#   struct Verbal < ContentWord; end

#   struct VShi < Verbal; end

#   struct VYou < Verbal; end

#   # 动词 - verb - động từ
#   struct Verb < Verbal
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
#     end

#     getter flag = Flag::None

#     DIR_RE = /.+[下上出进回过起来去]/
#     RES_RE = /[好完错晚坏饱清到走会懂见掉]/

#     def initialize(key : String)
#       return if key.size < 2

#       @flag |= Flag::HasPzai if key.includes?('在')
#       @flag |= Flag::HasUzhe if key.includes?('着')
#       @flag |= Flag::HasUde3 if key.includes?('得')

#       @flag |= Flag::HasBu4 if key.includes?('不')
#       @flag |= Flag::HasUle if key.includes?('了')

#       @flag |= Flag::DirComp if key =~ DIR_RE
#       @flag |= Flag::ResComp if key =~ RES_RE
#     end
#   end

#   struct VCombine < Verb; end

#   struct VCompare < Verb; end

#   struct VDircomp < Verb; end

#   struct Verb2Obj < Verb; end

#   struct IntrVerb < Verb; end

#   struct VerbObject < IntrVerb; end

#   #################

#   # ameba:disable Metrics/CyclomaticComplexity
#   def self.init_verb(tag : String, key : String, val = [] of String)
#     case tag[1]?
#     when nil then Verb.new(key)
#     when 'o' then VerbObject.new(key)
#     when 'n' then VerbNoun.new(key, val)
#     when 'd' then VerbAdvb.new(key, val)
#     when 'i' then IntrVerb.new(key)
#     when '2' then Verb2Obj.new(key)
#     when 'x' then VCombine.new(key)
#     when 'p' then VCompare.new(key)
#     when 'f' then VDircomp.new(key)
#     when 'm' then init_vmodal(key)
#     when '!' then initverb_special(key)
#     else          Verb.new(key)
#     end
#   end

#   def self.init_verb_special(key : String)
#     case
#     when key.ends_with?('是')            then VShi.new
#     when key.ends_with?('有')            then VYou.new
#     when MtDict.v2_objs.has_key?(key)   then Verb2Obj.new
#     when MtDict.verb_dir.has_key?(key)  then VDircomp.new
#     when MtDict.v_combine.has_key?(key) then VCombine.new
#     when MtDict.v_compare.has_key?(key) then VCompare.new
#     else                                     Verb.new
#     end
#   end
# end
