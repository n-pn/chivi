require "./_nominal"

module CV::MtlV3::POS
  class Ptitle < Nominal
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
end
