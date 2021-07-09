require "./base_ctrl"

class CV::VpDictCtrl < CV::BaseCtrl
  alias Dinfo = Tuple(String, String, Int32) # dict name, dict slug, entries count

  getter system_dicts : Array(Dinfo) do
    dicts = [] of Dinfo

    dicts << {"hanviet", dict_label("hanviet"), VpDict.hanviet.size}
    dicts << {"regular", dict_label("regular"), VpDict.regular.size}
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
    page = params.fetch_int("page", min: 1)

    take = 40
    skip = (page - 1) * take

    unique_dicts = [] of Dinfo
    VpDict.udicts[skip, take].each do |dname|
      unique_dicts << {dname, dict_label(dname), VpDict.load(dname).size}
    end

    render_json({
      system: system_dicts,
      unique: unique_dicts,
    })
  end

  def show
    dname = params["dname"]
    vdict = VpDict.load(dname)

    page = params.fetch_int("page", min: 1)
    take = 30
    skip = (page - 1) * take

    terms = [] of VpTerm
    filter = VpTrie::Filter.init(params.to_unsafe_h)

    vdict.each do |term|
      next unless filter.match?(term)

      if skip > 0
        skip -= 1
      else
        terms << term
        break if terms.size >= take
      end
    end

    render_json({
      label: dict_label(dname),
      dname: dname,
      # dtype: vdict.dtype,
      p_min: vdict.p_min,
      terms: terms,
    })
  end

  alias Lookup = Hash(String, Array(String))

  def lookup
    dname = params["dname"]
    input = params["input"].strip

    dicts = {VpDict.load(dname), VpDict.regular}
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

    hanviet = MtCore.hanviet_mtl.translit(input).to_str
    render_json({hanviet: hanviet, entries: entries})
  end

  def search
    dname = params["dname"]
    input = params["input"]
    hints = [] of String

    special_dict = VpDict.load(dname)
    regular_dict = VpDict.regular
    hanviet_dict = VpDict.hanviet

    if special_node = special_dict.trie.find(input)
      special_node.edits.each { |term| hints.concat(term.val) }
    end

    if regular_node = regular_dict.trie.find(input)
      regular_node.edits.each { |term| hints.concat(term.val) }
    end

    if hanviet_node = hanviet_dict.trie.find(input)
      hanviet_node.edits.each { |term| hints.concat(term.val) }
    end

    if suggest_node = VpDict.suggest.trie.find(input)
      suggest_node.edits.each { |term| hints.concat(term.val) }
    end

    unless special_term = special_node.try(&.term)
      ext = regular_node.try(&.term.try(&.ext)) || ""
      special_term = special_dict.new_term(input, ext: ext)
    end

    unless regular_term = regular_node.try(&.term)
      regular_term = regular_dict.new_term(input)
    end

    unless hanviet_term = hanviet_node.try(&.term)
      hanviet_term = hanviet_dict.new_term(input)
    end

    binh_am = MtCore.binh_am_mtl.translit(input).to_s
    hanviet = MtCore.hanviet_mtl.translit(input).to_s

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
    vdict = VpDict.load(dname)
    mtime = VpTerm.mtime

    key = params.fetch_str("key").strip
    val = params.fetch_str("val").strip.split(" / ")
    ext = params.fetch_str("ext")

    new_term = vdict.new_term(key, val, ext, mtime: mtime, uname: cv_dname, privi: privi)
    return halt!(501, "Không thay đổi!") unless vdict.set!(new_term)

    # TODO: save context

    if vdict.dtype == 3 # unique dict
      # add to quick translation dict if entry is a name
      if key.size > 2 && new_term.tag.nper?
        combine_term = VpDict.combine.new_term(key, val, ext, mtime: mtime)
        VpDict.combine.set!(combine_term)
      end

      # add to suggestion
      suggest_term = VpDict.suggest.new_term(key, val, ext, mtime: mtime)

      if old_term = VpDict.suggest.find(key)
        suggest_term.val.concat(old_term.val).uniq!
      end

      VpDict.suggest.set!(suggest_term)
    end

    render_json(new_term)
  end
end
