module MtlV2::AST
  enum AuxilType
    Ule
    Uzhi
    Uzhe
    Uguo
    Usuo
    Ude1
    Ude2
    Ude3
    Udeng
    Uyy
    Udh
    Uls
    Ulian
    Other

    # ameba:disable Metrics/CyclomaticComplexity
    def self.from_key(key : String)
      case key
      when "了", "喽"               then Ule
      when "之"                    then Uzhi
      when "着"                    then Uzhe
      when "过"                    then Uguo
      when "的", "底"               then Ude1
      when "地"                    then Ude2
      when "得"                    then Ude3
      when "所"                    then Usuo
      when "云云"                   then Udeng
      when "等"                    then Udeng1
      when "等等"                   then Udeng2
      when "一样", "一般", "似的", "般"  then Uyy
      when "的话"                   then Udh
      when "来讲", "来说", "而言", "说来" then Uls
      when "连"                    then Ulian
      else                             Other
      end
    end
  end

  class AuxilWord < BaseWord
    getter type : AuxilType

    def initialize(
      term : V2Term,
      type : AuxilType = AuxilType.from_key(term.key)
    )
      super(term)
    end
  end
end
