module CV::MTL
  struct FixPolysemy
    getter noun_pct = 0 # percentage of node being noun
    getter advb_pct = 0 # percentage of node being advb
    getter verb_pct = 0 # percentage of node being verb
    getter adjt_pct = 0 # percentage of node being adjt

    getter noun_alt : String? = nil
    getter advb_alt : String? = nil
    getter verb_alt : String? = nil
    getter adjt_alt : String? = nil

    def initialize(@node : BaseTerm)
      case node.tag
      when .pl_noad?
        @noun_pct = 50
        @advb_pct = 40
        @advb_alt = node.alt
      when .pl_vead?
        @verb_pct = 50
        @advb_pct = 40
        @advb_alt = node.alt
      when .pl_ajad?
        @adjt_pct = 50
        @advb_pct = 40
        @advb_alt = node.alt
      when .pl_veno?
        @verb_pct = 50
        @noun_pct = 40
        @noun_alt = node.alt
      when .pl_ajno?
        @adjt_pct = 50
        @noun_pct = 40
        @noun_alt = node.alt
      else
        @noun_pct = @node.maybe_noun? ? 40 : 20
        @verb_pct = @node.maybe_verb? ? 40 : 20
        @adjt_pct = @node.maybe_adjt? ? 40 : 20
        @advb_pct = @node.maybe_advb? ? 20 : 0
      end
    end

    # ameba:disable Metrics/CyclomaticComplexity
    def guess_by_succ
      case @node.real_succ
      when .nil?, .boundary?
        @advb_pct -= 10
      when .noun_words?, .pronouns?
        @advb_pct -= 20
        @noun_pct += 10
        @verb_pct += 20
        @adjt_pct += 20
      when .numbers?, .quantis?
        @advb_pct -= 30
        @verb_pct += 30
      when .qtverb?, .qttime?
        @verb_pct += 40
      when .v_shi?
        @advb_pct += 20
      when .v_you?
        @noun_pct += 10
        @noun_pct += 10
      when .aspect?, .vdir?
        @verb_pct += 50
        @adjt_pct += 30
      when .vcompl?
        @verb_pct += 40
        @adjt_pct += 20
      when .pre_zai?
        @verb_pct += 30
        @noun_pct += 10
      when .advb_words?, .preposes?
        @advb_pct += 40
      when .vauxil?
        @advb_pct += 60
      when .adjt_words?
        @advb_pct += 40
        @adjt_pct += 30
      when .pt_dev?
        @verb_pct += 30
        @adjt_pct += 30
        @noun_pct += 10
      when .pt_der?
        @verb_pct += 20
        @adjt_pct += 20
      when .pt_dep?, .pt_dec?
        @verb_pct += 20
        @adjt_pct += 20
        @noun_pct += 5
      when .pt_deg?
        @noun_pct += 100
      end

      self
    end

    # ameba:disable Metrics/CyclomaticComplexity
    def guess_by_prev : self
      case @node.real_prev
      when .nil?, .boundary?
        @advb_pct -= 10
      when .amod_words?
        @noun_pct += 50
        @adjt_pct += 40
      when .adjt_words?
        @noun_pct += 40
        @adjt_pct += 50
      when .pt_dev?
        @verb_pct += 80
        @adjt_pct += 50
      when .pt_dep?
        @noun_pct += 60
        @verb_pct += 10
        @adjt_pct += 10
      when .pt_der?
        @advb_pct += 20
        @adjt_pct += 30
        @verb_pct += 10
      when .vauxil?
        @verb_pct += 40
        @noun_pct += 10
      when .common_verbs?
        @noun_pct += 40
        @adjt_pct += 5
      when .noun_words?, .pro_pers?, .pro_int?
        @verb_pct += 50
        @adjt_pct += 40
      when .pre_zai?
        @verb_pct += 30
        @noun_pct += 5
      end

      self
    end

    def resolve! : BaseTerm
      _, type = [
        {-@noun_pct, 0},
        {-@verb_pct, 1},
        {-@adjt_pct, 2},
        {-@advb_pct, 3},
      ].sort.first

      case type
      when 0
        @noun_alt.try { |x| @node.val = x }
        @node.tag = PosTag.cast_noun(@node.key)
      when 1
        @verb_alt.try { |x| @node.val = x }
        @node.tag = PosTag.cast_verb(@node.key)
      when 2
        @adjt_alt.try { |x| @node.val = x }
        @node.tag = PosTag.cast_adjt(@node.key)
      else
        @advb_alt.try { |x| @node.val = x }
        @node.tag = PosTag.cast_advb(@node.key)
      end

      @node
    end
  end
end