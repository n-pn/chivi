require "./_base_ctrl"

class CV::VpdictCtrl < CV::BaseCtrl
  alias VdInfo = Tuple(String, String?, Int32) # dict name, label, entries count

  getter core_dicts : Array(VdInfo) do
    dicts = [] of VdInfo

    dicts << {"regular", CtrlUtil.d_dub("regular"), VpDict.regular.size}
    dicts << {"hanviet", CtrlUtil.d_dub("hanviet"), VpDict.hanviet.size}
    dicts << {"essence", CtrlUtil.d_dub("essence"), VpDict.essence.size}
    dicts << {"fixture", CtrlUtil.d_dub("fixture"), VpDict.fixture.size}

    dicts
  end

  def index
    pgidx, limit, offset = params.page_info(min: 24, max: 40)

    input = VpDict.novels
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

    vdict.data.reverse_each do |term|
      next unless filter.match?(term)
      terms << term
      break if terms.size >= total
    end

    total = terms.size
    send_json({
      dname: dname,
      d_dub: CtrlUtil.d_dub(dname),
      total: total,
      pgidx: pgidx,
      start: offset + 1,
      pgmax: CtrlUtil.pgmax(total, limit),
      terms: total > offset ? terms[offset, limit] : [] of VpTerm,
    })
  end

  alias Lookup = Hash(Symbol, Array(String))

  def lookup
    dname = params["dname"]
    dname = "combine" if dname == "generic"

    input = params["input"].strip
    vdict = {VpDict.load(dname), VpDict.regular}

    chars = input.chars
    upper = chars.size - 1

    entries = (0..upper).map do |idx|
      entry = Hash(Int32, Lookup).new do |hash, key|
        hash[key] = Lookup.new { |h, k| h[k] = [] of String }
      end

      vdict.each do |dict|
        dict.scan(chars, "!#{_cvuser.uname}", idx) do |term|
          dic = term.is_priv ? dict.dtype &+ 2 : dict.dtype

          value = "#{term.val.join("/")}\t#{term.ptag.to_str}\t#{dic}"
          entry[term.key.size][:vietphrase] << value
        end
      end

      VpDict.trungviet.scan(chars, idx: idx) do |item|
        entry[item.key.size][:trungviet] = item.val
      end

      VpDict.cc_cedict.scan(chars, idx: idx) do |item|
        entry[item.key.size][:cc_cedict] = item.val
      end

      entry.to_a.sort_by(&.[0].-)
    end

    hanviet = MtCore.hanviet_mtl.translit(input, apply_cap: true).to_str
    send_json({hanviet: hanviet, entries: entries})
  end

  def find_node(dict, key)
    dict.trie.find(key)
  end
end
