require "./_base"

module CV::POS
  struct Verbal < ContentWord; end

  struct VShi < Verbal; end

  struct VYou < Verbal; end

  # 动词 - verb - động từ
  struct Verb < Verbal
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

    def initialize(key : String)
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

  struct VCombine < Verb; end

  struct VCompare < Verb; end

  struct VDircomp < Verb; end

  struct Verb2Obj < Verb; end

  struct IntrVerb < Verb; end

  struct VerbObject < IntrVerb; end

  #########

  struct VerbNoun < Polytag
    getter verb_val : String? = nil
    getter verb_tag : String = "v"

    getter noun_val : String? = nil
    getter noun_tag : String = "n"

    def initialize(@key : String, val : Array(String))
      if (verb_val = val[1]?) && !verb_val.empty?
        verb_val, verb_tag = verb_val.split(" \\", 2)
        @verb_val = verb_val unless verb_val.empty?
        @verb_tag = verb_tag unless verb_tag.empty?
      end

      if (noun_val = val[2]?) && !noun_val.empty?
        noun_val, noun_tag = noun_val.split(" \\", 2)
        @noun_val = noun_val unless noun_val.empty?
        @noun_tag = noun_tag unless noun_tag.empty?
      end
    end

    # def as_noun
    # end
  end

  struct VerbAdvb < PolyTag
    getter verb_val : String? = nil
    getter verb_tag : String = "v"

    getter advb_val : String? = nil
    getter advb_tag : String = "a"

    def initialize(@key : String, val : Array(String))
      if (verb_val = val[1]?) && !verb_val.empty?
        verb_val, verb_tag = verb_val.split(" \\", 2)
        @verb_val = verb_val unless verb_val.empty?
        @verb_tag = verb_tag unless verb_tag.empty?
      end

      if (advb_val = val[2]?) && !advb_val.empty?
        advb_val, advb_tag = advb_val.split(" \\", 2)
        @advb_val = advb_val unless advb_val.empty?
        @advb_tag = advb_tag unless advb_tag.empty?
      end
    end
  end

  #################

  struct Vmodal < ContentWord; end

  struct VmHui < Vmodal; end # động từ `hội`

  struct VmNeng < Vmodal; end # động từ `năng`

  struct VmXiang < Vmodal; end # động từ `tưởng`

  #################

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init_verb(tag : String, key : String, val = [] of String)
    case tag[1]?
    when nil then Verb.new(key)
    when 'o' then VerbObject.new(key)
    when 'n' then VerbNoun.new(key, val)
    when 'd' then VerbAdvb.new(key, val)
    when 'i' then IntrVerb.new(key)
    when '2' then Verb2Obj.new(key)
    when 'x' then VCombine.new(key)
    when 'p' then VCompare.new(key)
    when 'f' then VDircomp.new(key)
    when 'm' then init_vmodal(key)
    when '!' then initverb_special(key)
    else          Verb.new(key)
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
