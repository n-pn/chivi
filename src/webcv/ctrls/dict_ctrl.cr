require "./base_ctrl"

class CV::DictCtrl < CV::BaseCtrl
  alias Dinfo = Tuple(String, String, Int32) # dict name, dict slug, entries count

  getter core_dicts : Array(Dinfo) do
    dicts = [] of Dinfo

    dicts << {"regular", dict_label("regular"), VpDict.regular.size}
    dicts << {"hanviet", dict_label("hanviet"), VpDict.hanviet.size}
    dicts << {"essence", dict_label("essence"), VpDict.essence.size}
    dicts << {"fixture", dict_label("fixture"), VpDict.fixture.size}

    dicts
  end

  def dict_label(dname : String)
    case dname
    when "cc_cedict" then "CC-CEDICT"
    when "trungviet" then "Trung Việt"
    when "hanviet"   then "Hán Việt"
    when "binh_am"   then "Bính âm"
    when "tradsim"   then "Phồn giản"
    when "regular"   then "Thông dụng"
    when "essence"   then "Nền tảng"
    when "fixture"   then "Cố định"
    else
      Cvbook.find({bhash: dname}).try(&.bname) || dname
    end
  end

  def index
    pgidx = params.fetch_int("page", min: 1)
    limit = 40

    offset = (pgidx - 1) * limit

    input = VpDict.udicts
    book_dicts = [] of Dinfo

    input[offset, limit].each do |dname|
      book_dicts << {dname, dict_label(dname), VpDict.load(dname).size}
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
    paged = terms.size > offset ? terms[offset, limit] : [] of VpTerm

    render_json({
      label: dict_label(dname),
      dname: dname,
      # dtype: vdict.dtype,
      p_min: vdict.p_min,
      terms: paged,
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
    input = params["input"].strip

    vietphrase = VpDict.for_lookup(dname, _cv_user.uname)

    chars = input.chars
    upper = chars.size - 1

    entries = (0..upper).map do |idx|
      entry = Hash(Int32, Lookup).new do |hash, key|
        hash[key] = Lookup.new { |h, k| h[k] = [] of String }
      end

      vietphrase.each do |dict, type|
        dict.scan(chars, idx) do |term|
          value = "#{type}: #{term.val.join("/")}"
          entry[term.key.size][:vietphrase] << value
        end
      end

      VpDict.trungviet.scan(chars, idx) do |item|
        entry[item.key.size][:trungviet] = item.val
      end

      VpDict.cc_cedict.scan(chars, idx) do |item|
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

    cvmtl = MtCore.generic_mtl(dname, _cv_user.uname)
    dicts = {
      VpDict.load(dname, _cv_user.uname),
      VpDict.load(dname),
      VpDict.load("regular", _cv_user.uname),
      VpDict.regular,
    }

    json_view do |jb|
      jb.object do
        words.each do |word|
          jb.field (word.as_s) do
            VpTermView.new(word.as_s, cvmtl, dicts).to_json(jb)
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
    stype = params["stype"]? == "_priv" ? cu_dname : "_base"

    vdict = VpDict.load(dname, stype)
    return halt!(500, "Không đủ quyền hạn!") if cu_privi < vdict.p_min

    mtime = VpTerm.mtime(Time.utc)

    key = params.fetch_str("key").strip
    val = params.fetch_str("val").split(" / ").map(&.strip)

    attr = params.fetch_str("attr", "")
    rank = params.fetch_str("rank", "").to_u8? || 3_u8

    vpterm = vdict.new_term(key, val, attr, rank, mtime: mtime, uname: cu_dname)
    return halt!(501, "Không thay đổi!") unless vdict.set!(vpterm)

    # TODO: save context

    # add to suggestion
    if vdict.dtype > 2
      suggest_term = VpDict.suggest.new_term(key, val, attr, rank, mtime: mtime)

      VpDict.suggest.find(key).try do |prev|
        suggest_term.val.concat(prev.val).uniq!
      end

      VpDict.suggest.set!(suggest_term)
    end

    # add to qtran dict if entry is a person name
    if vdict.dtype > 3 && dname != "combine"
      if key.size > 1 && vpterm.ptag.nper?
        combine_dict = VpDict.load("combine", stype)
        combine_term = combine_dict.new_term(key, val, attr, rank, mtime: mtime)
        combine_dict.set!(combine_term)
      end
    end

    json_view(vpterm)
  rescue err
    puts err
    halt! 500, err.message
  end
end
