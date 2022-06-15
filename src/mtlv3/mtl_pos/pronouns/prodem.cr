require "./pronoun"

module CV::MtlV3::POS
  class DemPron < Pronoun
  end

  class ProZhe < DemPron
    def heal!(succ = @succ) : Nil
      case succ
      when Verbal
        @val = "đây"
      when Punct
        return unless (succ.comma?) && (succ_2 = succ.succ?)
        # TODO: add more case here
        @val = succ_2.is_a?(ProZhe) ? "đây" : "cái này"
      when Nil, Prepos
        @val = "cái này"
      else
        @val = @prev.is_a?(Nominal) ? "giờ" : "cái này"
      end
    end
  end

  class ProNa1 < DemPron
    def heal!(succ = @succ) : Nil
      @val = "vậy" unless succ.is_a?(Verbal)
    end
  end
end
