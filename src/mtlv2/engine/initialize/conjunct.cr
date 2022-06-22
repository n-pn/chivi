module MtlV2::AST
  class Conjunct < BaseNode
    getter is_junct : Bool

    JUNCTS = {"但", "又", "或", "或是"}

    def initialize(term : V2Term)
      super(term)
      @is_junct = JUNCTS.includes?(term.key)
    end
  end

  class Concoord < Conjunct
    getter is_junct = true
  end

  def self.conjunct_from_term(term : V2Term)
    term.tags[0][1]? == 'c' ? Concoord.new(term) : Conjunct.new(term)
  end
end
