require "./engine/*"

module MtlV2
  class Engine
    class_getter hanviet_mtl : MTL::MtCore { init([V2Dict.essence, V2Dict.hanviet]) }
    class_getter pin_yin_mtl : MTL::MtCore { init([V2Dict.essence, V2Dict.pin_yin]) }
    class_getter tradsim_mtl : MTL::MtCore { init([V2Dict.tradsim]) }

    def self.generic_mtl(bname = "combine", uname = "") : MTL::MtCore
      dicts = [V2Dict.essence, V2Dict.regular, V2Dict.load(bname)]
      init(dicts, uname)
    end

    def self.load(dname : String, uname : String = "") : self
      case dname
      when "pin_yin"          then pin_yin_mtl
      when "hanviet"          then hanviet_mtl
      when "tradsim"          then tradsim_mtl
      when .starts_with?('-') then generic_mtl(dname, uname)
      else                         generic_mtl("combine", uname)
      end
    end

    def self.init(dicts : Array(V2Dict), uname : String = "")
      MTL::MtCore.new(dicts, uname)
    end

    def self.cv_pin_yin(input : String) : String
      pin_yin_mtl.translit(input).to_txt
    end

    def self.cv_hanviet(input : String, apply_cap = true) : String
      return input unless input =~ /\p{Han}/
      hanviet_mtl.translit(input, apply_cap: apply_cap).to_txt
    end

    def self.trad_to_simp(input : String) : String
      tradsim_mtl.tokenize(input.chars).to_txt
    end

    def self.convert(input : String, dname = "combine") : String
      case dname
      when "hanviet" then hanviet_mtl.translit(input).to_txt
      when "pin_yin" then pin_yin_mtl.translit(input).to_txt
      when "tradsim" then tradsim_mtl.tokenize(input.chars).to_txt
      else                generic_mtl(dname).cv_plain(input).to_txt
      end
    end
  end
end
