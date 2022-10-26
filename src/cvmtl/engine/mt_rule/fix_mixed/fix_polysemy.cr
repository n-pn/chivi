module MT::Core
  def fix_polysemy!(node : MonoNode)
    fixer = FixPolysemy.new(node)
    fixer = fixer.guess_by_succ
    fixer = fixer.guess_by_prev
    fixer.resolve!
  end

  private struct FixPolysemy
    getter noun_pct = 0 # percentage of node being noun
    getter advb_pct = 0 # percentage of node being advb
    getter verb_pct = 0 # percentage of node being verb
    getter adjt_pct = 0 # percentage of node being adjt

    getter noun_alt : String? = nil
    getter advb_alt : String? = nil
    getter verb_alt : String? = nil
    getter adjt_alt : String? = nil

    def initialize(@node : MonoNode)
      case node.tag
      when .verb_or_noun?
        @verb_pct = 50
        @noun_pct = 40
        @noun_alt = node.alt
      when .adjt_or_noun?
        @adjt_pct = 50
        @noun_pct = 40
        @noun_alt = node.alt
      when .verb_or_advb?
        @verb_pct = 50
        @advb_pct = 40
        @advb_alt = node.alt
      when .adjt_or_advb?
        @adjt_pct = 50
        @advb_pct = 40
        @advb_alt = node.alt
      when .noun_or_advb?
        @noun_pct = 50
        @advb_pct = 40
        @advb_alt = node.alt
      else
        @noun_pct = 20
        @verb_pct = 10
        @adjt_pct = 0
        @advb_pct = -10
      end
    end

    # ameba:disable Metrics/CyclomaticComplexity
    def guess_by_succ
      case @node.real_succ
      when .nil?, .boundary?, .empty?
        @advb_pct -= 10
      when .noun_words?, .all_prons?
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
      when .aspect_marker?, .vdir?
        @verb_pct += 50
        @adjt_pct += 30
      when .maybe_cmpl?
        @verb_pct += 40
        @adjt_pct += 20
      when .prep_zai?
        @verb_pct += 30
        @noun_pct += 10
      when .advb_words?, .preposes?
        @advb_pct += 40
      when .maybe_auxi?
        @advb_pct += 60
      when .adjt_words?
        @advb_pct += 40
        @adjt_pct += 30
      when .ptcl_dev?
        @verb_pct += 30
        @adjt_pct += 30
        @noun_pct += 10
      when .ptcl_der?
        @verb_pct += 20
        @adjt_pct += 20
      when .ptcl_dep?, .ptcl_dec?
        @verb_pct += 20
        @adjt_pct += 20
        @noun_pct += 5
      when .ptcl_deg?
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
      when .ptcl_dev?
        @verb_pct += 80
        @adjt_pct += 50
      when .ptcl_dep?
        @noun_pct += 60
        @verb_pct += 10
        @adjt_pct += 10
      when .ptcl_der?
        @advb_pct += 20
        @adjt_pct += 30
        @verb_pct += 10
      when .maybe_auxi?
        @verb_pct += 40
        @noun_pct += 10
      when .common_verbs?
        @noun_pct += 40
        @adjt_pct += 5
      when .noun_words?, .per_prons?, .int_prons?
        @verb_pct += 50
        @adjt_pct += 40
      when .prep_zai?
        @verb_pct += 30
        @noun_pct += 5
      end

      self
    end

    def resolve! : MonoNode
      case resolve_type!
      when .noun?
        @node.as_noun!(@noun_alt)
      when .verb?
        @node.as_verb!(@verb_alt)
      when .adjt?
        @node.as_adjt!(@adjt_alt)
      when .advb?
        @node.as_advb!(@advb_alt)
      end

      @node
    end

    enum Type
      Noun; Verb; Adjt; Advb
    end

    # ameba:disable Metrics/CyclomaticComplexity
    private def resolve_type! : Type
      # puts [@noun_pct, @verb_pct, @adjt_pct, @advb_pct]

      case @node.tag
      when .noun_or_advb?
        @noun_pct >= @advb_pct ? Type::Noun : Type::Advb
      when .verb_or_advb?
        @verb_pct >= @advb_pct ? Type::Verb : Type::Advb
      when .adjt_or_advb?
        @adjt_pct >= @advb_pct ? Type::Adjt : Type::Advb
      when .verb_or_noun?
        @verb_pct >= @noun_pct ? Type::Verb : Type::Noun
      when .adjt_or_noun?
        @adjt_pct >= @noun_pct ? Type::Adjt : Type::Noun
      else
        [
          {-@noun_pct, Type::Noun},
          {-@verb_pct, Type::Verb},
          {-@adjt_pct, Type::Adjt},
          {-@advb_pct, Type::Advb},
        ].sort.first.last
      end
    end
  end
end
