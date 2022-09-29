require "./_ctrl_base"
require "../vh_dict"

class VH::HomeCtrl < VH::BaseCtrl
  base "/_vh"

  @[AC::Route::GET("/lookup")]
  def lookup(input : String, range : Array(Int32))
    entries = {} of Int32 => Array(Tuple(Int32, Lookup))
    chars = input.chars

    range.each do |idx|
      entry = Hash(Int32, Lookup).new { |hash, key| hash[key] = Lookup.new }

      VhDict.all_dicts.scan(chars, idx: idx) do |key, vals|
        entry[key.size][:all_dicts] = vals
      end

      VhDict.trungviet.scan(chars, idx: idx) do |key, vals|
        entry[key.size][:trungviet] = vals
      end

      VhDict.cc_cedict.scan(chars, idx: idx) do |key, vals|
        entry[key.size][:cc_cedict] = vals
      end

      VhDict.trich_dan.scan(chars, idx: idx) do |key, vals|
        entry[key.size][:trich_dan] = vals
      end

      entries[idx] = entry.to_a.sort_by(&.[0].-)
    end

    render json: entries
  end
end
