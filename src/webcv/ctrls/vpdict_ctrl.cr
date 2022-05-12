require "./_base_ctrl"
require "../../libcv/vp_hint"

class CV::VpdictCtrl < CV::BaseCtrl
  alias VdInfo = Tuple(String, String?, Int32) # dict name, label, entries count

  getter core_dicts : Array(VdInfo) do
    dicts = [] of VdInfo

    dicts << {"regular", CtrlUtil.d_dub("regular"), VpDict.regular.size}
    dicts << {"essence", CtrlUtil.d_dub("essence"), VpDict.essence.size}
    dicts << {"fixture", CtrlUtil.d_dub("fixture"), VpDict.fixture.size}
    dicts << {"$hanviet", CtrlUtil.d_dub("hanviet"), VpDict.hanviet.size}
    dicts << {"$pin_yin", CtrlUtil.d_dub("pin_yin"), VpDict.pin_yin.size}
    dicts << {"$tradsim", CtrlUtil.d_dub("tradsim"), VpDict.tradsim.size}

    dicts
  end

  def index
    pgidx, limit, offset = params.page_info(min: 24, max: 40)

    input = VpDict.nvdicts
    book_dicts = [] of VdInfo

    input[offset, limit].each do |dname|
      book_dicts << {dname, CtrlUtil.d_dub(dname), VpDict.load(dname).size}
    end

    send_json({
      cores: core_dicts,
      books: book_dicts,
      total: input.size,
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(input.size, limit),
    })
  end

  def show
    dname = params["dname"]
    vdict = VpDict.load(dname)

    pgidx, limit, offset = params.page_info(min: 25, max: 50)

    total = offset + limit * 3
    terms = [] of VpTerm
    filter = VMatch.init(params)

    # TODO: provide cursor to search faster

    vdict.list.reverse_each do |term|
      next unless filter.match?(term)
      terms << term
      break if terms.size >= total
    end

    total = terms.size

    send_json({
      dname: dname,
      d_dub: CtrlUtil.d_dub(dname),
      dsize: vdict.size,

      total: total,
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(total, limit),

      start: offset &+ 1,
      terms: total > offset ? terms[offset, limit] : [] of VpTerm,
    })
  end

  alias Lookup = Hash(Symbol, Array(String))

  def lookup
    dname = params["dname"]
    dname = "combine" if dname == "generic"

    input = params["input"].strip
    range = params.json("range").as_a.map(&.as_i)

    vdict = {VpDict.load(dname), VpDict.regular}
    chars = input.chars

    entries = {} of Int32 => Array(Tuple(Int32, Lookup))

    range.each do |idx|
      entry = Hash(Int32, Lookup).new do |hash, key|
        hash[key] = Lookup.new { |h, k| h[k] = [] of String }
      end

      vdict.each do |dict|
        dict.scan(chars, "!#{_cvuser.uname}", idx) do |term|
          dic = term.is_priv ? dict.type &+ 2 : dict.type

          value = "#{term.val.join("/")}\t#{term.ptag.to_str}\t#{dic}"
          entry[term.key.size][:vietphrase] << value
        end
      end

      VpHint.trungviet.scan(chars, idx: idx) do |key, vals|
        entry[key.size][:trungviet] = vals
      end

      VpHint.cc_cedict.scan(chars, idx: idx) do |key, vals|
        entry[key.size][:cc_cedict] = vals
      end

      VpHint.trich_dan.scan(chars, idx: idx) do |key, vals|
        entry[key.size][:trich_dan] = vals
      end

      entries[idx] = entry.to_a.sort_by(&.[0].-)
    end

    send_json(entries)
  end

  def find_node(dict, key)
    dict.trie.find(key)
  end
end
