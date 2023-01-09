require "../../oldmt/vp_hint"

class CV::VpdictCtrl < CV::BaseCtrl
  alias VdInfo = Tuple(String, String, Int32) # dict name, label, entries count

  getter core_dicts : Array(VdInfo) do
    [
      {"regular", "Thông dụng", VpDict.regular.size},
      {"essence", "Nền tảng", VpDict.essence.size},
      {"fixture", "Khoá cứng", VpDict.fixture.size},
      {"$hanviet", "Hán việt", VpDict.hanviet.size},
      {"$pin_yin", "Bính âm", VpDict.pin_yin.size},
    ]
  end

  def index
    pgidx, limit, offset = params.page_info(min: 24, max: 40)

    total = Nvdict.query.count.to_i
    query = Nvdict.query.limit(limit).offset(offset)

    book_dicts = query.order_by(utime: :desc).map do |dict|
      {dict.dname, dict.d_lbl, dict.dsize}
    end

    serv_json({
      cores: core_dicts,
      books: book_dicts,
      total: total,
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(total, limit),
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

    serv_json({
      dname: dname,
      d_dub: dname[0] == '-' ? Nvdict.load!(dname[1..]).d_lbl : "",
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
        dict.scan_best(chars, idx, user: _viuser.uname, temp: true) do |term|
          entry[term.key.size][:vietphrase] << String.build do |io|
            term.vals.reject(&.empty?).join(io, '/')
            io << '\t'
            term.tags.join(io, ' ')
            io << '\t'
            io << dict.type &+ term._mode &* 2_u8
          end
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

    serv_json(entries)
  end
end
