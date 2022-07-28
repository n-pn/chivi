require "../mt_base/*"

module MtlV2::MTL
  # 代词 - pronoun - đại từ chưa phân loại
  class PronounWord < BaseWord
  end

  # 人称代词 - personal pronoun - đại từ nhân xưng
  class PersproWord < PronounWord
  end

  # 自己
  class ProZiji < PersproWord
  end

  # 指示代词 - demonstrative pronoun - đại từ chỉ thị
  class DemsproWord < PronounWord
  end

  class ProZhe < DemsproWord
    def heal!(succ = @succ) : Nil
      case succ
      when Nil, Prepos
        @val = "cái này"
      when Verbal
        @val = "đây"
      when Comma
        if (zhe2 = succ.succ?) && zhe2.is_a?(ProZhe)
          zhe2.heal!
          @val = zhe2.val
        end
      else
        @val = "giờ" if @prev.is_a?(Nominal)
      end
    end
  end

  class ProNa1 < DemsproWord
    def heal!(succ = @succ) : Nil
      @val = "vậy" unless succ.is_a?(Verbal)
    end
  end

  class ProJi3 < DemsproWord
  end

  # 疑问代词 - interrogative pronoun - đại từ nghi vấn
  class IntrproWord < PronounWord
  end

  class ProNa2 < IntrproWord
  end

  ####

  def self.pronoun_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""

    case tag[1]?
    when 'z' then demspro_from_term(term, tag)
    when 'y' then intrpro_from_term(term, tag)
    when 'r' then perspro_from_term(term, tag)
    else          PronounWord.new(term, pos: pos)
    end
  end

  def self.demspro_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "这" then ProZhe.new(term, pos: pos)
    when "那" then ProNa1.new(term, pos: pos)
    when "几" then ProJi3.new(term, pos: pos)
    else          DemsproWord.new(term, pos: pos)
    end
  end

  def self.intrpro_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "哪" then ProNa2.new(term, pos: pos)
    else          IntrproWord.new(term, pos: pos)
    end
  end

  def self.perspro_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "自己" then ProZiji.new(term, pos: pos)
    else           PersproWord.new(term, pos: pos)
    end
  end
end
