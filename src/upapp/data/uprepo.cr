require "./upchap"

class UP::Chrepo
  @@get_sizes_sql : String = "select sizes from #{Chinfo.schema.table} where ch_no >= $1 and ch_no <= $2"

  CACHE = {} of String => self

  def self.load(sname : String, sn_id : String)
    CACHE["#{sname}/#{sn_id}"] ||= new(sname, sn_id)
  end

  getter sname : String
  getter sn_id : String

  TXT_DIR = "var/up_db/texts"
  DB3_DIR = "var/up_db/stems"

  def initialize(@sname, @sn_id)
    @info_db = Chinfo.db(sname, sn_id, DB3_DIR)
  end

  @@fetch_all_sql : String = Chinfo.schema.select_stmt(&.<< " where ch_no > $1 and ch_no <= $2 order by ch_no asc")

  def get_all(chmin : Int32, chmax : Int32) : Array(Chinfo)
    @info_db.query_all(@@fetch_all_sql, chmin, chmax, as: Chinfo)
  end

  @@fetch_top_sql : String = Chinfo.schema.select_stmt(&.<< " where ch_no <= $1 and ch_no > 0 order by ch_no desc limit $2")

  def get_top(chmax : Int32, limit = 6)
    @info_db.query_all(@@fetch_top_sql, chmax, limit, as: Chinfo)
  end

  def find(ch_no : Int32)
    @info_db.query_one?(Chinfo.schema.select_by_pkey, ch_no, as: Chinfo)
  end

  def load(ch_no : Int32)
    find(ch_no) || Chinfo.new(ch_no)
  end

  ####

  def prev_part(ch_no : Int32, p_idx : Int32)
    return "#{ch_no}_#{p_idx &- 1}" if p_idx > 1
    return "" unless (ch_no > 1) && (pinfo = self.find_prev(ch_no))

    psize = pinfo.psize
    psize > 1 ? "#{pinfo.ch_no}-#{psize}" : pinfo.ch_no.to_s
  end

  def next_part(ch_no : Int32, p_idx : Int32, psize : Int32)
    return "#{ch_no}_#{p_idx &+ 1}" if p_idx < psize
    self.find_next(ch_no).try(&.ch_no).to_s
  end

  @@find_prev_sql : String = Chinfo.schema.select_stmt(&.<< " where ch_no < $1 order by ch_no desc limit 1")

  # Find previous chapter
  def find_prev(ch_no : Int32)
    @info_db.query_one?(@@find_prev_sql, ch_no, as: Chinfo)
  end

  @@find_next_sql : String = Chinfo.schema.select_stmt(&.<< " where ch_no > $1 order by ch_no asc limit 1")

  # Find next chapter
  def find_next(ch_no : Int32)
    @info_db.query_one?(@@find_next_sql, ch_no, as: Chinfo)
  end

  ###

  @@get_last_ch_no = "select ch_no from chinfos order by ch_no desc limit 1"

  def last_ch_no
    @info_db.query_one?(query, as: Int32) || 0
  end

  def word_count(chmin : Int32, chmax : Int32) : Int32
    sizes = @info_db.query_all(@@get_sizes_sql, chmin, chmax, as: String)
    sizes.sum(&.split(' ').sum(&.to_i))
  end

  @@upsert_zinfo_sql : String = Chinfo.schema.upsert_stmt(keep_fields: %w[rlink spath ztitle zchdiv])

  def upsert_zinfos!(input : Array(ZR::Chinfo))
    @info_db.open_tx do |tx|
      input.map { |x| Chinfo.from(x).upsert!(@@upsert_zinfo_sql, db: tx) }
    end
  end

  @@update_zinfo_sql : String = Chinfo.schema.update_stmt(%w[vtitle vchdiv])

  def update_vinfos!(input : Array({Int32, String, String}))
    @info_db.open_tx do |db|
      input.each do |ch_no, vtitle, vchdiv|
        db.exec(@@update_zinfo_sql, vtitle, vchdiv, ch_no)
      end
    end
  end

  def update_vinfos!(wn_id : Int32, chmin : Int32 = 1, chmax : Int32 = 99999)
    ch_nos, zinfos = get_zinfos(chmin: chmin, chmax: chmax)
    return if ch_nos.empty?

    href = "#{CV_ENV.m1_host}/_m1/qtran/tl_mulu?wn_id=#{wn_id}"
    tran = HTTP::Client.post(href, body: zinfos, &.body_io.gets_to_end).lines

    data = ch_nos.map_with_index do |ch_no, idx|
      {ch_no, tran[idx &* 2], tran[idx &* 2 &+ 1]}
    end

    update_vinfos!(data)
  end

  @@fetch_zinfos_sql : String = Chinfo.schema.select_stmt(%w{ch_no ztitle zchdiv}, &.<< "where ch_no >= $1 and ch_no <= $2")

  private def get_zinfos(chmin = 1, chmax = 99999)
    ch_nos = [] of Int32
    buffer = String::Builder.new

    @info_db.open_ro do |tx|
      tx.query_each(@@fetch_zinfos_sql, chmin, chmax) do |rs|
        ch_nos << rs.read(Int32)          # read ch_no
        buffer << rs.read(String) << '\n' # read title
        buffer << rs.read(String) << '\n' # read chdiv
      end
    end

    {ch_nos, buffer.to_s}
  end

  ####

  def save_raw_text!(ch_no : Int32, ztext : String, uname : String = "",
                     title : String = "", chdiv : String = "")
    cinfo = self.load(ch_no)

    lines = ChapUtil.split_ztext(ztext)
    spath = "#{@sname}/#{@sn_id}/#{ch_no}"

    cinfo.save_raw_text!(lines, spath: spath, uname: uname, txt_dir: TXT_DIR)

    cinfo.ztitle = title unless title.empty?
    cinfo.zchdiv = chdiv unless chdiv.empty?

    cinfo.upsert!(db: @info_db)
  end
end
