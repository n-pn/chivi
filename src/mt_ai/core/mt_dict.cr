require "bit_array"
require "./mt_data/*"

class MT::MtDict
  def self.for_qt(pdict : String)
    new([TrieDict.load!(pdict), TrieDict.essence, TrieDict.new(pdict)])
  end

  def self.for_mt(pdict : String)
    new([TrieDict.load!(pdict), TrieDict.regular, TrieDict.essence, TrieDict.suggest])
  end

  def self.hv_name(pdict : String)
    new([TrieDict.load!(pdict), TrieDict.name_hv])
  end

  def initialize(@data : Array(TrieDict))
  end

  def add_temp(zstr, vstr, attr, epos)
    defn = MtDefn.new(vstr: vstr, attr: attr, dnum: :auto0, fpos: epos)
    @data.last.root[zstr].add_data(epos, defn) { MtWseg.new(zstr) }
    defn
  end

  def get_defn?(zstr : String)
    @data.each do |trie|
      next unless node = trie.root[zstr]?
      defn = node.defn
      return defn if defn
    end
  end

  def get_defn?(zstr : String, epos : MtEpos)
    got = alt = nil

    @data.each do |trie|
      next unless node = trie.root[zstr]?
      got = node.vals.try(&.[epos]?)
      return got, alt if got
      alt ||= node.defn
    end

    return got, alt
  end

  def all_wsegs(input : Array(Char), start : Int32 = 0)
    wsegs = [] of MtWseg
    skips = BitArray.new(input.size &- start &+ 1, false) # tracking for overriding

    @data.each do |trie|
      trie.scan_wseg(input, start: start) do |size, wseg|
        next if skips[size]    # skip if this wseg existed in higher dict
        skips[size] = true     # mark wseg as existed
        next if wseg.prio == 0 # skip wseg marks as deleted
        wsegs << wseg
      end
    end

    wsegs
  end

  # # ameba:disable Metrics/CyclomaticComplexity
  # def init(zstr : String, epos : MtEpos) : MtDefn
  #   case epos
  #   when .pu?
  #     vstr = CharUtil.normalize(zstr)
  #     add_temp(zstr, epos, vstr, MtAttr.parse_punct(zstr))
  #   when .em?
  #     add_temp(zstr, epos, zstr, MtAttr[Asis, Capx])
  #   when .url?
  #     add_temp(zstr, epos, CharUtil.normalize(zstr), MtAttr[Asis])
  #   when .od?
  #     add_temp(zstr, epos, init_od(zstr), :none)
  #   when .cd?
  #     add_temp(zstr, epos, init_cd(zstr), :none)
  #   when .vv?
  #     get_alt?(zstr) || add_temp(zstr, epos, init_vv(zstr), :none)
  #   when .nt?
  #     vstr, attr = init_nt(zstr)
  #     add_temp(zstr, epos, vstr, attr)
  #   when .nr?
  #     get_alt?(zstr) || add_temp(zstr, epos, init_nr(zstr), :none)
  #   else
  #     get_alt?(zstr) || add_temp(zstr, epos, QtCore.tl_hvword(zstr), :none)
  #   end
  # end

  # @[AlwaysInline]
  # def add_temp(zstr : String, epos : MtEpos, vstr : String, attr : MtAttr = :none)
  #   # TODO: Add to pdict directly?
  #   term = MtDefn.new(vstr: vstr, attr: attr, dnum: :autogen_0, fpos: epos)
  #   @dicts.last.add(zstr, epos, term)
  # end

  # NT_RE = /^([\d零〇一二两三四五六七八九十百千]+)(.*)/

  # def init_nt(zstr : String)
  #   return {CharUtil.normalize(zstr), MtAttr::Ntmp} unless zstr.matches?(/\p{Han}/)

  #   unless match = NT_RE.match(zstr)
  #     vstr = get_alt?(zstr).try(&.vstr) || QtCore.tl_hvname(zstr)
  #     return {vstr, MtAttr::Ntmp}
  #   end

  #   _, digits, suffix = match
  #   numstr = TlUnit.translate(digits)

  #   at_t = MtAttr[At_t, Ntmp]
  #   ntmp = MtAttr::Ntmp

  #   case suffix
  #   when "年"       then {"năm #{numstr}", ntmp}
  #   when "月"       then {"tháng #{numstr}", ntmp}
  #   when "日"       then {"ngày #{numstr}", ntmp}
  #   when "号"       then {"#{digits.size > 1 ? "ngày" : "mồng"} #{numstr}", ntmp}
  #   when "点", "时"  then {"#{numstr} giờ", at_t}
  #   when "分", "分钟" then {"#{numstr} phút", at_t}
  #   when "秒", "秒钟" then {"#{numstr} giây", at_t}
  #   when "半"       then {"#{numstr} rưỡi", at_t}
  #   else
  #     vstr = suffix.empty? ? numstr : "#{numstr} #{get(suffix, :NT).vstr}"
  #     {numstr, ntmp}
  #   end
  # end

  # def init_nr(zstr : String)
  #   # TODO: call special name translation engine

  #   fname, pchar, lname = zstr.partition(/\p{P}+/)
  #   return QtCore.tl_hvname(zstr) if pchar.empty?

  #   fname_vstr = get?(fname, :NR).try(&.vstr) || QtCore.tl_hvname(fname)
  #   lname_vstr = get?(lname, :NR).try(&.vstr) || QtCore.tl_hvname(lname)

  #   pchar = MAP_PCHAR[pchar[0]]? || pchar

  #   "#{fname_vstr}#{pchar}#{lname_vstr}"
  # end

  # MAP_PCHAR = {
  #   "、" => ", ",
  #   "､" => ", ",
  #   "･" => " ",
  #   "‧" => " ",
  # }

  # def init_cd_dedup(zstr : String)
  #   return unless zstr.size == 3
  #   return unless zstr[0] == '一' && zstr[1] == zstr[2]

  #   get?(zstr, :QP).try(&.vstr) || begin
  #     qzstr = zstr[-1].to_s
  #     qnode = get?(qzstr, :M) || get_alt?(qzstr)
  #     qvstr = qnode.try(&.vstr) || qzstr

  #     "từng #{qvstr} từng #{qvstr}"
  #   end
  # end

  # DECIMAL_SEP = {
  #   '点' => " chấm ",
  #   '．' => ".",
  #   '／' => "/",
  # }

  # def init_vv(zstr : String) : String
  #   QtCore.tl_hvword(zstr)
  # end
end
