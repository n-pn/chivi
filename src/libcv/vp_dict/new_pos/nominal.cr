require "./_base"

module CV::POS
  struct Noun < Base
    include Content
    include Objects

    include Nominal
  end

  struct Person < Base
    include Content
    include Objects

    include Nominal
    include NProper

    include Humankind
  end

  struct Ptitle < Base
    include Content
    include Objects

    include Nominal

    include Humankind
  end

  struct AffilName < Base
    include Content
    include Objects

    include Nominal
    include NProper

    include Attribute
    include Placement
  end

  struct PlaceName < AffilName; end

  struct InstiName < AffilName; end

  struct BookTitle < Base
    include Content
    include Objects

    include Nominal
    include NProper
  end

  struct OtherName < Base
    include Content
    include Objects

    include Nominal
    include NProper
  end

  struct BookTitle < OtherName; end

  struct Nattr < Base
    include Content
    include Objects

    include Nominal

    include Attribute
  end

  struct Space < Base
    include Content
    include Objects

    include Nominal

    include Attribute
    include Placement
  end

  struct Locat < Base
    include Content
    include Objects

    include Nominal

    include Attribute
  end

  struct LocatVerb < Locat
    include Verbal
    include Special

    getter verb_val : String

    def initialize(key : String)
      case key
      when "上" then @verb_val = "lên"
      when "下" then @verb_val = "xuống"
      when "中" then @verb_val = "trúng"
      else          raise "Invalid locat_verb #{key}"
      end
    end
  end

  struct Timeword < Base
    include Content
    include Objects

    include Nominal

    include Attribute
    include Temporal
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init_noun(tag : String, key : String)
    case tag[1]?
    when nil then Noun.new
    when 'a' then Nattr.new
    when 'r' then Person.new
    when 'f' then Person.new
    when 'w' then Ptitle.new
    when 'n' then AffilName.new
    when 's' then PlaceName.new
    when 't' then IntsiName.new
    when 'x' then BookTitle.new
    when 'z' then OtherName.new
      # when 'l' then NounPhrase.new
    else Noun.new
    end
  end

  def self.init_locat(key : String)
    key.in?("上", "下", "中") ? LocatVerb.new(key) : Locat.new(key)
  end
end
