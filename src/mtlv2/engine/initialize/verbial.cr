module MtlV2::AST
  class Verbal < BaseNode; end

  class VShi < Verbal; end

  class VYou < Verbal; end

  # 动词 - verb - động từ
  class Verb < Verbal
    @[Flags]
    enum Flag
      DirCompl # Direction complement
      ResCompl # Result complement
      PotCompl # Potential complement
      QtiCompl # Quantity complement

      HasPzai
      HasUzhe
      HasUde3

      HasBu4
      HasUle
    end

    getter flag = Flag::None

    DIR_RE = /.+[下上出进回过起来去]/
    RES_RE = /[好完错晚坏饱清到走会懂见掉]/

    def initialize(term : V2Term, dic = 0, idx = 1)
      super(term, dic, idx)
      return if key.size < 2

      @flag |= Flag::HasPzai if key.includes?('在')
      @flag |= Flag::HasUzhe if key.includes?('着')
      @flag |= Flag::HasUde3 if key.includes?('得')

      @flag |= Flag::HasBu4 if key.includes?('不')
      @flag |= Flag::HasUle if key.includes?('了')

      @flag |= Flag::DirComp if key =~ DIR_RE
      @flag |= Flag::ResComp if key =~ RES_RE
    end
  end

  class VCombine < Verb; end

  class VCompare < Verb; end

  class VDircomp < Verb; end

  class Verb2Obj < Verb; end

  class IntrVerb < Verb; end

  class VerbObject < IntrVerb; end

  #########

  class VerbNoun < Mixed
    getter verb_val : String? = nil
    getter verb_tag : String = "v"

    getter noun_val : String? = nil
    getter noun_tag : String = "n"

    def initialize(term : V2Term, @dic = 0, @idx = 0)
      super(term, dic, idx)

      @adjt_val = term.vals[1]?
      @adjt_tag = term.tags[1]? || "v"

      @noun_val = term.vals[2]?
      @noun_tag = term.tags[2]? || "n"
    end

    # def as_noun
    # end
  end

  struct VerbAdvb < Mixed
    getter verb_val : String? = nil
    getter verb_tag : String = "v"

    getter advb_val : String? = nil
    getter advb_tag : String = "a"

    def initialize(term : V2Term, @dic = 0, @idx = 0)
      super(term, dic, idx)

      @adjt_val = term.vals[1]?
      @adjt_tag = term.tags[1]? || "v"

      @noun_val = term.vals[2]?
      @noun_tag = term.tags[2]? || "d"
    end
  end

  #################

  struct Vmodal < BaseNode; end

  struct VmHui < Vmodal; end # động từ `hội`

  struct VmNeng < Vmodal; end # động từ `năng`

  struct VmXiang < Vmodal; end # động từ `tưởng`

  #################

  # ameba:disable Metrics/CyclomaticComplexity
  def self.verb_from_term(term : V2Term)
    case term.tags[0][1]?
    when nil then Verb.new(term)
    when 'o' then VerbObject.new(term)
    when 'n' then VerbNoun.new(term)
    when 'd' then VerbAdvb.new(term)
    when 'i' then IntrVerb.new(term)
    when '2' then Verb2Obj.new(term)
    when 'x' then VCombine.new(term)
    when 'p' then VCompare.new(term)
    when 'f' then VDircomp.new(term)
    when 'm' then init_vmodal(term)
    when '!' then initverb_special(term)
    else          Verb.new(term)
    end
  end

  def self.init_vmodal(key : ::String)
    case key
    when "会" then VmHui.new
    when "能" then VmNeng.new
    when "想" then VmXiang.new
    else          Vmodal.new
    end
  end

  def self.init_verb_special(key : String)
    case
    when key.ends_with?('是')            then VShi.new
    when key.ends_with?('有')            then VYou.new
    when MtDict.v2_objs.has_key?(key)   then Verb2Obj.new
    when MtDict.verb_dir.has_key?(key)  then VDircomp.new
    when MtDict.v_combine.has_key?(key) then VCombine.new
    when MtDict.v_compare.has_key?(key) then VCompare.new
    else                                     Verb.new
    end
  end
end
