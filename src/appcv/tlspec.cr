require "../cutil/ukey_util"

class CV::TlSpec
  DIR = "db/tlspecs"

  CACHE = {} of String => self

  def self.load!(ukey : String)
    CACHE[ukey] ||= new(ukey, mode: 1)
  end

  def self.init!
    ukey = UkeyUtil.gen_ukey
    @@items.unshift(ukey)
    load!(ukey)
  end

  class_getter items : Array(String) do
    Dir.glob("#{DIR}/*.tsv")
      .sort_by { |x| -File.info(x).modification_time }
      .map { |x| File.basename(x, ".tsv") }
  end

  getter file : String
  getter ukey : String

  property zhtxt : String = ""
  property dname : String = "combine" # unique dict used
  property slink : String = "."       # source link

  property ctime : Int64? = nil
  property utime : Int64? = nil

  property uname : String? = nil # original poster uname
  property tspec : String = ""   # expected result/translation note

  property status : Int32 = 0 # 0: pending, 1: checking, 2: resolved, 3: duplicate, 4: wontfix
  property labels : Array(String) = [] of String

  getter logs = [] of Array(String)

  def initialize(@ukey : String, mode : Int32 = 1)
    @file = "#{DIR}/#{@ukey}.tsv"

    return unless mode > 0 && File.exists?(@file)

    File.read_lines(@file).each do |line|
      log(line.split('\t'))
    end
  end

  # format: [mtime uname field value...]
  def log(rows : Array(String)) : Bool
    return false unless mtime = rows[0]?.try(&.to_i64?)

    @logs << rows
    @utime = mtime
    @ctime ||= mtime

    case rows[1]?
    when "zhtxt"
      @dname = rows[2]? || "combine"
    when "zhctx"
      @zhtxt = rows[3]? || "???"
      @slink = rows[4]? || "."
    when "tspec"
      @uname ||= rows[2]? || "_"
      @tspec = rows[3]? || ""
    when "state"
      # uname = rows[2]? || "_"
      @status = rows[3]?.to_i? || 0
    when "label"
      # uname = rows[2]? || "_"
      @labels = rows[3..]
    end

    true
  end

  def log!(rows : Array(String))
    return unless log(rows)
    File.open(@file, "a") { |io| io.puts(rows.join('\t')) }
  end

  def log!(type : String, *value : String)
    log!([Time.utc.to_unix.to_s, type].concat(value))
  end

  def save!
    File.open(@file, "w") do |io|
      @logs.each { |rows| io.puts rows.join('\t') }
    end
  end
end
