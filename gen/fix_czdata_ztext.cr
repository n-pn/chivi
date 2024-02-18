require "zstd"
require "sqlite3"
require "../src/_util/hash_util"

HALF = {'.', '·', ',', '!', '?', ';', ':', '(', ')', '[', ']'}
FULL = {'。', '·', '，', '！', '？', '；', '：', '（', '）', '［', '］'}

def hw_alnum?(char : Char)
  ('0' <= char <= '9') || ('a' <= char <= 'z') || ('A' <= char <= 'Z')
end

def keep_format?(frag : String)
  return true if frag.empty?

  if frag[0].ascii_alphanumeric?
    lchar = frag[-1]?
    return true if !lchar || lchar.ascii_alphanumeric?
  end

  return true if frag.starts_with?("http") || frag.starts_with?("www.")
  return true if frag.in?(".jpg", ".png", ".gif")
  frag !~ /[\.·,!?;:\(\)\[\]]/
end

def fix_ztext(input : String)
  return "" if input.empty?

  String.build(input.bytesize) do |io|
    input.split(/([a-zA-Z0-9\s\.·,!?;:\(\)\[\]]+)/) do |frag|
      # keep it is literal
      if keep_format?(frag)
        io << frag
        next
      end

      # replace "..." with '…'
      if frag =~ /^\.{2,}/
        (frag.size / 3).round.to_i.times { io << '…' }
        next
      end

      frag.each_char do |char|
        if idx = HALF.index(char)
          io << FULL[idx]
        else
          io << char
        end
      end
    end
  end
end

class Czdata
  include DB::Serializable

  getter ch_no : Int32
  getter ztext : String
  getter chdiv : String
  getter title : String

  @[DB::Field(ignore: true)]
  getter zsize : Int32 = 0

  @[DB::Field(ignore: true)]
  getter cksum : Int32 = 0

  def self.load(db)
    db.query_all "select ch_no, ztext, chdiv, title from czdata", as: self
  end

  def fix_zdata!
    @ztext = fix_ztext(@ztext)
    @zsize = @ztext.size
    @cksum = HashUtil.fnv_1a(@ztext).unsafe_as(Int32) unless @zsize == 0
    @title = fix_ztext(@title)
    @chdiv = fix_ztext(@chdiv)
  end

  SAVE_SQL = <<-SQL
    insert into czdata(ch_no, s_cid, ztext, zsize, cksum, title, chdiv)
    values ($1, 0, $2, $3, $4, $5, $6)
    on conflict(ch_no) do update set
      ztext = excluded.ztext,
      zsize = excluded.zsize,
      cksum = excluded.cksum,
      title = excluded.title,
      chdiv = excluded.chdiv
    SQL

  def persist!(db)
    db.exec(SAVE_SQL, @ch_no, @ztext, @zsize, @cksum, @title, @chdiv)
  rescue ex
    puts ex.message
  end
end

def fix_zdata(db_path : String, label = "-/-")
  inputs = DB.open("sqlite3:#{db_path}?immutable=1") { |db| Czdata.load(db) }

  chap_avail = 0
  word_count = 0

  inputs.each do |zdata|
    zdata.fix_zdata!
    next if zdata.zsize == 0

    chap_avail &+= 1
    word_count &+= zdata.zsize
  end

  DB.open("sqlite3:#{db_path}?synchronous=normal&journal_mode=WAL") do |db|
    db.exec "alter table czdata add column cksum integer not null default 0" rescue nil
    db.exec "begin"
    inputs.each(&.persist!(db))
    db.exec "commit"
  end

  puts "<#{label}> #{db_path}: #{inputs.size} chaps corrected, db compressed"

  {inputs.size, chap_avail, word_count}
end

INP_DIR = "/2tb/zroot/wn_db"

snames = ARGV.reject(&.starts_with?('-'))

if ARGV.includes?("--users")
  snames.concat Dir.children(INP_DIR).select!(&.starts_with?('@'))
end

snames.each do |sname|
  files = Dir.glob("#{INP_DIR}/#{sname}/*.v1.db3")
  files.each_with_index(1) do |db_path, idx|
    zst_path = db_path + ".zst"
    next if File.file?(zst_path)

    chap_total, chap_avail, word_count = fix_zdata(db_path, "#{idx}/#{files.size}")

    sn_id = File.basename(db_path, "-zdata.v1.db3")
    mtime = File.info(db_path).modification_time.to_unix

    File.open("#{INP_DIR}/../#{sname}.tsv", "a") do |file|
      file << sn_id << '\t' << mtime << '\t'
      file << chap_total << '\t' << chap_avail << '\t'
      file << word_count << '\n'
    end

    cctx = Zstd::Compress::Context.new(level: 3)
    ibuf = File.read(db_path).to_slice
    File.write(zst_path, cctx.compress(ibuf))
  rescue ex
    Log.error(exception: ex) { db_path }
  end
end
