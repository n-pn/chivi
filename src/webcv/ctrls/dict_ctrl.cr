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
      NvBtitle.get(dname).try(&.[1]) || dname
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

  alias Lookup = Hash(String, Array(String))

  def lookup
    dname = params["dname"]
    input = params["input"].strip

    dicts = [VpDict.load(dname)]
    dicts << VpDict.load("pleb_" + dname) if cu_tlmode < 2
    dicts << VpDict.regular
    dicts << VpDict.load("pleb_regular") if cu_tlmode < 2

    chars = input.chars
    upper = chars.size - 1

    entries = (0..upper).map do |idx|
      entry = Hash(Int32, Lookup).new do |hash, key|
        hash[key] = Lookup.new { |h, k| h[k] = [] of String }
      end

      dicts.each do |dict|
        dict.scan(chars, idx) do |item|
          entry[item.key.size]["vietphrase"].concat(item.val).uniq!
        end
      end

      VpDict.trungviet.scan(chars, idx) do |item|
        entry[item.key.size]["trungviet"] = item.val
      end

      VpDict.cc_cedict.scan(chars, idx) do |item|
        entry[item.key.size]["cc_cedict"] = item.val
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
    input = params["input"]
    hints = [] of String

    cvmtl = MtCore.generic_mtl(dname, mode: cu_tlmode)
    hints << cvmtl.cv_plain(input, mode: cu_tlmode, cap_mode: 0).to_s

    special_dict = VpDict.load(dname)
    regular_dict = VpDict.regular
    hanviet_dict = VpDict.hanviet

    if special_node = find_node(special_dict, input)
      special_node.edits.each { |term| hints.concat(term.val) }
    end

    if regular_node = find_node(regular_dict, input)
      regular_node.edits.each { |term| hints.concat(term.val) }
    end

    if hanviet_node = find_node(hanviet_dict, input)
      hanviet_node.edits.each { |term| hints.concat(term.val) }
    end

    if cu_tlmode < 2
      special_pleb = VpDict.load("pleb_#{dname}")
      special_node = find_node(special_pleb, input) || special_node

      regular_pleb = VpDict.load("pleb_regular")
      regular_node = find_node(regular_pleb, input) || regular_node
    end

    special_term = special_node.try(&.term) || special_dict.new_term(input)
    regular_term = regular_node.try(&.term) || regular_dict.new_term(input)
    hanviet_term = hanviet_node.try(&.term) || hanviet_dict.new_term(input)

    binh_am = MtCore.binh_am_mtl.translit(input).to_s
    hanviet = MtCore.hanviet_mtl.translit(input).to_s

    find_node(VpDict.suggest, input).try do |node|
      node.edits.each { |term| hints.concat(term.val) }
    end

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object {
          jb.field "trans", {binh_am: binh_am, hanviet: hanviet}
          jb.field "hints", hints.uniq.reject { |x| x.empty? || x == hanviet }

          jb.field "infos" {
            jb.array {
              special_term.to_json(jb)
              regular_term.to_json(jb)
              hanviet_term.to_json(jb)
            }
          }
        }
      end
    end
  end

  def upsert
    return halt!(500, "Không đủ quyền hạn!") if cu_privi < 1

    privi = params.fetch_int("privi")
    privi = cu_privi if privi > cu_privi

    dname = params["dname"]
    vdict = cu_tlmode < 2 ? VpDict.load("pleb_#{dname}") : VpDict.load(dname)

    mtime = VpTerm.mtime

    key = params.fetch_str("key").strip
    val = params.fetch_str("val").split(" / ").map(&.strip)

    attr = params.fetch_str("attr")
    rank = params.fetch_int("rank")

    new_term = vdict.new_term(key, val, attr, rank, mtime: mtime, uname: cu_dname, privi: privi)
    return halt!(501, "Không thay đổi!") unless vdict.set!(new_term)

    # TODO: save context

    if vdict.dtype == 3 # book dict
      # add to quick translation dict if entry is a name
      if key.size > 2 && new_term.ptag.nper?
        combine_term = VpDict.combine.new_term(key, val, attr, rank, mtime: mtime)
        VpDict.combine.set!(combine_term)
      end

      # add to suggestion
      suggest_term = VpDict.suggest.new_term(key, val, attr, rank, mtime: mtime)

      if old_term = VpDict.suggest.find(key)
        suggest_term.val.concat(old_term.val).uniq!
      end

      VpDict.suggest.set!(suggest_term)
    end

    render_json(new_term)
  end
end
