require "../_generics"

module MtlV2::MTL
  @[Flags]
  enum AdjtFlag : UInt8
    Adverbial  # adjective that can act as verb adverb without de2
    VerbSuffix # when combine with verb always places after

    Modifier   # adjective that can act as noun modifier without de1
    NounPrefix # when combine with noun always places before

    # word that act like adjective but do not combine with adverbs
    # can only combine with noun/verb in present of particle de1/de2
    Adjtform

    Measure # can combine with measurement numeral after
    Nominal # adjective can act as nouns

    def self.from(tag : String, key : String) : self
      return flags(Modifier, NounPrefix) if key.in?("原", "所有")

      case tag[1]?
      when 'b'      then Modifier
      when 'z', 'f' then Adjtform
      else
        term.key.size < 2 ? Modifier | Adverbial : None
      end
    end
  end
end
