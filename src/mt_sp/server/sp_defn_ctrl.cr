require "./_sp_ctrl_base"
require "../data/wd_dict"

class SP::DefnCtrl < AC::Base
  base "/_sp"

  class LookupForm
    include JSON::Serializable
    getter input : String
    getter range : Array(Int32)
  end

  @[AC::Route::PUT("/lookup", body: :form)]
  def lookup(form : LookupForm)
    output = {} of Int32 => Array(Tuple(Int32, WdTerms))
    chars = form.input.chars

    form.range.each do |index|
      output[index] = scan_terms(chars, start: index)
    end

    render json: output
  end

  class WdTerms
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
    entry = Hash(Int32, WdTerms).new { |hash, key| hash[key] = WdTerms.new }

    WdDict.top_terms.scan(chars, start: start) do |word, defn|
      entry[word.size].top_terms = defn.gsub("\v", "; ")
    end

    WdDict.trungviet.scan(chars, start: start) do |word, defn|
      entry[word.size].trungviet = defn
    end

    WdDict.cc_cedict.scan(chars, start: start) do |word, defn|
      entry[word.size].cc_cedict = defn
    end

    WdDict.trich_dan.scan(chars, start: start) do |word, defn|
      entry[word.size].trich_dan = defn
    end

    entry.to_a.sort_by(&.[0].-)
  end
end
