module MtlV2::MTL
  module VerbUtil
    COMPARE = {
      "如"  => "tựa",
      "像"  => "giống",
      "仿佛" => "giống",
      "宛若" => "giống",
      "好像" => "thật giống",
      "和"  => "giống",
    }

    HELPING = {
      "爱"   => "yêu",
      "喜欢"  => "thích",
      "避免"  => "tránh",
      "忍不住" => "không nhịn được",
      "加以"  => "tiến hành",
      "进行"  => "tiến hành",
      "予以"  => "ban cho",
      "着手"  => "lấy tay",
      "舍得"  => "nỡ bỏ",
    }

    DIRCOMP = {
      "上"  => "lên",
      "下"  => "xuống",
      "进"  => "vào",
      "出"  => "ra",
      "过"  => "qua",
      "去"  => "đi",
      "回"  => "trở về",
      "起"  => "lên",
      "来"  => "tới",
      "上来" => "đi đến",
      "上去" => "đi lên",
      "下来" => "lại",
      "下去" => "xuống",
      "进来" => "tiến đến",
      "进去" => "đi vào",
      "出来" => "đi ra",
      "出去" => "ra ngoài",
      "过来" => "qua tới",
      "过去" => "qua",
      "回来" => "trở về",
      "回去" => "trở lại",
      "起来" => "lên",
    }
  end

  @[Flags]
  enum VerbAttr
    # shared
    DirCompl # Direction complement
    ResCompl # Result complement
    PotCompl # Potential complement
    QtiCompl # Quantity complement

    HasPzai
    HasUzhe
    HasUde3

    HasBu4
    HasUle

    Need0Obj
    Need2Obj

    HelpVerb
    LinkVerb

    # unique

    VerbObjt
    IntrVerb
    MoodVerb

    VDircomp
    VCompare

    def self.from_tag(tag : String)
      case tag[1]
      when 'o' then VerbObjt | Need0Obj
      when 'i' then IntrVerb | Need0Obj
      when '2' then Need2Obj
      when 'x' then HelpVerb
      when 'p' then VCompare
      when 'f' then VDircomp
      when 'm' then MoodVerb | HelpVerb
      when '!'
      else None
      end
    end

    def self.from_key(key : String, attr = None)
      attr |= HasPzai if key.ends_with?('在')
      attr |= HasUzhe if key.ends_with?('着')
      attr |= HasUde3 if key.ends_with?('得')

      attr |= HasBu4 if key.includes?('不')
      attr |= HasUle if key.includes?('了')

      attr |= DirCompl if key =~ /.+[下上出进回过起来去]/
      attr |= ResCompl if key =~ /[好完错晚坏饱清到走会懂见掉]/

      attr
    end
  end

  module Verbal
    getter attr = VerbAttr::None
    forward_missing_to @attr
  end

  class VShiWord < BaseWord
    include Verbal
  end

  class VYouWord < BaseWord
    include Verbal
  end

  # 动词 - verb - động từ
  class VerbWord < BaseWord
    include Verbal

    def initialize(term : V2Term, pos : String)
      super(term, pos)

      @attr = VerbAttr.from_tag(term.tags[pos]? || "v")
      @attr = VerbAttr.from_key(@key, @attr) if @key.size > 1
    end
  end

  # class VDircomp < Verb
  #   def self.has_key?(key : String)
  #     MAP_VAL.has_key?(key)
  #   end
  # end

  # class Verb2Obj < Verb
  #   def initialize(term : V2Term)
  #     super(term)
  #     @flag |= Flag::Need2Obj
  #   end
  # end

  # class IntrVerb < Verb
  #   def initialize(term : V2Term)
  #     super(term)
  #     @flag |= Flag::Need0Obj
  #   end
  # end

  # class VerbObject < IntrVerb; end

  #########

  class VerbNoun < BaseWord
    getter verb : VerbWord { VerbWord.new(@key, @val, @tab, @idx) }
    getter noun : NounWord { NounWord.new(@key, @val, @tab, @idx) }

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)

      @noun = MTL.noun_from_term(term, pos &* 2 + 1)
      @verb = MTL.verb_from_term(term, pos &* 2 + 2)
    end

    def as_noun!
      self.as!(self.noun)
    end

    def as_verb!
      self.as!(self.verb)
    end
  end

  class VerbAdvb < BaseWord
    getter verb : VerbWord { VerbWord.new(@key, @val, @tab, @idx) }
    getter advb : AdvbWord { NounWord.new(@key, @val, @tab, @idx) }

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)

      @advb = MTL.advb_from_term(term, pos &* 2 + 1)
      @verb = MTL.verb_from_term(term, pos &* 2 + 2)
    end

    def as_advb!
      self.as!(self.advb)
    end

    def as_verb!
      self.as!(self.verb)
    end
  end

  #################

  class VmHui < VerbWord
    # động từ `hội`
  end

  class VmNeng < VerbWord
    # động từ `năng`
  end

  class VmXiang < VerbWord
    # động từ `tưởng`
  end

  #################

  def self.verb_from_term(term : V2Term, pos = 0)
    tag = term.tags[pos]? || "v"
    return VerbWord.new(term, pos: pos) unless tag[1]? == '!'

    case term.key
    when "会"                      then VmHui.new(term, pos)
    when "能"                      then VmNeng.new(term, pos)
    when "想"                      then VmXiang.new(term, pos)
    when term.key.ends_with?('是') then VShiWord.new(term, pos)
    when term.key.ends_with?('有') then VYouWord.new(term, pos)
    else                               VerbWord.new(term, pos)
    end
  end
end
