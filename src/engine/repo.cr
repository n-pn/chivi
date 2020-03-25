require "./dict"

# Loading dicts
class Engine
  class Repo
    alias DictMap = Hash(String, Dict)
    alias UserMap = Hash(String, DictMap)

    def initialize(@root = ".dic")
      @dicts = {
        "system" => DictMap.new,
        "common" => DictMap.new,
        "unique" => DictMap.new,
      }

      @fixes = {
        "common" => UserMap.new { |h, k| h[k] = DictMap.new },
        "unique" => UserMap.new { |h, k| h[k] = DictMap.new },
      }
    end

    alias Dicts = Array(Dict)

    def cc_cedict
      @dicts["system"]["cc_cedict"] ||= load_dic(".", "cc_cedict")
    end

    def trungviet
      @dicts["system"]["trungviet"] ||= load_dic(".", "trungviet")
    end

    def hanviet
      @dicts["system"]["hanviet"] ||= load_dic(".", "hanviet")
    end

    def pinyin
      @dicts["system"]["pinyin"] ||= load_dic(".", "pinyin")
    end

    def tradsim
      @dicts["system"]["tradsim"] ||= load_dic(".", "tradsim")
    end

    def generic
      @dicts["common"]["generic"] ||= load_dic("common", "generic")
    end

    def generic(fix : String)
      @fixes["common"]["generic"][fix] ||= load_fix("common", "generic", fix)
      {generic, @fixes["common"]["generic"][fix]}
    end

    def combine
      @dicts["common"]["combine"] ||= load_dic("common", "combine")
    end

    def combine(fix : String)
      @fixes["common"]["combine"][fix] ||= load_fix("common", "combine", fix)
      {combine, @fixes["common"]["combine"][fix]}
    end

    def suggest
      @dicts["common"]["suggest"] ||= load_dic("common", "suggest")
    end

    def suggest(fix : String)
      @fixes["common"]["suggest"][fix] ||= load_fix("common", "suggest", fix)
      {suggest, @fixes["common"]["suggest"][fix]}
    end

    def unique(name : String)
      @dicts["unique"][name] ||= load_dic("unique", name)
    end

    def unique(name : String, fix : String)
      @fixes["unique"][name][fix] ||= load_fix("unique", name, fix)
      {unique(name), @fixes["unique"][name][fix]}
    end

    def load_dic(dir : String, name : String)
      Dict.new(File.join(@root, dir, "#{name}.dic"))
    end

    def load_fix(dir : String, name : String, user : String = "admin")
      Dict.new(File.join(@root, dir, "#{name}.#{user}.fix"))
    end
  end
end
