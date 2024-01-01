require "./_sp_ctrl_base"
require "../data/wd_dict"
require "../data/wd_defn"

class SP::DefnCtrl < AC::Base
  base "/_sp"

  class LookupForm
    include JSON::Serializable
    getter input : String
    getter range : Array(Int32)
  end

  @[AC::Route::GET("/defns/:word")]
  def defn_word(word : String)
    render json: bing_lookup(word)
  end

  # FIXME: move this to somewhere else
  MS_DICT_UPSERT_QUERY = <<-SQL
    insert into defns (word, defn, mtime) values (?, ?, ?)
    on conflict do update set
      word = excluded.word,
      defn = excluded.defn,
      mtime = excluded.mtime
    where word = excluded.word
  SQL

  private def bing_lookup(word : String)
    # FIXME: only call bing api if _privi > 0

    WdDefn.open_db("bing_dict") do |db|
      query = "select defn from defns where word = ? limit 1"

      if defn = db.query_one?(query, word, as: String)
        Array(MsDict::Term::Tran).from_json(defn)
      else
        defn = MsDict.lookup([word]).first.translations
        db.exec MS_DICT_UPSERT_QUERY, word, defn.to_json, Time.utc.to_unix
        defn
      end
    end
  end

  @[AC::Route::PUT("/lookup", body: :form)]
  def defn_list(form : LookupForm)
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
