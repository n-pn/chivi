# require "../v2dict/vp_term"
# require "./mt_util"
# require "./base_node/*"

# @[Flags]
# enum MtFlag
#   Uncheck
#   Checked
#   Resolved

#   NeedObj
#   Need2Obj

#   HasVdir

#   HasPreZai
#   HasUzhe
#   HasUle
#   HasUde3

#   HasQtGe4 # has 个
# end

# module MtlV2
#   class BaseNode
#     property idx : Int32 = 0
#     property dic : Int32 = 0

#     property key : String = ""
#     property val : String = ""
#     property tag : PosTag = PosTag::None

#     property! prev : BaseNode
#     property! succ : BaseNode

#     property! root : BaseNode
#     property! body : BaseNode

#     property flag : MtFlag = MtFlag::None

#     forward_missing_to @tag

#     def initialize(@key = "", @val = @key, @tag = PosTag::None, @dic = 0, @idx = 0)
#     end

#     def initialize(term : V2Term, @dic : Int32 = 0, @idx = 0)
#       @key = term.key
#       @val = term.val.first
#       @tag = term.ptag
#     end

#     def initialize(char : Char, @idx = -1)
#       @key = @val = char.to_s
#       @tag =
#         case char
#         when ' ' then PosTag::Punct
#         when '_' then PosTag::Litstr
#         else
#           char.alphanumeric? ? PosTag::Litstr : PosTag::None
#         end
#     end

#     def flag!(flag : MtFlag) : self
#       @flag |= flag
#       self
#     end

#     def flag!(flag : Symbol) : self
#       flag!(MtFlag.parse(flag.to_s))
#       # raise "Unknown flag #{flag}"
#     end

#     def blank?
#       @key.empty? || @val.blank?
#     end

#     #############

#     def set_prev(@prev : BaseNode) : BaseNode
#       prev.succ = self
#       self
#     end

#     def set_prev(@prev : Nil) : BaseNode
#       self
#     end

#     def set_succ(@succ : BaseNode) : BaseNode
#       succ.prev = self
#       self
#     end

#     def set_succ(@succ : Nil) : BaseNode
#       self
#     end

#     ##########

#     def prev?
#       @prev.try { |x| yield x }
#     end

#     def succ?
#       @succ.try { |x| yield x }
#     end

#     def body?
#       @body.try { |x| yield x }
#     end

#     def set_body!(node : BaseNode) : Nil
#       self.body = node
#       self.fix_root!(node.root?)
#       node.root = self
#     end

#     def fix_root!(@root : BaseNode?) : Nil
#     end

#     def set_prev!(@prev : Nil) : Nil
#     end

#     def set_prev!(node : BaseNode) : Nil
#       node.fix_prev!(@prev)
#       self.fix_prev!(node)
#     end

#     def set_succ!(@succ : Nil) : Nil
#     end

#     def set_succ!(node : BaseNode) : Nil
#       node.fix_succ!(@succ)
#       self.fix_succ!(node)
#     end

#     def fix_prev!(@prev : Nil) : Nil
#     end

#     def fix_prev!(@prev : self) : Nil
#       prev.succ = self
#     end

#     def fix_succ!(@succ : Nil) : Nil
#       self
#     end

#     def fix_succ!(@succ : self) : Nil
#       succ.prev = self
#     end

#     def set!(@val : String) : self
#       self
#     end

#     def set!(@tag : PosTag) : self
#       self
#     end

#     def set!(@val : String, @tag : PosTag) : self
#       self
#     end

#     #######

#     # -ameba:disable Metrics/CyclomaticComplexity

#     def fold!(succ = self.succ?) : BaseNode
#       self

#       # case @tag
#       # when .puncts?    then TlRule.fold_puncts!(self)
#       # when .mixed?     then TlRule.fold_mixed!(self)
#       # when .special?   then TlRule.fold_specials!(self)
#       # when .preposes?  then TlRule.fold_preposes!(self)
#       # when .strings?   then TlRule.fold_strings!(self)
#       # when .adverbial? then TlRule.fold_adverbs!(self)
#       # when .auxils?    then TlRule.fold_auxils!(self)
#       # when .pronouns?  then TlRule.fold_pronouns!(self)
#       # when .temporal?  then TlRule.fold_temporal!(self)
#       # when .numeral?   then TlRule.fold_number!(self)
#       # when .modifier?  then TlRule.fold_modifier!(self)
#       # when .adjective? then TlRule.fold_adjts!(self)
#       # when .vmodals?   then TlRule.fold_vmodals!(self)
#       # when .verbal?    then TlRule.fold_verbs!(self)
#       # when .locative?  then TlRule.fold_space!(self)
#       # when .nominal?   then TlRule.fold_nouns!(self)
#       # when .onomat?    then TlRule.fold_onomat!(self)
#       # else                  self
#       # end
#     end
#   end
# end
