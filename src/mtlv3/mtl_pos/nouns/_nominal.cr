require "../_base"

module CV::MtlV3::POS
  extend self

  class Nominal < BaseNode
    @[Flags]
    enum Kind
      Names
      Human
      Place
      Attri
    end

    getter kind = Kind::None
  end

  class NounForm < Nominal
    getter prodem : Prodem? = nil
    getter nquant : Nquant? = nil

    getter defn : DefnPhrase? = nil

    getter noun : Nominal

    getter locat : Locat
  end

  class Person < BaseNode
    getter has_ptitle = false
    getter ptitle : Ptitle?
    getter person : Person?

    def initialize(term : VpTerm, dic : Int32, idx : Int32)
      super(term, dic, idx)
      @kind = Kind.flags(Human, Names)
      @has_ptitle = @val != @val.titleize && @val != @val.downcase
    end

    def fold!(succ : Ptitle) : self
      if ptitle = @ptitle
        @ptitle = ptitle.fold!(succ)
        @has_ptitle = true
      elsif !has_ptitle || succ.is_sub_title?
        @ptitle = succ
        @has_ptitle = true
        self.set_succ(succ.succ)
      end

      fold!(self.succ)
    end

    def fold!(succ : Person) : self
      if !@person && succ.has_ptitle
        @person = succ
        self.set_succ(succ.succ)
      end

      fold!(self.succ)
    end
  end
end
