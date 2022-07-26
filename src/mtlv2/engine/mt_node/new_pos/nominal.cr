module CV::MtlV3::POS
  class Ptitle < BaseNode
    getter template : String = ""
    getter sub_title : Ptitle? = nil

    def initialize(term : VpTerm, dic : Int32, idx : Int32)
      super(term, dic, idx)
      @kind = Kind::Human

      @template = term.val[1]? || "? " + term.val[0]
    end

    def is_sub_title?
      false
    end

    def fold!(succ : Ptitle) : self
      if !@sub_title && succ.is_sub_title?
        @template = succ.template.sub("?", @template)
        @sub_title = succ
        self.set_succ(succ.succ)
      end

      fold!(self.succ)
    end
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
