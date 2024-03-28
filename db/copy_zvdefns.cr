require "../src/mt_ai/data/pg_defn"
require "../src/mt_sp/data/zv_defn"

CACHE_ID = {
  10 => "essence",
  20 => "word_hv",
  30 => "pin_yin",

  110 => "noun_vi",
  120 => "verb_vi",
  130 => "adjt_vi",

  150 => "time_vi",
  160 => "nqnt_vi",

  210 => "name_hv",
  220 => "name_ja",
  230 => "name_en",

  310 => "b_title",
  320 => "c_title",

  11 => "regular",
  21 => "combine",
  31 => "suggest",

  211 => "m_n_pair",
  221 => "m_v_pair",
  231 => "v_n_pair",
  241 => "v_v_pair",
  251 => "v_c_pair",
  261 => "p_v_pair",
  271 => "d_v_pair",
}

def map_dict(d_id : Int32) : String
  CACHE_ID[d_id] ||= begin
    case d_id % 10
    when MT::MtDtyp::Wnovel.value then "wn#{d_id // 10}"
    when MT::MtDtyp::Userpj.value then "up#{d_id // 10}"
    when MT::MtDtyp::Userqt.value then "qt#{d_id // 10}"
    else                               raise "invalid #{d_id}"
    end
  end
end

MIN_TIME = ARGV[0]?.try(&.to_i) || 0

inp_defns = MT::PgDefn.get_all(MIN_TIME, &.<< "where mtime >= $1").sort_by! do |defn|
  {defn.mtime, defn.zstr, defn.d_id}
end

puts inp_defns.size

out_defns = inp_defns.map do |defn|
  SP::Zvdefn.new(
    dict: map_dict(defn.d_id),
    zstr: CharUtil.fast_sanitize(defn.zstr),
    cpos: defn.cpos,
    vstr: defn.vstr,
    attr: defn.attr,
    rank: defn.rank,
    _user: defn.uname,
    _time: defn.mtime,
    _lock: defn.plock,
  )
end

out_defns.each_slice(10_000) do |slice|
  PGDB.transaction do |tx|
    slice.each(&.upsert!(db: tx.connection))
  end

  puts "#{slice.size} saved!"
end

puts TimeUtil.cv_mtime
