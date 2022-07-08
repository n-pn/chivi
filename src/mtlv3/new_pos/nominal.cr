require "./_base"

module CV::POS
  struct Noun < Objects; end

  struct ProperName < Noun; end

  struct Person < ProperName
    include Mankind
  end

  struct Ptitle < Noun
    include Mankind
  end

  module Attribute; end

  module Placement; end

  struct AffilName < ProperName
    include Attribute
    include Placement
  end

  struct PlaceName < AffilName; end

  struct InstiName < AffilName; end

  struct OtherName < ProperName; end

  struct BookTitle < OtherName; end

  struct Attrib < Noun
    include Attribute
  end

  struct Space < Noun
    include Attribute
    include Placement
  end

  struct Locat < Noun
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

  struct Ntime < Noun
    include Attribute
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.init_noun(tag : String, key : String)
    case tag[1]?
    when nil then Noun.new
    when 'r' then Person.new
    when 'n' then AffilName.new
    when 's' then PlaceName.new
    when 't' then IntsiName.new
    when 'z' then OtherName.new
    when 'x' then BookTitle.new
    when 'a' then Attrib.new
    when 'w' then Ptitle.new
    when 'f' then Person.new
      # when 'l' then NounPhrase.new
    else Noun.new
    end
  end

  def self.init_locat(key : String)
    key.in?("上", "下", "中") ? LocatVerb.new(key) : Locat.new(key)
  end
end
