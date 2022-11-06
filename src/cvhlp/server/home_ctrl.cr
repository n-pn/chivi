require "./_shared"
require "../models/lu_dict"

class TL::HomeCtrl < TL::BaseCtrl
  base "/_hl"

  class LookupInput
    include JSON::Serializable
    getter input : String
    getter range : Array(Int32)
  end

  @[AC::Route::GET("/lookup", body: :req)]
  def lookup(req : LookupInput)
    output = {} of Int32 => Array(Tuple(Int32, LuTerms))

    chars = req.input.chars
    req.range.each do |index|
      output[index] = scan_terms(chars, start: index)
    end

    render json: output
  end

  class LuTerms
    property top_terms : String? = nil
    property trungviet : String? = nil
    property cc_cedict : String? = nil
    property trich_dan : String? = nil

    def initialize
    end

    def to_json(jb : JSON::Builder)
      jb.object do
        jb.field "top_terms", @top_terms
        jb.field "trungviet", @trungviet
        jb.field "cc_cedict", @cc_cedict
        jb.field "trich_dan", @trich_dan
      end
    end
  end

  private def scan_terms(chars : Array(Char), start : Int32)
    entry = Hash(Int32, LuTerms).new { |hash, key| hash[key] = LuTerms.new }

    LuDict.top_terms.scan(chars, start: start) do |word, defn|
      entry[word.size].top_terms = defn
    end

    LuDict.trungviet.scan(chars, start: start) do |word, defn|
      entry[word.size].trungviet = defn
    end

    LuDict.cc_cedict.scan(chars, start: start) do |word, defn|
      entry[word.size].cc_cedict = defn
    end

    LuDict.trich_dan.scan(chars, start: start) do |word, defn|
      entry[word.size].trich_dan = defn
    end

    entry.to_a.sort_by(&.[0].-)
  end
end
