require "./base_ctrl"

class CV::VpdictCtrl < CV::BaseCtrl
  alias Dinfo = Tuple(String, String, Int32) # dict name, dict slug, entries count

  getter core_dicts : Array(Dinfo) do
    dicts = [] of Dinfo

    dicts << {"regular", CtrlUtil.d_dub("regular"), VpDict.regular.size}
    dicts << {"hanviet", CtrlUtil.d_dub("hanviet"), VpDict.hanviet.size}
    dicts << {"essence", CtrlUtil.d_dub("essence"), VpDict.essence.size}
    dicts << {"fixture", CtrlUtil.d_dub("fixture"), VpDict.fixture.size}

    dicts
  end

  def index
    pgidx = params.fetch_int("page", min: 1)
    limit = 40

    offset = (pgidx - 1) * limit

    input = VpDict.udicts
    book_dicts = [] of Dinfo

    input[offset, limit].each do |dname|
      book_dicts << {dname, CtrlUtil.d_dub(dname), VpDict.load(dname).size}
    end

    total = input.size
    pgmax = total.-(1).//(limit) + 1

    render_json({
      cores: core_dicts,
      books: book_dicts,
      total: total,
      pgidx: pgidx,
      pgmax: pgmax,
    })
  end

  def show
    dname = params["dname"]
    vdict = VpDict.load(dname)

    pgidx = params.fetch_int("page", min: 1)
    limit = 30

    offset = (pgidx - 1) * limit
    total = offset + 128

    terms = [] of VpTerm
    filter = VMatch.init(params.to_unsafe_h)

    # TODO: provide cursor to search faster

    vdict.data.reverse_each do |term|
      next unless filter.match?(term)
      terms << term
      break if terms.size >= total
    end

    pgmax = terms.size.-(1).//(limit) + 1
    terms = terms.size > offset ? terms[offset, limit] : [] of VpTerm

    render_json({
      dname: dname,
      d_dub: CtrlUtil.d_dub(dname),
      terms: terms,
      total: vdict.size,
      pgidx: pgidx,
      pgmax: pgmax,
    })
  rescue err
    puts err.inspect
    raise err
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
    render_json({hanviet: hanviet, entries: entries})
  end

  def find_node(dict, key)
    dict.trie.find(key)
  end

  def search
    dname = params["dname"]
    words = params.json("words").as_a

    bdict = VpDict.load(dname)
    cvmtl = MtCore.generic_mtl(dname, u_dname)

    json_view do |jb|
      jb.object do
        words.each do |word|
          jb.field (word.as_s) do
            view = VpTermView.new(word.as_s, bdict, cvmtl, "!#{u_dname}")
            view.to_json(jb)
          end
        end
      end
    end
  rescue err
    puts err
    halt! 500, err.message
  end

  def upsert
    dname = params["dname"]
    _priv = params["_priv"]? == "true"
    vdict = VpDict.load(dname)

    unless vdict.allow?(u_privi, _priv)
      return halt!(500, "Không đủ quyền hạn để sửa từ!")
    end

    key = params.fetch_str("key").gsub("\t", " ").strip
    val = params.fetch_str("val").gsub('', "").split(" | ").map(&.strip)

    if vdict.dtype == 2 && VpDict.fixture.find(key)
      return halt!(403, "Không thể sửa được từ khoá cứng!")
    end

    attr = params.fetch_str("attr", "")
    rank = params.fetch_str("rank", "").to_u8? || 3_u8

    uname = _priv ? "!" + u_dname : u_dname
    vpterm = VpTerm.new(key, val, attr, rank, uname: uname)

    return halt!(501, "Nội dung không thay đổi!") unless vdict.set!(vpterm)

    # add to suggestion
    add_to_suggest(vpterm.dup) if vdict.dtype > 1
    # add to qtran dict if entry is a person name
    add_to_combine(vpterm.dup) if vdict.dtype > 3 && dname != "combine"

    json_view(vpterm)
  rescue err
    puts err
    halt! 500, err.message
  end

  private def add_to_suggest(term : VpTerm)
    VpDict.suggest.find(term.key).try do |prev|
      term.val.concat(prev.val).uniq!
    end

    VpDict.suggest.set!(term)
  end

  private def add_to_combine(term : VpTerm)
    return unless term.key.size > 1 && term.ptag.person?
    VpDict.combine.set!(term)
  end
end
