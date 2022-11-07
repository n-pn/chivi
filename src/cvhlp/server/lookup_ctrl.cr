require "./_shared"
require "../models/lu_dict"

class TL::LookupCtrl < TL::BaseCtrl
  base "/_mh"

  class LookupInput
    include JSON::Serializable
    getter input : String
    getter range : Array(Int32)
  end

  @[AC::Route::PUT("/lookup", body: :req)]
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
        jb.field "Dữ liệu Vietphrase", @top_terms
        jb.field "Từ điển Trung Việt", @trungviet
        jb.field "Từ điển CC-CEDICT", @cc_cedict
        jb.field "Từ điển Trích dẫn", @trich_dan
      end
    end
  end

  private def scan_terms(chars : Array(Char), start : Int32)
    entry = Hash(Int32, LuTerms).new { |hash, key| hash[key] = LuTerms.new }

    LuDict.top_terms.scan(chars, start: start) do |word, defn|
      entry[word.size].top_terms = defn.gsub("\v", "; ")
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
