require "./_generic"

module MT::MTL
  # 代词 - pronoun - đại từ chưa phân loại
  class PronounWord < BaseWord
    def noun_prefix?
      true
    end
  end

  # 人称代词 - personal pronoun - đại từ nhân xưng
  class PersproWord < PronounWord
  end

  # 自己
  class ProZiji < PersproWord
  end

  # 指示代词 - demonstrative pronoun - đại từ chỉ thị
  class DemsproWord < PronounWord
    def noun_prefix?
      true
    end
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

    def noun_prefix?
      false
    end
  end

  class ProNa1 < DemsproWord
    def heal!(succ = @succ) : Nil
      @val = "vậy" unless succ.is_a?(Verbal)
    end

    def noun_prefix?
      false
    end
  end

  class ProJi3 < DemsproWord
  end

  # 疑问代词 - interrogative pronoun - đại từ nghi vấn
  class IntrproWord < PronounWord
  end

  class ProNa2 < IntrproWord
    def noun_prefix?
      false
    end
  end
end
