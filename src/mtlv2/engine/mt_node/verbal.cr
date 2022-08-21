require "./nominal"
require "./adverbial"

module MtlV2::MTL
  @[Flags]
  enum VerbAttr
    # shared
    DirCompl # Direction complement
    ResCompl # Result complement
    PotCompl # Potential complement
    QtiCompl # Quantity complement

    # HasPzai
    HasUzhe
    # HasUde3
    # HasBu4
    HasUle

    Basic
    Chain # serial-verb
    Req2O # need 2 objects

    # Auxil
    Intrv # intransitive
    Mixed # both intra + trans
    Vobjt # verb + object pair

    def needs_obj?
      value & (Intrv | Vobjt) == 0
    end

    def not_needs_obj?
      value & (Intrv | Mixed | Vobjt) != 0
    end

    def self.from(tag : String, key : String) : self
      case tag[1]?
      when nil then from_key(key)
      when 'o' then Vobjt
      when 'i' then Intrv
      when 'j' then Mixed
      when '2' then Req2O
      else          None
      end
    end

    def self.from_key(key : String)
      attr = self.can_chain?(key) ? Chain : None
      return attr if key.size == 1

      case key[-1]?
      when '了' then attr | HasUle
        # when '在' then attr |= HasPzai
        # when '得' then attr |= HasUde3
      when '着' then attr | HasUzhe | Chain
      when '下', '上', '出', '进', '回',
           '过', '起', '来', '去'
        attr | DirCompl
      when '好', '完', '错', '晚', '坏',
           '饱', '清', '到', '走', '会',
           '懂', '见', '掉'
        attr | ResCompl
      else
        attr
      end
    end

    def self.can_chain?(key : String)
      {'来', '去', '到', '出'}.includes?(key[0])
    end
  end

  module Verbal
    getter attr = VerbAttr::None
    forward_missing_to @attr

    def self.from_term(term : V2Term, pos = 0)
      tag = term.tags[pos]? || "v"
      case tag[1]?
      when 'p' then VcmpWord.new(term, pos)
      when 'f' then VdirWord.new(term, pos)
      when 'm' then VmodWord.new(term, pos)
      when 'x' then VauxWord.new(term, pos)
      when 'j' then VmixWord.new(term, pos)
      when '!' then unique_verb(term, pos)
      else          VerbWord.new(term, pos)
      end
    end

    def self.unique_verb(term : V2Term, pos = 0)
      case term.key[-1]?
      when '会' then VmodHui.new(term, pos)
      when '能' then VmodNeng.new(term, pos)
      when '想' then VmodXiang.new(term, pos)
      when '是' then VShiWord.new(term, pos)
      when '有' then VYouWord.new(term, pos)
      else          VerbWord.new(term, pos)
      end
    end
  end

  # 动词 - verb - động từ
  class VerbWord < BaseWord
    include Verbal

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      tag = term.tags[pos]? || "v"
      @attr = VerbAttr.from(tag, term.key)
    end
  end

  class VmixWord < VerbWord
    @trans_val : String

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @trans_val = term.vals[pos &+ 1]? || @val
    end

    def as_trans!
      @val = @trans_val
      self
    end
  end

  class VdirWord < VerbWord
    # MAP_VAL = {
    #   "上"  => "lên",
    #   "下"  => "xuống",
    #   "进"  => "vào",
    #   "出"  => "ra",
    #   "过"  => "qua",
    #   "去"  => "đi",
    #   "回"  => "trở về",
    #   "起"  => "lên",
    #   "来"  => "tới",
    #   "上来" => "đi đến",
    #   "上去" => "đi lên",
    #   "下来" => "lại",
    #   "下去" => "xuống",
    #   "进来" => "tiến đến",
    #   "进去" => "đi vào",
    #   "出来" => "đi ra",
    #   "出去" => "ra ngoài",
    #   "过来" => "qua tới",
    #   "过去" => "qua",
    #   "回来" => "trở về",
    #   "回去" => "trở lại",
    #   "起来" => "lên",
    # }

    include Verbal
    @dir_val : String

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @attr |= VerbAttr::Chain if VerbAttr.can_chain?(term.key)

      @dir_val = term.vals[pos &+ 1]? || @val
    end

    def as_dir!
      @val = @dir_val
    end
  end

  class VcmpWord < VerbWord
    # COMPARE = {
    #   "如"  => "tựa",
    #   "像"  => "giống",
    #   "仿佛" => "giống",
    #   "宛若" => "giống",
    #   "好像" => "thật giống",
    # }

    @cmp_val : String

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @cmp_val = term.vals[pos &+ 1]? || @val
    end

    def as_cmp!
      @val = @cmp_val
    end
  end

  class VauxWord < VerbWord
    # 形式动词 - pro-verb - động từ hình thái

    # HELPING = {
    #   "爱"   => "yêu",
    #   "喜欢"  => "thích",
    #   "避免"  => "tránh",
    #   "加以"  => "tiến hành",
    #   "进行"  => "tiến hành",
    #   "予以"  => "ban cho",
    #   "着手"  => "lấy tay",
    #   "舍得"  => "nỡ bỏ",
    #   "忍不住" => "không nhịn được",
    # }

    @aux_val : String

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @aux_val = term.vals[pos &+ 1]? || @val
    end

    def as_aux!
      @val = @aux_val
    end
  end

  class VmodWord < VerbWord
    include Verbal

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
    end
  end

  class VmodHui < VmodWord
  end

  class VmodNeng < VmodWord
    # động từ `năng`
  end

  class VmodXiang < VmodWord
    # động từ `tưởng`
  end

  #################

  class VShiWord < BaseWord
    include Verbal
  end

  class VYouWord < BaseWord
    include Verbal
  end
end
